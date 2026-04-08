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
