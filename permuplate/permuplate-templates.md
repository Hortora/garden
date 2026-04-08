# Permuplate Template Gotchas and Undocumented Features

---

## @PermuteReturn methods with hand-written return types silently disappear via boundary omission

**ID:** GE-0005
**Stack:** Permuplate (any version), Maven plugin inline mode
**Symptom:** Methods annotated with `@PermuteReturn(className = "Path2")` (where `Path2` is a hand-written class) are completely absent from the generated output. No error, no warning — the method simply doesn't appear.
**Context:** Any `@Permute` template that uses a hand-written (non-generated) class as the return type via `@PermuteReturn.className`. Boundary omission checks whether the className is in the generated-class set; hand-written classes are never in that set, so the method is omitted on every arity.

### What was tried (didn't work)
- Added `path2()..path6()` methods with `@PermuteReturn(className = "Path2", typeArgs = "...")` — no methods appeared in generated output, no compilation error
- Verified template was parsed correctly — the method existed in the template, generated class did not have it

### Root cause

Permuplate's boundary omission logic checks whether `@PermuteReturn.className` is in the set of class names generated from all `@Permute` annotations in the current parent file. Hand-written classes (like `Path2`, `NegationScope`, etc.) are never in this set. The method is therefore treated as "would reference a non-existent generated class" and silently removed.

The `when` attribute is evaluated as a JEXL expression and compared to the string `"true"`. When it evaluates to `"true"`, boundary omission is overridden and the method is kept regardless of whether the class is in the generated set.

### Fix

Use `when` with a JEXL condition expression to override boundary omission selectively:

```java
// WRONG: hand-written Path2 not in generated set → method silently removed on all arities
@PermuteReturn(className = "Path2", typeArgs = "...")
public <B> Object path2() { ... }

// CORRECT: when="true" overrides boundary omission entirely
@PermuteReturn(className = "Path2", typeArgs = "...", when = "true")
public <B> Object path2() { ... }

// BEST: when="i < 6" keeps method for i=1..5 but allows boundary omission at i=6
// (where you genuinely don't want the method because Join7First doesn't exist)
@PermuteReturn(className = "Path2", typeArgs = "...", when = "i < 6")
public <B> Object path2() { ... }
```

The JEXL expression `i < 6` evaluates to boolean `true` for i=1..5 → compared to string "true" → overrides boundary omission. For i=6 it evaluates to `false` → boundary omission fires → method removed.

### Why this is non-obvious

The boundary omission feature is designed to handle leaf nodes (e.g., `Join6First` has no `join()` because `Join7First` doesn't exist). It makes sense for generated classes. The non-obvious part: it also fires for hand-written classes, silently. A developer adding `@PermuteReturn(className = "MyHandWrittenClass")` would reasonably expect the method to appear since `MyHandWrittenClass` clearly exists — but it disappears because the set check is against *generated* classes only.

*Score: 12/15 · Included because: silent method disappearance with no error; boundary omission's scope (generated classes only) is invisible from the API surface · Reservation: extremely narrow audience — only Permuplate template authors mixing hand-written return types*

---

## typeArgList(from, to, style) accepts dynamic JEXL expressions for from/to, not just constants

**ID:** GE-0007
**Stack:** Permuplate (any version), Apache Commons JEXL3
**What it is:** The built-in `typeArgList(from, to, style)` function in Permuplate's JEXL evaluation context accepts any JEXL expression for `from` and `to`, including variables and arithmetic. This enables generating Tuple type argument sequences of arbitrary depth from a single template method.
**How discovered:** Trial and implementation during OOPath design — needed `Tuple3<A,B,C>` for path3(), `Tuple4<A,B,C,D>` for path4() etc. at any outer arity `i`.

### Description

`typeArgList(from, to, style)` generates a comma-separated list of type argument names:
- `typeArgList(1, 3, 'alpha')` → `"A, B, C"`
- `typeArgList(1, 3, 'T')` → `"T1, T2, T3"`

The `from` and `to` parameters are evaluated as JEXL expressions. Since the outer loop variable `i` is always in scope, arithmetic expressions work:

- `typeArgList(i, i+2, 'alpha')` → for i=1: `"A, B, C"`, for i=2: `"B, C, D"`
- `typeArgList(1, i, 'alpha')` → for i=1: `"A"`, for i=3: `"A, B, C"` (existing outer facts)

### How to use it

In a `@PermuteReturn typeArgs` expression for a method that returns a PathN-style type:

```java
// path3() on JoinNSecond: returns Path3 with Tuple3 content
@PermuteReturn(
    className = "Path3",
    typeArgs = "'Join' + (i+1) + 'First<END, DS, '"
             + " + typeArgList(1, i, 'alpha') + ', Tuple3<'"    // existing outer facts
             + " + typeArgList(i, i+2, 'alpha') + '>>, Tuple2<' // Tuple3 content
             + " + typeArgList(i, i+1, 'alpha') + '>, '"        // current tuple
             + " + typeArgList(i, i+2, 'alpha')",                // Path3 type params
    when = "i < 6")
public <B> Object path3() { ... }
```

Without dynamic from/to, you would need a separate method per depth × arity combination — 5 depths × 6 arities = 30 static expressions instead of 5 parameterised ones.

### Why it's not obvious

The `typeArgList` function is documented as accepting integer arguments. There is no documentation stating these integers can be JEXL expressions. Most users would assume `from` and `to` are compile-time constants and hardcode them. The key insight: JEXL evaluates all arguments before calling the function, so passing `i+2` is exactly the same as passing a constant `3` when `i=1`. The function itself never knows the difference.

### Caveats
- `from` and `to` must evaluate to integers within the 1–26 range (alpha style)
- Out-of-range values throw at generation time with a JEXL evaluation error

*Score: 10/15 · Included because: combinatorial reduction (30 → 5 expressions) demonstrates clear value; insight generalises to any JEXL-based template engine · Reservation: extremely narrow audience (Permuplate + specific typeArgList usage)*
