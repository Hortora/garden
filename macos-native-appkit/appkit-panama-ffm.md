# AppKit + Panama FFM Gotchas

Discovered building a native macOS desktop app with Java (Quarkus Native),
Objective-C bridge, and Panama FFM API.

---


---

## GCD main queue blocks silently never execute when [NSApp run] is inside dispatch_async

**Stack:** AppKit, GCD, Objective-C
**Symptom:** `dispatch_async(dispatch_get_main_queue(), block)` and `dispatch_after(delay, main_queue, block)` are called, no error, but the block never executes. Ever. Not even after a long wait.
**Context:** Any architecture where `[NSApp run]` is called from *inside* a `dispatch_async(main_queue, ...)` block — which is the standard pattern for running AppKit from a non-main thread (e.g. Quarkus worker thread calling into AppKit).

### What was tried (didn't work)
- `dispatch_async(main_queue, focusBlock)` — never ran
- `dispatch_after(50ms, main_queue, focusBlock)` — never ran
- `dispatch_after(200ms, main_queue, cursorFix)` — never ran
- `performSelector:withObject:afterDelay:0` — never ran
- `window.initialFirstResponder = inputField` — ran but too early, wrong timing
- Added NSLog inside the dispatch block — log never appeared

### Root cause
GCD serializes the main queue — it will not dispatch new blocks while one is already executing. When `[NSApp run]` is called inside a `dispatch_async` block, GCD considers that outer block still running (it will only "finish" when `[NSApp run]` returns, i.e. when the app terminates). So all new `dispatch_async` / `dispatch_after` calls to the main queue silently queue and wait forever.

AppKit events (typing, clicking, window delegate callbacks) still work because `[NSApp run]` pumps CFRunLoop directly — completely bypassing GCD.

### Fix
Use AppKit delegate methods instead of dispatch for post-startup work:

```objc
// ✅ These fire inside the run loop — no GCD involved
- (void)windowDidBecomeKey:(NSNotification *)notification { ... }
- (void)applicationDidFinishLaunching:(NSNotification *)notification { ... }

// ✅ NSTimer fires via CFRunLoop, not GCD
[NSTimer scheduledTimerWithTimeInterval:0.05 target:self
    selector:@selector(doFocus) userInfo:nil repeats:NO];

// ❌ These all silently queue forever
dispatch_async(dispatch_get_main_queue(), block);
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 50ms), main_queue, block);
[obj performSelector:@selector(x) withObject:nil afterDelay:0.0];
```

### Why this is non-obvious
AppKit events work fine, so the app feels alive. Only GCD-dispatched blocks fail. There's no error, no warning, no crash. The dispatch call succeeds; the block simply never runs. The symptom (something doesn't happen) gives no clue that GCD serialisation is the cause.


---

## UI updates from Panama upcalls must be synchronous — dispatch_async doesn't drain

**Stack:** AppKit, Panama FFM, Objective-C, GCD
**Symptom:** A Panama upcall fires (e.g. from NSTextField action → Java → back to ObjC). The ObjC function calls `dispatch_async(main_queue, updateBlock)` to update the UI. The update never appears. No error.
**Context:** Any Panama upcall triggered from an AppKit event handler (e.g. NSTextField action, NSButton click). This is a special case of the GCD block problem above.

### What was tried (didn't work)
- `dispatch_async(main_queue, ^{ [view setString:updated]; })` — block never ran

### Root cause
The upcall fires on the main thread (same thread as the AppKit event handler). The main queue is locked by the outer `dispatch_async` block containing `[NSApp run]`. Dispatching from within the upcall just adds another blocked item to the queue.

### Fix
Check the thread and update synchronously when already on main thread:

```objc
void myui_append_output(const char *text) {
    NSString *str = [NSString stringWithUTF8String:text];
    if ([NSThread isMainThread]) {
        doUpdate(str);  // synchronous — we are already here
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{ doUpdate(str); });
    }
}
```

### Why this is non-obvious
The upcall works (Java code runs). The downcall works (ObjC function is called). The dispatch call itself succeeds. Only the block silently never executes. There is zero indication at any layer that this is a threading/GCD problem.


---

## Replacing window.contentView silently breaks all keyboard and mouse event routing

**Stack:** AppKit, Objective-C
**Symptom:** After `window.contentView = myNewView`, mouse clicks and keyboard events no longer reach any subview. Buttons don't respond. NSTextField receives no input. The window close button still works.
**Context:** Any code that replaces the content view after window creation — common when trying to use NSSplitView or a custom container as the root view.

### What was tried (didn't work)
- `window.contentView = NSSplitView` — blocked all events to NSSplitView subviews
- `window.contentView = NSView container` — blocked all events to container subviews
- `[window recalculateKeyViewLoop]` after replacement — no effect
- `[window makeFirstResponder:subview]` after replacement — no effect

### Root cause
AppKit maintains an internal connection between the window and its responder chain through the original `contentView`. Replacing it with a new view breaks this connection silently. The window chrome (traffic lights) still responds because it has its own routing path, but nothing in the content area does.

### Fix
Never replace `window.contentView`. Instead, add views *to* the existing content view:

```objc
// ❌ Breaks event routing
window.contentView = mySplitView;

// ✅ Preserves event routing
NSView *root = window.contentView;  // keep AppKit's original view
[root addSubview:terminalView];
[root addSubview:inputField];
```

### Why this is non-obvious
The window still draws correctly. The views are visible. Only event routing is broken, and only for subviews — the window chrome still works. This creates the impression that there's a focus or first-responder problem, not a view hierarchy problem.


---

## WKWebView silently renders nothing in a JVM process without an .app bundle

**Stack:** WebKit, WKWebView, Objective-C, macOS
**Symptom:** WKWebView is created with the correct frame, is not hidden, `loadHTMLString:` is called, `evaluateJavaScript:` completion handler reports no error. Nothing renders on screen. `WKNavigationDelegate` methods (`didFinishNavigation:`, `didFailNavigation:`) never fire.
**Context:** Running as a JVM process launched from terminal, without a proper macOS `.app` bundle structure.

### What was tried (didn't work)
- Setting `navigationDelegate` — delegate never called
- `WKWebViewConfiguration.websiteDataStore = nonPersistentDataStore` — no effect
- Various HTML structures and content — no effect
- Logging JS errors in completion handler — no errors, just nil result
- `wkPreferences.javaScriptEnabled = YES` explicitly — no effect

### Root cause
WKWebView renders in a separate `WebContent` subprocess. In a proper `.app` bundle, macOS sets up IPC between the host process and WebContent correctly (using sandbox permissions and bundle entitlements). In a JVM process launched from terminal with no bundle, this IPC silently fails. The ObjC calls all succeed, but the effects never reach the WebContent process.

### Fix
In development (JVM mode), replace WKWebView with NSTextView for output display. NSTextView is entirely in-process, requires no subprocess, and works correctly.

WKWebView works correctly inside a proper `.app` bundle (production/native image builds).

Design the output pane with a swappable renderer so NSTextView can be used in development and WKWebView in production.

### Why this is non-obvious
Every ObjC call returns success. The completion handler reports no error. The view has the correct size and position. There is no log, no crash, no indication that a subprocess is involved or failing. The only symptom is that nothing renders.


---

## NSTextField cursor (insertion point) invisible on programmatic focus of empty field

**Stack:** AppKit, NSTextField, Objective-C
**Symptom:** NSTextField is the first responder, receives keystrokes correctly (text appears), but shows no blinking cursor. After pressing Enter once, the cursor appears and continues working.
**Context:** NSTextField made first responder programmatically (via `makeFirstResponder:`) before or shortly after `[NSApp run]` starts, when the field is empty.

### What was tried (didn't work)
- `[window makeFirstResponder:field]` called before `[NSApp run]` — cursor not visible
- `window.initialFirstResponder = field` — cursor not visible (window was already key, so AppKit ignored this)
- `[editor updateInsertionPointStateAndRestartTimer:YES]` via `dispatch_after` — dispatch block never ran (see GCD serialisation gotcha)
- No-op string assignment via `dispatch_after` — never ran
- `[window makeFirstResponder:field]` in `windowDidBecomeKey:` without the string trick — cursor not visible

### Root cause
Documented AppKit bug. When an empty NSTextField gains first responder programmatically, the field editor is installed (keystrokes work) but the insertion-point blink timer is never started. The cursor exists; it simply doesn't animate and isn't drawn. After Enter, the field transitions through a non-empty editing state, which triggers a full re-focus cycle that starts the timer.

### Fix
In `windowDidBecomeKey:` (NOT in a dispatch block — see GCD gotcha), call `makeFirstResponder:` AND perform a no-op string assignment to tickle the field editor:

```objc
@property (nonatomic, weak) NSTextField *inputField;

- (void)windowDidBecomeKey:(NSNotification *)notification {
    if (self.inputField) {
        NSWindow *w = notification.object;
        [w makeFirstResponder:self.inputField];
        [self.inputField setStringValue:@" "]; // tickle blink timer
        [self.inputField setStringValue:@""];  // clear immediately
        self.inputField = nil; // run once only
    }
}
```

`windowDidBecomeKey:` is used because it fires inside the run loop — where GCD dispatch is blocked (see GCD gotcha above), AppKit delegates work correctly.

### Why this is non-obvious
The field editor IS active (keystrokes work). The window IS key. The field IS first responder. Every observable indicator says it should be working. Only the blink timer is missing, and there's no API to check whether the blink timer is running.


---

## NSTextField placeholder invisible on dark background

**Stack:** AppKit, NSTextField, Objective-C
**Symptom:** `inputField.placeholderString = @"Type here..."` renders text that is near-invisible against a dark background.
**Context:** Any dark-themed UI using NSTextField's built-in placeholder.

### What was tried (didn't work)
- Setting `placeholderString` — uses system semi-transparent grey, invisible on dark bg

### Root cause
The system placeholder colour is a semi-transparent grey calibrated for light backgrounds. On dark backgrounds it becomes near-invisible.

### Fix
Use `placeholderAttributedString` with explicit colour:

```objc
inputField.placeholderAttributedString = [[NSAttributedString alloc]
    initWithString:@"Type here…"
        attributes:@{ NSForegroundColorAttributeName:
            [NSColor colorWithRed:0.50 green:0.50 blue:0.50 alpha:1.0] }];
```

### Why this is non-obvious
`placeholderString` appears to work (text is there) — it's just invisible. There's no indication the colour needs to be set separately.


---

## NSSplitView as contentView blocks keyboard events to NSTextField subviews

**Stack:** AppKit, NSSplitView, NSTextField, Objective-C
**Symptom:** NSTextField inside NSSplitView which is set as `window.contentView` receives no keyboard input, even after `makeFirstResponder:`. Clicking the field does nothing. Mouse events also don't reach it.
**Context:** Using NSSplitView as the root container by replacing `window.contentView`.

### Root cause
This is a specific manifestation of the "replacing contentView breaks routing" gotcha above. NSSplitView is particularly aggressive — it blocks both mouse AND keyboard events to all subviews, not just keyboard.

### Fix
See "Replacing window.contentView silently breaks all keyboard and mouse event routing" above. Add NSSplitView as a subview of the existing contentView, or replace the layout with manual `addSubview:` calls.

### Why this is non-obvious
NSSplitView is the canonical AppKit control for split-pane layouts. Using it as the contentView seems like exactly the right thing to do. The layout renders correctly. Only events are silently swallowed.


---

## PTY master reads every line twice — line discipline ECHO is on by default

**Stack:** POSIX PTY, macOS, Java Panama FFM
**Symptom:** Every line of subprocess output appears twice in the PTY reader. `/bin/cat` with input `hello` produces two `hello` lines. No error anywhere.
**Context:** Any PTY-based subprocess where the parent writes to the master fd and the subprocess echoes to stdout. Happens regardless of language or how the PTY was opened.

### What was tried (didn't work)
- Assumed the double output was the subprocess echoing input itself (it isn't — `cat` only echoes stdout, not stdin)
- Checked read loop for off-by-one / double-read — no issue there

### Root cause
The PTY line discipline has `ECHO` enabled by default. When you write bytes to the master fd (simulating keyboard input), the kernel's line discipline echoes those bytes back to the master fd immediately — before the subprocess even sees them. So for input `hello\n`:
1. Parent writes `hello\n` to master → line discipline echoes `hello\r\n` back to master (ECHO)
2. Subprocess reads `hello\n` from slave stdin, writes `hello\n` to stdout → comes back through master as `hello\r\n`

The reader sees it twice. No error. Both copies look identical.

### Fix
Call `tcgetattr` on the master fd after opening, clear the `ECHO` bit in `c_lflag`, call `tcsetattr` back:

```java
// struct termios (macOS AArch64): c_iflag(8) + c_oflag(8) + c_cflag(8) + c_lflag(8) + c_cc[20]
// c_lflag is at byte offset 24. ECHO = 0x00000008L
try (Arena temp = Arena.ofConfined()) {
    MemorySegment termios = temp.allocate(64); // 52 bytes needed
    if (PosixLibrary.tcgetattr(masterFd, termios) == 0) {
        long lflag = termios.get(ValueLayout.JAVA_LONG, 24);
        lflag &= ~0x00000008L; // clear ECHO
        termios.set(ValueLayout.JAVA_LONG, 24, lflag);
        PosixLibrary.tcsetattr(masterFd, 0 /* TCSANOW */, termios);
    }
}
```

On macOS AArch64: `tcflag_t` = `unsigned long` = 8 bytes. `c_lflag` is the 4th field, offset = 3 × 8 = 24. `ECHO` = bit 3 = `0x00000008`.

### Why this is non-obvious
The ECHO setting is on the master fd but the effect is felt by the reader of the master. Developers expect the subprocess's stdout to produce output — they don't expect the kernel to independently echo their writes back to them. The symptom (doubled output) looks like a bug in the read loop or the subprocess itself.
