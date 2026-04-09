**Type:** gotcha
**Submission ID:** GE-0139
**Date:** 2026-04-09
**Project:** casehub
**Stack:** Java 21 (all versions)
**Scanned against:** GE-0024 (volatile fields, distinct), GE-0023 (records immutability, distinct)

## synchronized(key.intern()) Causes Cross-Instance JVM Global Pool Contention

**Symptom:** Per-key locking in a `ConcurrentHashMap`-backed store appears correct and passes all tests. Under production load, unrelated instances (different map objects) serialise unexpectedly. No error, warning, or lock timeout — just hidden throughput degradation.

**Root cause:** `String.intern()` returns a canonical String from the JVM's global intern pool. Calling `synchronized(key.intern())` does not lock "this key in this map" — it locks the *globally shared* interned string object. Any two threads in any two instances that happen to use the same key string (e.g. `"status"`, `"result"`, `"data"`) compete for the same lock across the entire JVM. The JVM provides no warning; the code looks correct; tests pass because test-level concurrency is rarely high enough to exhibit the contention.

**Fix:** Use `ConcurrentHashMap<String, AtomicReference<V>>` with a CAS loop for lock-free per-key versioning:

```java
// Instead of: ConcurrentHashMap<String, ValueEntry>
private final ConcurrentHashMap<String, AtomicReference<ValueEntry>> store
    = new ConcurrentHashMap<>();

// putIfVersion — lock-free per-key optimistic update
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

**Why non-obvious:** `String.intern()` is often taught as a "safe" way to get a canonical object for synchronisation on string keys. The cross-instance scope of the lock is not mentioned in most Java concurrency resources. The pattern breaks silently — tests pass, production degrades.

**Suggested target:** `java/concurrency.md`

*Score: 13/15 · Included because: extremely non-obvious, silent failure, high pain in production, affects any Java developer using string-keyed locking · Reservation: none*
