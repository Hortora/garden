# Quarkus / Panache Gotchas

---

## `PanacheRepositoryBase.findById()` return type blocks SPI interface implementation

**ID:** GE-0138
**Stack:** Quarkus 3.17.5, Hibernate ORM with Panache
**Symptom:** Compiler rejects a class that extends `PanacheRepositoryBase<HibernateCaseFile, Long>` and also implements a custom SPI interface declaring `findById(Long): Optional<CaseFile>`. Error looks like a method signature conflict.

### Root cause
`PanacheRepositoryBase<E, ID>` declares `findById(ID id): Optional<E>`. When `E = HibernateCaseFile` and the SPI declares `findById(Long): Optional<CaseFile>`, Java sees two `findById(Long)` methods with different return types (`Optional<HibernateCaseFile>` vs `Optional<CaseFile>`). Even though `HibernateCaseFile implements CaseFile`, Java's type system does not allow a method to satisfy both return types simultaneously — covariant return types work for concrete classes but not for generic type parameters resolved at class declaration.

### Fix
Drop `PanacheRepositoryBase` entirely. Inject `EntityManager` directly and use JPQL queries:

```java
@ApplicationScoped
public class HibernateCaseFileRepository implements CaseFileRepository {

    @Inject EntityManager em;

    @Override
    @Transactional
    public Optional<CaseFile> findById(Long id) {
        return Optional.ofNullable(em.find(HibernateCaseFile.class, id));
    }

    @Override
    public List<CaseFile> findByStatus(CaseStatus status) {
        return em.createQuery(
            "SELECT cf FROM HibernateCaseFile cf WHERE cf.status = :s",
            HibernateCaseFile.class)
            .setParameter("s", status)
            .getResultList()
            .stream().map(cf -> (CaseFile) cf).toList();
    }
}
```

### Why non-obvious
The error message looks like a duplicate method conflict, not a generics incompatibility. The obvious fix (casting or a bridge method) doesn't work. Nothing in Quarkus or Panache docs warns that `PanacheRepositoryBase` is incompatible with SPI-based repository interfaces.

*Score: 12/15 · Included because: non-obvious, cryptic error, high pain, relevant to any team building SPI abstractions over Panache · Reservation: somewhat niche (SPI + Panache combination)*

---

## Hibernate `@OneToMany` collections must be initialized with `ArrayList`, not `CopyOnWriteArrayList`

**ID:** GE-0142
**Stack:** Hibernate ORM 6.x, Quarkus 3.17.5 (likely all Hibernate 6.x versions)
**Symptom:** Unit tests pass. Integration tests that load the entity from the database fail — the `@OneToMany` collection either throws an unexpected exception or behaves as if empty when accessed outside the entity's loading context.

### Root cause
Hibernate replaces field-initialized collections with its own `PersistentBag` (or `PersistentList`) proxy at load time. This works reliably for `java.util.ArrayList` initializers. When the field is initialized with `CopyOnWriteArrayList`, Hibernate may not reliably recognize it as a replaceable collection — the proxy wrapping can silently fail or behave incorrectly. Unit tests never expose this because Hibernate does not load the entity from the database; it only affects database round-trips.

### Fix
Always initialize `@OneToMany` and `@ManyToMany` fields with `new ArrayList<>()`:

```java
// Wrong — passes unit tests, fails integration tests
@OneToMany(mappedBy = "parentTask", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
private List<HibernateTask> childTasks = new CopyOnWriteArrayList<>();

// Correct
@OneToMany(mappedBy = "parentTask", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
private List<HibernateTask> childTasks = new ArrayList<>();
```

If thread-safety is needed at the application layer, wrap on access: `Collections.synchronizedList(entity.getChildTasks())` — but do not use `CopyOnWriteArrayList` as the field initializer.

### Why non-obvious
`CopyOnWriteArrayList` implements `List` and is a perfectly valid Java collection. Nothing in Hibernate ORM documentation, Quarkus documentation, or the `@OneToMany` Javadoc warns against using non-standard `List` implementations as field initializers. The failure is invisible in unit tests and only surfaces when entities are persisted and fetched from a real database.

*Score: 12/15 · Included because: silent failure, unit tests mask the bug, nothing in any documentation warns about this constraint · Reservation: specific to teams using CopyOnWriteArrayList for thread safety in entities*
