**Submission ID:** GE-0145
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** gotcha
**Stack:** Playwright Java 1.49.0

## Playwright Java: `waitForFunction(String, WaitForFunctionOptions)` silently serialises options as JS arg

**Symptom:** `PlaywrightException: Unsupported type of argument: com.microsoft.playwright.Page$WaitForFunctionOptions@...` at runtime. No compile error. The stack trace points into Playwright's internal serialisation, not to the call site.

**Context:** Occurs when calling `page.waitForFunction(expression, options)` with two arguments — the expression string and a `WaitForFunctionOptions` object — intending to set a timeout. The method signature appears to accept this form.

**What was tried:** Passing `new Page.WaitForFunctionOptions().setTimeout(5_000)` as the second argument. Looked correct given the Python API shape.

**Root cause:** Playwright Java's `waitForFunction` overloads are:
- `waitForFunction(String expression)`
- `waitForFunction(String expression, Object arg)`
- `waitForFunction(String expression, Object arg, WaitForFunctionOptions options)`

There is **no** `waitForFunction(String, WaitForFunctionOptions)` overload. The two-arg call matches `(String, Object)` — treating the options object as the JavaScript argument to pass to the function — and Playwright then tries to serialise `WaitForFunctionOptions` as JSON, which fails.

**Fix:** Always pass `null` as the arg when no JS argument is needed:

```java
// WRONG — WaitForFunctionOptions becomes the JS arg
page.waitForFunction(
    "() => window.__test !== undefined",
    new Page.WaitForFunctionOptions().setTimeout(10_000));

// FIX — null as explicit no-arg, options as third parameter
page.waitForFunction(
    "() => window.__test !== undefined",
    null,
    new Page.WaitForFunctionOptions().setTimeout(10_000));
```

**Why non-obvious:** The Python Playwright API accepts `timeout` as a keyword argument directly. Java's overload resolution silently selects the wrong overload. The error message mentions internal serialisation — nothing points to the call site or the missing `null`.

**Suggested target:** `tools/playwright.md`

*Score: 12/15 · Included because: wrong overload resolved silently, error message completely misleading, Java-specific trap for Python Playwright users · Reservation: none*
