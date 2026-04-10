# Java Records Gotchas

---

## Java records with `List<T>` fields are not truly immutable without a compact constructor

**ID:** GE-0023
**Stack:** Java 16+ (records, all versions)
**Symptom:** A record is treated as immutable because records make field references final. However, a caller that retains the original `ArrayList` before passing it to the record constructor can mutate the backing list after construction, silently corrupting the record's state.
**Context:** Any Java record that accepts a `List`, `Set`, or `Map` as a constructor parameter and is expected to be immutable.

### What was tried (didn't work)
- Declared the field as `List<T>` (final by record semantics) — makes the reference immutable but not the list contents
- Relied on the caller to pass unmodifiable lists — not enforced; no compile-time or runtime guard

### Root cause
Java records automatically make field references final (immutable reference), but they do not defensively copy the passed-in collection. The record stores whatever reference was passed to it. If the caller still holds the original mutable collection, they can call `list.add(...)` and the record's field reflects the change immediately.

### Fix

Add a compact constructor that wraps all collection fields with `List.copyOf()`:

```java
public record GameState(
    int minerals,
    int vespene,
    List<Unit> myUnits,
    List<Building> myBuildings,
    List<Unit> enemyUnits,
    long gameFrame
) {
    // Compact constructor — called before fields are assigned
    public GameState {
        myUnits     = List.copyOf(myUnits);      // defensive copy + unmodifiable
        myBuildings = List.copyOf(myBuildings);
        enemyUnits  = List.copyOf(enemyUnits);
    }
}
```

`List.copyOf()` also rejects null elements, providing an extra safety net. Passing an already-unmodifiable list (e.g. `List.of(...)`) to `List.copyOf()` is a no-op — no performance cost.

### Why this is non-obvious
Records are marketed as immutable value types. Developers familiar with Kotlin data classes or Scala case classes (which do copy semantics by default for standard collections) assume Java records behave similarly. The distinction between "immutable reference" and "immutable content" is subtle and easy to miss in a code review, especially for developers coming from database or UI patterns rather than concurrent data structures.

*Score: 11/15 · Included because: very common misconception about records; the fix is a one-liner compact constructor but the problem is not obvious until someone mutates a "immutable" record externally · Reservation: technically documented in JEP 395; experienced Java devs may already know this*

## Use `mvn compile` to enumerate all call sites when changing a Java record signature

**ID:** GE-0158
**Stack:** Java 21, Maven, any IDE
**Labels:** `#refactoring` `#java`

**Technique:** When adding fields to a Java record, run `mvn compile` immediately after the record change (before fixing any callers). The compiler generates one error per call site with the exact file and line. Work through the error list systematically. This is more reliable than grep, handles generated code, inner lambdas, and stream expressions that grep misses.

**What developers normally do:** Grep for `new Unit(` or similar, update what they find, then discover they missed three more at compile time.

### The approach

1. Change the record definition:
```java
// Before:
public record Unit(String tag, UnitType type, Point2d position, int health, int maxHealth) {}

// After:
public record Unit(String tag, UnitType type, Point2d position,
                   int health, int maxHealth,
                   int shields, int maxShields) {}
```

2. Immediately compile:
```bash
mvn compile 2>&1 | grep "error:" | grep -o "\.java:[0-9]*" | sort | uniq -c | sort -rn
```

3. Work the list. The compiler tells you the exact line. Fix each site with the new field values.

**Key insight for immutable records replacing themselves:** Any method that creates a new record from an existing one (e.g. inside `List.replaceAll()`) must carry ALL fields through, including new ones. Missing `u.shields()` in such a replacement silently resets the field to its default on every invocation:

```java
// WRONG — shields reset to 0 on every tick
myUnits.replaceAll(u -> new Unit(u.tag(), u.type(), newPos, u.health(), u.maxHealth()));

// RIGHT — carry shields through
myUnits.replaceAll(u -> new Unit(u.tag(), u.type(), newPos, u.health(), u.maxHealth(),
    u.shields(), u.maxShields()));
```

The compiler catches the arity mismatch at the call site, but not the semantic error of using `0` instead of `u.shields()` — the dangerous case is `new Unit(..., 0, 0)` which compiles but loses the field state.

*Score: 10/15 · Included because: replaceAll-with-new-record silent data loss is genuinely non-obvious; compiler-as-enumerator is a useful technique that most developers don't think to use · Reservation: the basic technique is documented; the replaceAll silent-loss warning is the novel part*

---
