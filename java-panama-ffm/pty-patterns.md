# Java Panama FFM — PTY and POSIX Testing Patterns

---

## Panama FFM native write/read on PTY slave fds causes SIGTRAP JVM crash in the next test class (macOS AArch64)

**ID:** GE-0038
**Stack:** Panama FFM, Java 25 / GraalVM CE 25, macOS AArch64, Maven Surefire
**Symptom:** A test class that calls `PosixLibrary.write()` or `PosixLibrary.read()` on a PTY slave fd runs cleanly. The next test class then crashes the JVM with exit code 133 (signal 5 = SIGTRAP) — no error message, no stack trace, just a sudden JVM death reported by surefire as "The forked VM terminated without properly saying goodbye."
**Context:** Two test classes in the same surefire JVM fork, where the first uses Panama FFM `write()`/`read()` on PTY slave fds and the second uses Panama FFM downcalls for anything else.

### What was tried (didn't work)
- Closing all fds properly in `@AfterEach` — fds confirmed closed, crash persists
- Removing `O_NOCTTY` — no effect
- Testing classes in isolation — each class passes perfectly alone
- Running unrelated class → PTY class — passes (no Panama I/O on slave fds in between)
- Running PTY class (open-only, no write/read) → next class — passes

### Root cause
Panama FFM `write()` and `read()` downcalls on PTY slave fds leave internal state that corrupts Panama FFM's downcall infrastructure in the same JVM process. On macOS AArch64, this manifests as a SIGTRAP (exit 133) — likely a PAC (Pointer Authentication Code) violation triggered when the corrupted state is used by a subsequent Panama downcall. The exact mechanism is inside the JVM/Panama implementation.

The minimum reproducer: `PosixLibraryTest#writeToSlaveIsReadableFromMaster` → any test using Panama FFM downcalls in the same surefire JVM fork.

### Fix

Configure surefire with `reuseForks=false` — each test class gets a fresh JVM fork, so corrupted state never crosses class boundaries. **See GE-0039** for the full Maven config.

### Why this is non-obvious
- Both test classes pass perfectly in isolation — no test failure, no warning
- The crash happens in the SECOND class, not the one that did the write/read
- Exit code 133 (SIGTRAP) gives no indication of Panama FFM involvement
- Opening the slave fd (without write/read) does NOT cause the crash — only actual I/O does
- The fix is in the build config, not in the test or production code

*Score: 13/15 · Included because: crash in wrong class, no error, counterintuitive cause; would stump anyone adding PTY I/O tests to a Panama FFM project · Reservation: may be fixed in future JVM/Panama versions*

---

## Panama FFM `IOC_OUT` ioctl returns success but leaves buffer zeroed (macOS AArch64, JVM mode)

**ID:** GE-0053
**Stack:** Java Panama FFM (JDK 21+), macOS AArch64, JVM mode only
**Symptom:** `ioctl(masterFd, TIOCGWINSZ, buf)` returns 0 (success) but `buf` stays all-zeros after the call. The PTY window size set via `TIOCSWINSZ` is not read back.

```java
MemorySegment winsize = temp.allocate(8);
int ret = ioctl(fd, TIOCGWINSZ, winsize);
// ret == 0 (success), but winsize bytes are all 0
short rows = winsize.get(ValueLayout.JAVA_SHORT, 0);  // always 0
short cols = winsize.get(ValueLayout.JAVA_SHORT, 2);  // always 0
```

Confirmed via: C binary from same shell → works. JNI from same JVM → works. Panama FFM → silent zero buffer.

**Context:** Occurs when calling any `IOC_OUT` direction ioctl (kernel writes to a caller-provided buffer) via a Panama FFM non-variadic `FunctionDescriptor`. `IOC_IN` direction ioctls (caller provides data, kernel reads it) — such as `TIOCSWINSZ` — work correctly via the same descriptor. Asymmetric failure.

### Root cause

`ioctl(2)` is a variadic function in C but was being called via a Panama FFM non-variadic `FunctionDescriptor` without `Linker.Option.firstVariadicArg(2)`. On macOS AArch64, the AAPCS64 calling convention requires `al` (the count of floating-point registers used) to be set in `x8` for variadic calls. Without `firstVariadicArg`, Panama treats the call as non-variadic and doesn't set this register correctly, causing the ADDRESS argument (struct pointer) to land in the wrong register. The kernel writes to whatever address it received — garbage — and returns 0, masking the failure entirely.

For `IOC_IN` calls the kernel reads the pointer value — even with the ABI mismatch the value arrives usably. For `IOC_OUT` the kernel writes to the address it received — if the pointer landed wrong, the Java `MemorySegment` is untouched.

### Fix

Add `Linker.Option.firstVariadicArg(2)` to the ioctl downcall handle:

```java
// BEFORE — broken: variadic ioctl without declaring where variadic args start
private static final MethodHandle IOCTL = LINKER.downcallHandle(
    LIBC.find("ioctl").orElseThrow(),
    FunctionDescriptor.of(ValueLayout.JAVA_INT,
        ValueLayout.JAVA_INT, ValueLayout.JAVA_LONG, ValueLayout.ADDRESS));

// AFTER — correct: tells Panama the 3rd arg (index 2) is the first variadic arg
private static final MethodHandle IOCTL = LINKER.downcallHandle(
    LIBC.find("ioctl").orElseThrow(),
    FunctionDescriptor.of(ValueLayout.JAVA_INT,
        ValueLayout.JAVA_INT, ValueLayout.JAVA_LONG, ValueLayout.ADDRESS),
    Linker.Option.firstVariadicArg(2));
```

**Applies to any variadic C function called via Panama FFM with non-fixed-position pointer args on AArch64.** `open(2)` with two arguments is safe without the option because the optional third arg is never passed.

**Workaround in JVM-mode tests:** Use `tput cols` / `tput lines` spawned as subprocess on the PTY — they call `TIOCGWINSZ` internally through real libc and report correct values via stdout. See GE-0061.

**In GraalVM native image:** `TIOCGWINSZ` via Panama FFM works correctly — GraalVM compiles Panama stubs to actual native code with correct ABI. No workaround needed in production.

**How the bug was discovered:** Added `tput cols` integration tests for PTY terminal resize. `tput` reported 0 (the default) instead of the set value, proving `TIOCSWINSZ` had never actually set the window size despite returning success. Adding `firstVariadicArg(2)` confirmed the fix.

### Why non-obvious

`TIOCSWINSZ` (IOC_IN, same ioctl, same Panama descriptor) works perfectly, so the Panama binding looks correct. The failure is direction-specific and silent — ioctl returns 0, no exception, no warning. You only discover it by noticing the buffer values are always zero despite a prior successful `TIOCSWINSZ`.

*Score: 13/15 · Included because: silent failure, asymmetric (IOC_IN works, IOC_OUT doesn't), zero discoverability from docs · Reservation: AArch64-specific, JVM-mode-only*

---

## tput silently reports 0 when TERM env var is absent in PTY integration tests

**ID:** GE-0060
**Stack:** macOS, tput, Java/Maven surefire test runner, PTY subprocess testing
**Symptom:** `tput cols` or `tput lines` spawned as a subprocess on a PTY returns `0\r\n` (or sometimes nothing) instead of the expected terminal dimensions. The test assertion `result.contains("100")` fails even though `TIOCSWINSZ` was called correctly.
**Context:** Spawning `tput` from a test process launched by Maven surefire. Surefire runs without a controlling terminal, so `$TERM` is not set in the inherited environment.

### Root cause

`tput` uses `$TERM` to select the terminfo database entry. Without it, tput does not know which terminal type it is talking to and refuses to query terminal capabilities like cols/lines. It does not error — it returns 0 silently.

### Fix

Pass `TERM=xterm-256color` explicitly in the subprocess environment:

```java
// PtyProcess.spawn(String[] command, String[] env)
// env is a FULL REPLACEMENT — not merged with parent env
pty.spawn(new String[]{"/usr/bin/tput", "cols"},
          new String[]{"TERM=xterm-256color"});
```

If your spawn API only inherits the parent environment, set `TERM` via `ProcessBuilder.environment().put("TERM", "xterm-256color")`.

### Why non-obvious

The failure mode is silent — tput exits 0 and prints `0`, not an error. The test assertion `result.contains("100")` fails and the natural assumption is that `TIOCSWINSZ` didn't work. You spend time investigating the PTY resize path when the real issue is that the measurement tool (tput) isn't configured. The fix (inject `TERM`) is in an unrelated-looking part of the code.

*Score: 10/15 · Included because: silent wrong value (not an error), natural misdiagnosis direction (blame TIOCSWINSZ not tput), affects any PTY test suite on CI-like environments · Reservation: TERM is a standard env var, fairly well-known requirement for tput*

---

## Use tput to verify PTY window dimensions in JVM-mode Panama FFM tests

**ID:** GE-0061
**Stack:** Java Panama FFM, macOS AArch64, PTY testing, JVM mode
**Labels:** `#testing` `#workaround`
**What it achieves:** Provides a reliable PTY window dimension verification path in JVM-mode tests, bypassing the Panama FFM IOC_OUT ioctl bug (GE-0053) by using `tput` as a subprocess that calls `TIOCGWINSZ` through real libc.
**Context:** Testing PTY resize operations in JVM mode on macOS AArch64, where `ioctl(fd, TIOCGWINSZ, ...)` via Panama FFM silently returns zeros.

### The technique

```java
@Test
void tputColsReflectsResizeDimensions() throws Exception {
    pty.open();
    pty.resize(24, 100);  // calls ioctl(TIOCSWINSZ)

    CompletableFuture<String> received = new CompletableFuture<>();
    StringBuilder output = new StringBuilder();
    pty.startReader(text -> {
        output.append(text);
        if (!received.isDone()) received.complete(output.toString());
    });
    // Start reader BEFORE spawn — tput exits immediately
    pty.spawn(new String[]{"/usr/bin/tput", "cols"},
              new String[]{"TERM=xterm-256color"});

    String result = received.get(3, TimeUnit.SECONDS);
    assertTrue(result.trim().contains("100"),
            "tput cols should report 100, got: " + result);
}
```

### Why non-obvious

The obvious approach is `ioctl(masterFd, TIOCGWINSZ, buf)` via Panama FFM — but on macOS AArch64 in JVM mode, Panama's non-variadic `FunctionDescriptor` for the variadic `ioctl()` causes IOC_OUT direction ioctls to silently return 0 while leaving the buffer zeroed (GE-0053). `tput` calls `TIOCGWINSZ` internally through real libc (not Panama FFM), so it bypasses the ABI limitation entirely.

The subprocess also exercises the full kernel path: TIOCSWINSZ on the master → kernel PTY state → subprocess reads TIOCGWINSZ on the slave. This is the most realistic test of whether a subprocess will actually see the correct terminal dimensions.

**Side benefit:** The tput tests verify end-to-end PTY slave visibility of the window size — something the raw ioctl test doesn't cover.

### Caveats

- Requires TERM env var set (see GE-0060)
- Start the reader before spawning tput (tput exits immediately — race condition otherwise)
- Works in GraalVM native image too (both approaches work there)

*Score: 12/15 · Included because: non-obvious workaround for a non-obvious Panama FFM limitation; provides stronger end-to-end coverage than the direct ioctl test · Reservation: technique is specific to the Panama FFM JVM-mode limitation on AArch64*
