# Java Panama FFM + GraalVM Native Image Gotchas

Discovered building a Quarkus Native macOS app with Panama FFM and an Objective-C bridge.

---

## jextract upcall helpers (allocate()) fail silently in native image

**ID:** GE-20260412-dc1548
**Stack:** Panama FFM (Java 22+), jextract, GraalVM 25
**Symptom:** `jextract`-generated callback classes have an `allocate(Function fi, Arena arena)` method. Calling it in JVM mode works. In native image it throws `NoSuchMethodException` for the interface's method.
**Context:** Any Panama upcall using jextract's generated `SomeCallback.allocate()` helper.

### What was tried (didn't work)
- Using `WindowClosedCallback.allocate(handler::run, arena)` — throws at runtime in native image
- Registering the generated interface in `reflect-config.json` with `allDeclaredMethods: true` — still fails

### Root cause
jextract's `allocate()` uses `MethodHandles.privateLookupIn()` + `findVirtual()` on the generated functional interface. GraalVM's native image cannot resolve interface method handles created this way at compile time, even with reflection config.

### Fix
Bypass jextract's upcall helper entirely. Use `MethodHandles.lookup().findStatic()` on a *static method you control* instead:

```java
public static MemorySegment createCallback(Arena arena, Runnable handler) {
    windowClosedHandler = handler;
    try {
        MethodHandle mh = MethodHandles.lookup()
                .findStatic(Callbacks.class, "onWindowClosed",
                        MethodType.methodType(void.class));
        return Linker.nativeLinker().upcallStub(mh, FunctionDescriptor.ofVoid(), arena);
    } catch (NoSuchMethodException | IllegalAccessException e) {
        throw new RuntimeException(e);
    }
}

public static void onWindowClosed() { ... }  // ← register THIS in reflect-config.json
```

Register the static method (not the interface) in `reflect-config.json`.

### Why this is non-obvious
Works perfectly in JVM mode. Fails only in native image. The jextract-generated code looks correct and idiomatic. The failure mode (NoSuchMethodException for an interface method) doesn't point clearly to the privateLookupIn cause.

---

## reachability-metadata.json foreign section uses "directUpcalls" not "upcalls"

**ID:** GE-20260412-e00a2f
**Stack:** Panama FFM, GraalVM native image, GraalVM 25
**Symptom:** `MissingForeignRegistrationError` at runtime in native image. The error message says "add the following to the 'foreign' section" but prints an empty snippet (GraalVM 25 bug — the snippet generator is broken).
**Context:** GraalVM 25 native image with Panama FFM upcalls.

### What was tried (didn't work)
- `{"foreign": {"upcalls": [{"descriptor": "()void"}]}}` — parse error
- `{"foreign": {"upcalls": [{"descriptor": "()V"}]}}` — parse error
- Various descriptor formats based on documentation — parse errors

### Root cause
GraalVM 25's `reachability-metadata.json` foreign section uses `directUpcalls` (not `upcalls`) with class/method details, not a generic descriptor string. The documentation and the error message snippet (which GraalVM 25.0.2 fails to generate) are both misleading.

### Fix
Use the native-image tracing agent to generate the correct format:

```bash
java -agentlib:native-image-agent=config-output-dir=target/agent-config,config-write-period-secs=3 \
     --enable-native-access=ALL-UNNAMED \
     -jar target/quarkus-app/quarkus-run.jar
# ... interact with app, then kill it ...
cat target/agent-config/reachability-metadata.json
```

The correct format (GraalVM 25):

```json
{
  "foreign": {
    "directUpcalls": [
      {
        "class": "com.example.Callbacks",
        "method": "onWindowClosed",
        "returnType": "void",
        "parameterTypes": []
      }
    ],
    "downcalls": [
      { "returnType": "jlong", "parameterTypes": ["void*", "jint", "jint", "void*"] },
      { "returnType": "void",  "parameterTypes": [] }
    ]
  }
}
```

### Why this is non-obvious
The error message is supposed to print the correct JSON snippet. In GraalVM 25.0.2, it prints nothing (empty snippet). All documentation examples use `upcalls`, not `directUpcalls`. You cannot guess the correct format from any available source — only the tracing agent reveals it.

---

## Arena.ofAuto() throws UnsupportedOperationException on close()

**ID:** GE-20260412-c15261
**Stack:** Panama FFM (Java 22+), GraalVM 25
**Symptom:** Application crashes at shutdown with `UnsupportedOperationException` when a `@PreDestroy` method calls `arena.close()`.
**Context:** Using `Arena.ofAuto()` as an application-lifetime arena for Panama upcall stubs.

### What was tried (didn't work)
- `private final Arena arena = Arena.ofAuto();` with `@PreDestroy void close() { arena.close(); }`
  — throws at shutdown

### Root cause
`Arena.ofAuto()` is GC-managed. It does not support explicit `close()`. Calling it throws `UnsupportedOperationException`.

### Fix
Use `Arena.ofShared()` for explicitly-managed, thread-safe arenas:

```java
private final Arena arena = Arena.ofShared();  // not ofAuto()

@PreDestroy
void close() { arena.close(); }  // now works
```

### Why this is non-obvious
`ofAuto()` sounds like the "easy" choice and works fine for holding the arena open. The `close()` failure only surfaces at shutdown, which is often not tested. The name doesn't suggest it's non-closeable.

---

## jextract-generated classes initialize at build time and fail to find dylib symbols

**ID:** GE-20260412-73b00b
**Stack:** Panama FFM (Java 22+), jextract, GraalVM 25
**Symptom:** Native image build fails: `Class initialization of MyMacUI_h$myui_start failed. Caused by: UnsatisfiedLinkError: unresolved symbol: myui_start`
**Context:** jextract-generated binding classes try to resolve native symbols at class-initialization time, which GraalVM runs at build time. The dylib isn't present at build time.

### Root cause
jextract generates static class initializers that call `findOrThrow("symbol_name")` to look up the native symbol. GraalVM native image runs these initializers at build time by default. The dylib doesn't exist at build time, so symbol lookup fails.

### Fix
Defer initialization of the entire generated package to runtime in `native-image.properties`:

```properties
Args = --enable-native-access=ALL-UNNAMED \
       --initialize-at-run-time=com.example.bridge.gen
```

### Why this is non-obvious
The JVM mode works perfectly because class initialization happens at runtime when the dylib is loaded. Only native image breaks. The error message correctly identifies the problem but the solution (runtime initialization of the whole package) isn't obvious.

---

## Hand-written Panama FFM classes with static final MethodHandle fields also need --initialize-at-run-time

**ID:** GE-20260412-e103a8
**Stack:** Panama FFM, GraalVM native image 25, macOS AArch64
**Symptom:** Native image build fails with a `linkToNative` parsing error at analysis time on the first public method of a hand-written class that holds `private static final MethodHandle` fields created via `Linker.nativeLinker().downcallHandle()`. Error is completely different from the `UnsatisfiedLinkError` that jextract-generated classes produce.
**Context:** Any hand-written class (not jextract-generated) that initialises `MethodHandle` fields pointing to native libc functions via `Linker.nativeLinker().defaultLookup()`.

### What was tried (didn't work)
- Assumed build-time initialisation was safe — `Linker` and `SymbolLookup` are always available, and libc symbols are present at build time. Build fails at analysis phase.
- Only added `--initialize-at-run-time` for the jextract-generated package (`bridge.gen`) — own hand-written class was not covered.

### Root cause
GraalVM's pointsto analyser traverses `invokeExact()` call sites during build-time analysis, attempting to inline through the `linkToNative` intrinsic. Even though `defaultLookup()` can resolve libc symbols at build time, the analysis phase cannot complete the traversal. Adding `--initialize-at-run-time` defers the static field initialisation (and thus the downcall handle creation) to runtime, where the JVM handles it normally.

### Fix
Add the hand-written class to `--initialize-at-run-time` in `native-image.properties`:

```properties
Args = --enable-native-access=ALL-UNNAMED \
       --initialize-at-run-time=com.example.bridge.gen \
       --initialize-at-run-time=com.example.pty.PosixLibrary
```

Also register the new downcall signatures in `reachability-metadata.json` since the handles are now created at runtime (not build time):

```json
{"returnType": "jint", "parameterTypes": ["jint", "void*"]},
{"returnType": "jint", "parameterTypes": ["jint", "jint", "void*"]}
```

### Why this is non-obvious
jextract-generated classes need run-time init because they call `findOrThrow()` for symbol lookup. A hand-written class with `Linker.downcallHandle()` looks completely safe for build-time init — the Linker is always present and libc symbols are available at build time. The different error type (`linkToNative` analysis failure vs `UnsatisfiedLinkError`) makes it hard to connect the two cases or apply the same fix.

---

## MissingForeignRegistrationError gives no indication which downcall entry is wrong

**ID:** GE-20260412-937f1d
**Stack:** Panama FFM, GraalVM native image 25, reachability-metadata.json
**Symptom:** `MissingForeignRegistrationError` at runtime. The error message names the failing function but does NOT tell you which entry in `reachability-metadata.json` is wrong or what is wrong about it (wrong parameter count, wrong type, etc.).
**Context:** Any time a `downcalls` entry in `reachability-metadata.json` doesn't exactly match the `FunctionDescriptor` used in the code — common when writing entries by hand.

### What was tried (didn't work)
- `posix_spawn` entry with 5 `void*` params — fails at runtime with `MissingForeignRegistrationError`. The error names `posix_spawn` but doesn't say "wrong param count".

### Root cause
GraalVM matches downcall descriptors by exact signature. `posix_spawn` takes 6 ADDRESS params (pid_t\*, path, file_actions, attrp, argv[], envp[]) but the entry had 5. The runtime error reports the function name but gives no diagnostic about which aspect of the signature mismatches.

### Fix
Count ADDRESS params in the `FunctionDescriptor` exactly and match them in the JSON entry one-for-one:

```json
{"returnType": "jint", "parameterTypes": ["void*", "void*", "void*", "void*", "void*", "void*"]}
```
(6 `void*` for posix_spawn — pid_t\*, path, file_actions, attrp, argv[], envp[])

Diagnosis when you hit this: cross-check every downcall entry against its `FunctionDescriptor` parameter list, one by one, counting ADDRESS → `void*`, JAVA_INT → `jint`, JAVA_LONG → `jlong`.

### Why this is non-obvious
The error looks like a missing entry (the function isn't registered at all), not a wrong entry. You instinctively add a new entry rather than fix the existing one. The mismatch is a count error that's easy to make when writing entries by hand from memory.
