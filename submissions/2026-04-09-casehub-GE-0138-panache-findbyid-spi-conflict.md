**Type:** gotcha
**Submission ID:** GE-0138
**Date:** 2026-04-09
**Project:** casehub
**Stack:** Quarkus 3.17.5, Hibernate ORM with Panache
**Scanned against:** GE-0077 (distinct — that's Vert.x reflection, unrelated)

## PanacheRepositoryBase.findById() return type blocks SPI interface implementation

**Symptom:** Compiler rejects a class that extends `PanacheRepositoryBase<HibernateCaseFile, Long>` and also implements a custom SPI interface declaring `findById(Long): Optional<CaseFile>`. Error looks like a method signature conflict, not a type error — misleading.

**Root cause:** `PanacheRepositoryBase<E, ID>` declares `findById(ID id): Optional<E>` with a concrete generic return type `Optional<E>`. When `E = HibernateCaseFile` and the SPI declares `findById(Long): Optional<CaseFile>`, Java sees two `findById(Long)` methods with different return types (`Optional<HibernateCaseFile>` vs `Optional<CaseFile>`). Even though `HibernateCaseFile implements CaseFile`, Java's type system does not allow a method to satisfy both return types simultaneously — covariant return types work for concrete classes but not for generic type parameters resolved at class declaration. The Quarkus/Panache documentation does not mention this constraint anywhere.

**Fix:** Drop `PanacheRepositoryBase` entirely. Inject `EntityManager` directly and use JPQL queries:

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

**Why non-obvious:** The error message looks like a duplicate method conflict, not a generics incompatibility. The obvious fix (casting or using a bridge method) doesn't work. Nothing in Quarkus or Panache docs warns that `PanacheRepositoryBase` is incompatible with SPI-based repository interfaces. Most tutorials show Panache used with its own query methods, never combined with a custom interface.

**Suggested target:** `quarkus/panache.md` (new file — does not exist yet)

*Score: 12/15 · Included because: non-obvious, cryptic error, high pain, relevant to any team building SPI abstractions over Panache · Reservation: somewhat niche (SPI + Panache combination)*
