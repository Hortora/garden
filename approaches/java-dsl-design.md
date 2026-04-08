# Java DSL Design Approaches

---

## Varargs type-capture for type-safe DSL methods with full generic support

**Context:** Designing fluent DSL methods that need to return a caller-specified
type without requiring the caller to pass a `Class<T>` argument — especially when
the target type may include nested generics like `Map<String, Map<String, Date>>`.

**Applies to:** Any Java DSL or API where methods project, narrow, or construct
instances of a caller-determined type. Common in rule engines, ORM mappers,
serialisation frameworks, and typed builder APIs.

### The approach

Declare the method with a varargs parameter of the return type `T`:

```java
@SuppressWarnings({"unchecked", "varargs"})
public <T> T as(T... v) {
    Class<T> clazz = (Class<T>) v.getClass().getComponentType();
    // use clazz to construct or cast the result
    return (T) construct(clazz);
}
```

The caller passes **no arguments** but provides the type either via assignment
context or an explicit type witness:

```java
// Type inferred from assignment — works with full nested generics
Map<String, Map<String, Date>> result = tuple.as();

// Or with explicit type witness
MyRecord r = tuple.<MyRecord>as();
```

Java infers `T` from the assignment target, then creates a zero-length `T[]` for
the empty varargs call. `v.getClass().getComponentType()` returns the erased raw
class (`Map.class`), which is sufficient for construction.

### Why Class<T> doesn't work for nested generics

```java
// This compiles but loses generic info — all you get is Map.class
public <T> T as(Class<T> cls) { ... }

// Callers cannot write this — it's a compile error:
Map<String, Map<String, Date>> result = tuple.as(Map<String, Map<String, Date>>.class);

// They must write this ugly, unsafe alternative:
Map<String, Map<String, Date>> result = tuple.as((Class) Map.class);
```

With the varargs approach, `Map<String, Map<String, Date>> result = tuple.as()` is
fully type-checked at the call site — the compiler verifies the assignment is
consistent with the inferred `T`. The runtime erasure to `Map.class` is acceptable
because construction only needs the raw class.

### Implementation variants

**Projection to record/class (as() pattern):**
```java
public <T> T as(T... v) {
    Class<T> clazz = (Class<T>) v.getClass().getComponentType();
    // find matching constructor, call with tuple values in order
    for (Constructor<?> ctor : clazz.getDeclaredConstructors()) {
        if (ctor.getParameterCount() == size()) {
            return (T) ctor.newInstance(collectValues());
        }
    }
    throw new IllegalArgumentException("No matching constructor on " + clazz);
}
```

**Type narrowing no-op (type() pattern):**
```java
public <T> Object type(T... cls) {
    return cast(this);  // runtime no-op — just compile-time narrowing
}
```

**Type-marker with stored class (params() pattern):**
```java
public <T> ChainBuilder<T> params(T... cls) {
    this.paramsClass = (Class<T>) cls.getClass().getComponentType();
    return new ChainBuilder<>(this);
}
```

### Real-world usage in the Drools DSL sandbox

The sandbox uses this pattern in three places:
- `BaseTuple.as()` — projects OOPath tuple results into typed records
- `Join0Second.type()` — compile-time type narrowing for untyped DataSources
- `ParametersFirst.params()` — captures the rule params type for the join chain

### Why a skilled developer might not find this naturally

The instinctive design is `<T> T method(Class<T> cls)`, which works for simple
types but silently fails for nested generics — the caller is forced to use raw
casts. The varargs trick is non-obvious because it appears to "do nothing" at the
call site (no arguments passed), and the `@SuppressWarnings("varargs")` suppresses
the IDE warning about heap pollution that would otherwise draw attention to the
unusual usage. The key insight is that the varargs array creation — not the array
contents — is the mechanism that carries type information.
