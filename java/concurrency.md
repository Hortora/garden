# Java Concurrency Gotchas

---

## Multiple `volatile` fields read without synchronisation produce torn cross-field snapshots

**ID:** GE-0024
**Stack:** Java (all versions with volatile and multi-threading)
**Symptom:** A class with multiple related `volatile` fields reads them in sequence inside a `snapshot()` method. Each individual read is safe, but the group is not atomic — a concurrent mutator can modify one field between two reads, producing an internally inconsistent snapshot. No exception, no error; the returned object contains values from two different points in time.
**Context:** Any class that exposes a snapshot/copy of several related fields as a single value object, where multiple fields are updated atomically by a mutating method.

### What was tried (didn't work)
- Declared all scalar fields `volatile` — correctly ensures visibility of individual writes but does not make multi-field reads atomic
- Relied on `CopyOnWriteArrayList` for the list fields — correct for the list contents, but the volatile scalar reads surrounding it are still not grouped atomically

### Root cause
`volatile` provides visibility and ordering guarantees for a single field, not for a group of reads. The Java Memory Model treats each volatile read/write independently. Between the read of `minerals` and the read of `supplyUsed`, another thread can call `tick()`, increment `gameFrame`, and adjust `supplyUsed` — the snapshot sees `minerals` from before the tick and `supplyUsed` from after it.

### Fix

```java
// WRONG — five separate volatile reads, not atomic
public GameState snapshot() {
    return new GameState(minerals, vespene, supply, supplyUsed,
        List.copyOf(myUnits), List.copyOf(myBuildings),
        List.copyOf(enemyUnits), gameFrame.get());
}

// CORRECT — synchronized groups all reads into one critical section
public synchronized GameState snapshot() {
    return new GameState(minerals, vespene, supply, supplyUsed,
        List.copyOf(myUnits), List.copyOf(myBuildings),
        List.copyOf(enemyUnits), gameFrame.get());
}
```

Alternative if snapshot performance is critical: use a single `AtomicReference<GameState>` updated atomically by all mutators, eliminating the snapshot method entirely.

### Why this is non-obvious
The `volatile` keyword feels like it should be sufficient — each field is individually safe. The subtlety is that "each field is safe" ≠ "reading multiple fields together is safe." Code reviews focus on whether mutations are guarded; the read side is easy to overlook because it doesn't modify anything. Unit tests run single-threaded and never catch it; the bug only manifests under real concurrency.

*Score: 14/15 · Included because: one of the most common Java concurrency mistakes; individually correct volatile fields give false sense of thread safety for grouped reads; symptom can be extremely difficult to reproduce · Reservation: none identified*

---

## `synchronized(key.intern())` causes JVM-wide global pool contention across unrelated instances

**ID:** GE-0139
**Stack:** Java 21 (all versions)
**Symptom:** Per-key locking in a `ConcurrentHashMap`-backed store appears correct and passes all tests. Under production load, unrelated instances (different map objects) serialise unexpectedly. No error, warning, or lock timeout — just hidden throughput degradation.

### Root cause
`String.intern()` returns a canonical String from the JVM's global intern pool. Calling `synchronized(key.intern())` does not lock "this key in this map" — it locks the *globally shared* interned string object. Any two threads in any two instances that use the same key string (e.g. `"status"`, `"result"`, `"data"`) compete for the same lock across the entire JVM. The JVM provides no warning; the code looks correct; tests pass because test-level concurrency is rarely high enough to exhibit the contention.

### Fix
Use `ConcurrentHashMap<String, AtomicReference<V>>` with a CAS loop for lock-free per-key versioning:

```java
private final ConcurrentHashMap<String, AtomicReference<ValueEntry>> store
    = new ConcurrentHashMap<>();

public void putIfVersion(String key, Object value, long expectedVersion)
        throws StaleVersionException {
    AtomicReference<ValueEntry> ref = store.computeIfAbsent(
        key, k -> new AtomicReference<>());
    ValueEntry current;
    do {
        current = ref.get();
        long currentVer = current != null ? current.version() : 0L;
        if (currentVer != expectedVersion) {
            throw new StaleVersionException(key, expectedVersion, currentVer);
        }
    } while (!ref.compareAndSet(current,
        new ValueEntry(value, nextVersion())));
}
```

### Why non-obvious
`String.intern()` is often taught as a "safe" way to get a canonical object for synchronisation on string keys. The cross-instance scope of the lock is not mentioned in most Java concurrency resources. The pattern breaks silently — tests pass, production degrades.

*Score: 13/15 · Included because: extremely non-obvious, silent failure, high pain in production, affects any Java developer using string-keyed locking · Reservation: none*
