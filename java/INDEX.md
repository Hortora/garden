# java Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0004 | Use typed element return in generator/predicate pairs to enforce cross-API type agreement | technique | 11/15 |
| GE-0023 | Java records with `List<T>` fields are not truly immutable without a compact constructor | gotcha | 11/15 |
| GE-0024 | Multiple `volatile` fields read without synchronisation produce torn cross-field snapshots | gotcha | 14/15 |
| GE-0037 | Inject a Supplier<Instant> to test time-dependent logic without sleeping or mocking frameworks | technique | 12/15 |
| GE-0058 | Wrong generic type parameters in Java stub methods compile silently | gotcha | 14/15 |
| GE-0064 | Maven aggregator pom requires `<packaging>pom</packaging>` — omitting it causes a cryptic build failure | gotcha | 11/15 |
| GE-0067 | Maven ignores non-Java files in `src/main/java/` — resources must be in `src/main/resources/` or explicitly declared | gotcha | 14/15 |
| GE-0122 | `package-private` Members in `a.b.c` Are Inaccessible from `a.b` — Sub-Packages Are Distinct Packages | gotcha | 9/15 |
| GE-0139 | `synchronized(key.intern())` causes JVM-wide global pool contention across unrelated instances | gotcha | 13/15 |
| GE-0143 | `final hashCode()` in parent — update the protected field from setters instead of overriding | gotcha | 12/15 |
| GE-0144 | Maven incremental build passes but `NoClassDefFoundError` at runtime — stale `.class` files | gotcha | 11/15 |
| GE-0158 | Use `mvn compile` to enumerate all call sites when changing a Java record signature | gotcha | 10/15 |
