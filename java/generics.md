# Java Generics Gotchas

---

## Lambda return type checks assignment compatibility — `DataSource<Account>` IS compatible with `Function<DS, DataSource<?>>` target despite generic invariance

**Stack:** Java (all versions with lambda expressions, JLS §15.27.3)
**Symptom:** You expect `ctx -> ctx.accounts()` (where `ctx.accounts()` returns `DataSource<Account>`) to fail compilation against `Function<DS, DataSource<?>>` due to generic invariance. It compiles cleanly.
**Context:** Any method parameter typed as `Function<T, Container<?>>` where callers pass lambdas returning `Container<ConcreteType>`. Discovered when typing `NegationScope.join(Function<DS, DataSource<?>> source)` to avoid `Object`.

### What was tried
- Used `Object` as parameter type (first instinct, assuming the typed version would fail) — result: compiled, but required an ugly double-cast at every call site:
  ```java
  scope.join((Object)(java.util.function.Function<Ctx, DataSource<Account>>) ctx -> ctx.accounts())
  ```
- Thought `Function<DS, DataSource<Account>>` is not a subtype of `Function<DS, DataSource<?>>` (generic invariance) → assumed the lambda would need to match exactly → used `Object` to avoid the type error

### Root cause

Java uses **two different compatibility rules** depending on context:

1. **Subtype compatibility (for variables/assignments):** `Function<DS, DataSource<Account>>` is NOT a subtype of `Function<DS, DataSource<?>>`. Generic type parameters are invariant: `List<String>` ≠ `List<?>`. This is the mental model most developers apply.

2. **Lambda return type checking (JLS §15.27.3):** When checking whether a lambda matches a functional interface target type, Java checks whether the lambda's **return expression** is *assignment-compatible* with the target's return type. `DataSource<Account>` IS assignment-compatible with `DataSource<?>` (wildcard capture allows any type argument). So the lambda compiles.

The key distinction: `Function<DS, DataSource<Account>>` ≠ `Function<DS, DataSource<?>>` as types — but `ctx -> ctx.accounts()` as a lambda expression IS compatible with `Function<DS, DataSource<?>>` as a target type. The lambda doesn't have a fixed type until inference resolves it.

### Fix

Use the wildcard parameterised type in the method signature — lambdas work directly:

```java
// Uses Object — requires ugly double-cast at call sites:
public NegationScope<OUTER, DS> join(Object source) { ... }
// Call site: scope.join((Object)(Function<Ctx, DataSource<Account>>) ctx -> ctx.accounts())

// Uses wildcard — clean lambda at call sites:
public NegationScope<OUTER, DS> join(java.util.function.Function<DS, DataSource<?>> source) { ... }
// Call site: scope.join(ctx -> ctx.accounts())  ← compiles cleanly
```

`filter(Object)` stays as `Object` when predicates have varying arities (no common typed interface).

### Why this is non-obvious

The mental model — "generics are invariant → `Function<DS, DataSource<Account>>` ≠ `Function<DS, DataSource<?>>` → lambda fails" — is correct about generic subtype relationships but wrong about lambda target type checking. JLS §15.27.3 uses assignment compatibility for the return type check, which follows different rules. Most developers learn the invariance rule from `List<String>` ≠ `List<Object>` and apply it universally, not realising lambdas use a distinct resolution path where wildcard return types accept any concrete parameterisation of the wildcard argument.

---

## Use typed element return in generator/predicate pairs to enforce cross-API type agreement

**ID:** GE-0004
**Stack:** Java (all versions with generics)
**Labels:** `#java-dsl`
**What it achieves:** The compiler enforces that a traversal function and its accompanying filter predicate agree on the element type — preventing silent type mismatches that would only surface at runtime.
**Context:** Any API with a paired (generator function, filter predicate) where both operate on the same element type. Common in builder DSLs, pipeline APIs, traversal frameworks.

### The technique

When a method accepts both a generator and a predicate, use a shared type parameter in the generator's return type instead of a wildcard:

```java
// WRONG: wildcard — compiler can't enforce agreement between fn2 and flt2
public <END, T, A, B> END path(
        Function2<PathContext<T>, A, Iterable<?>> fn2,   // returns any Iterable
        Predicate2<PathContext<T>, B>             flt2)  // tests B — could be different type!
{ ... }

// RIGHT: typed return — compiler enforces fn2 produces Iterable<B>, flt2 tests B
public <END, T, A, B> END path(
        Function2<PathContext<T>, A, Iterable<B>> fn2,   // must return Iterable<B>
        Predicate2<PathContext<T>, B>             flt2)  // tests the same B
{ ... }
```

With the typed version, this compiles:
```java
.path(
    (ctx, room) -> room.books(),       // returns List<Book> — B inferred as Book
    (ctx, book) -> book.published())   // Book matches B — OK
```

But this fails at compile time (catching a real bug):
```java
.path(
    (ctx, room) -> room.books(),       // returns List<Book> — B inferred as Book
    (ctx, shelf) -> shelf.level() > 0) // Shelf != Book — COMPILE ERROR
```

With `Iterable<?>`, the second example compiles silently and fails only at runtime.

### Why this is non-obvious

The instinct when building an API that immediately erases the element type (consuming the `Iterable<?>` as `Object[]`) is to use wildcard: "I'm going to erase it anyway, why bother?" The insight is that the type parameter `B` doesn't need to persist *into* the implementation — it only needs to exist *at the call site* to enforce agreement between the two lambda arguments. The implementation can cast `(B)` internally with `@SuppressWarnings`. The type safety is in the API shape, not the implementation.

### When to use it
- Any method that accepts `(generator, predicate)` as a pair where both should agree on element type
- Builder DSLs with chained (traversal function, filter) steps
- Pipeline APIs where you generate elements and immediately filter them

Limitation: only works when both arguments use the same type variable in the same method call. If generator and predicate are in separate method calls, the type variable goes out of scope.

*Score: 11/15 · Included because: "type parameter only needs to exist at the call site, not persist into the implementation" is a compact, reusable principle · Reservation: experienced Java generics practitioners will recognise this pattern; may be too niche for developers who don't write DSL-style APIs*
