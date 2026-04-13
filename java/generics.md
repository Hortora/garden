# Java Generics Gotchas

---


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
