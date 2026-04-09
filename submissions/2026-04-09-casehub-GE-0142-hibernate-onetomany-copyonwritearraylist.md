**Type:** gotcha
**Submission ID:** GE-0142
**Date:** 2026-04-09
**Project:** casehub
**Stack:** Hibernate ORM 6.x, Quarkus 3.17.5 (likely all Hibernate 6.x versions)
**Scanned against:** no existing Hibernate collection gotchas in index

## Hibernate @OneToMany Collections Must Be Initialized with ArrayList, Not CopyOnWriteArrayList

**Symptom:** Unit tests pass. Integration tests that load the entity from the database fail — the `@OneToMany` collection either throws an unexpected exception or behaves as if empty when accessed outside the entity's loading context.

**Root cause:** Hibernate replaces field-initialized collections with its own `PersistentBag` (or `PersistentList`) proxy at load time. This replacement works reliably for `java.util.ArrayList` initializers. When the field is initialized with `CopyOnWriteArrayList`, Hibernate may not reliably recognize it as a replaceable collection — the proxy wrapping can silently fail or behave incorrectly. Unit tests never expose this because Hibernate does not load the entity from the database during unit tests; it only affects database round-trips.

**Fix:** Always initialize `@OneToMany` and `@ManyToMany` fields with `new ArrayList<>()`:

```java
// Wrong — passes unit tests, fails integration tests
@OneToMany(mappedBy = "parentTask", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
private List<HibernateTask> childTasks = new CopyOnWriteArrayList<>();

// Correct
@OneToMany(mappedBy = "parentTask", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
private List<HibernateTask> childTasks = new ArrayList<>();
```

If thread-safety on the collection is needed at the application layer, wrap on access: `Collections.synchronizedList(entity.getChildTasks())` — but do not use `CopyOnWriteArrayList` as the field initializer.

**Why non-obvious:** `CopyOnWriteArrayList` implements `List` and is a perfectly valid Java collection. Nothing in Hibernate ORM documentation, Quarkus documentation, or the `@OneToMany` Javadoc warns against using non-standard `List` implementations as field initializers. The failure is invisible in unit tests and only surfaces when entities are actually persisted and fetched from a real database.

**Suggested target:** `quarkus/panache.md` (same file as GE-0138, or `java/hibernate.md` as a new file)

*Score: 12/15 · Included because: silent failure, unit tests pass masking the bug, nothing in any documentation warns about this constraint · Reservation: somewhat specific to teams that use CopyOnWriteArrayList for thread safety in entities*
