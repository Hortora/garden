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
| GE-20260415-4700a5 | JAX-RS @QueryParam boolean silently rejects '1' — only 'true'/'false' accepted | gotcha | 9/15 |
| GE-20260421-2df2ba | JavaParser ClassOrInterfaceDeclaration covers both classes AND interfaces | gotcha | 12/15 |
| GE-20260421-5886e0 | Synthetic single-iteration config runs a non-template class through a code-gen pipeline | technique | 10/15 |
| GE-20260421-dbc509 | replaceAll("\\d+$") strips only trailing digits — misses embedded arity numbers like Join2First | gotcha | 9/15 |
| GE-0144 | Maven incremental build passes but `NoClassDefFoundError` at runtime — stale `.class` files | gotcha | 11/15 |
| GE-0144 | Maven incremental build passes but `NoClassDefFoundError` at runtime — stale `.class` files | gotcha | 11/15 |
| GE-20260414-c4ddc9 | In-memory service error messages should use human-readable names not internal UUIDs — TDD test assertions catch the difference | gotcha | 8/15 |
| GE-20260415-3cf4db | RestAssured GPath 'find { it == [x, y] }' matches int[] inside List<int[]> by value | undocumented | 12/15 |
| GE-20260415-5d762b | Arrays.copyOf on boolean[][] only copies references — inner rows still shared (mutable aliasing) | gotcha | 9/15 |
| GE-20260415-e112ca | Interface default no-op methods for optional lifecycle callbacks — implementors only override what they need | technique | 9/15 |
| GE-20260415-fb675d | A* nearestWalkable radius cap causes silent fallback to DirectMovement on out-of-bounds targets | gotcha | 11/15 |
| GE-20260415-fd3530 | Replace parallel switch chains over the same key with a single lookup map using index constants | technique | 9/15 |
| GE-20260416-262221 | Override Random.nextDouble() via anonymous subclass to force always-hit/always-miss in probability tests | technique | 11/15 |
| GE-20260416-39d854 | Synthesised delegation methods need explicit `public` when overriding interface methods | gotcha | 11/15 |
| GE-20260416-53d13c | Adding stop-to-fight breaks combat tests via nearest-target ordering change | gotcha | 10/15 |
| GE-20260416-7ec461 | Maven `-am -Dtest=ClassName` propagates test filter to all upstream modules — 'No tests matching pattern' on unrelated modules | gotcha | 10/15 |
| GE-20260416-b57ee4 | JavaParser NodeList.clone() returns raw Object — clone each element individually | undocumented | 10/15 |
| GE-20260416-ca1c71 | Maven *IT.java test files are silently skipped by mvn test — failsafe convention | gotcha | 12/15 |
| GE-20260417-246570 | Map<String,Integer> passed where Map<String,Object> expected — compiles via diamond target-type inference | gotcha | 9/15 |
| GE-20260417-28e1b8 | URI.create() throws IllegalArgumentException on malformed URLs — urlparse() never does | gotcha | 10/15 |
| GE-20260417-2b12e1 | Test HTTP-dependent methods by overriding package-private helpers in an inner subclass — no Mockito needed | technique | 11/15 |
| GE-20260417-460714 | mvn compile -q suppresses compiler errors — exit code is 0 and no output even when compilation fails | gotcha | 10/15 |
| GE-20260417-64e848 | JavaParser TYPE_USE annotation on qualified type names goes on scope type, not leaf | gotcha | 11/15 |
| GE-20260417-96accd | Maven multi-module cycle: adding a module as test-scope dep when it already depends on you | gotcha | 11/15 |
| GE-20260417-f962f2 | URI.getPath().split("/") produces a leading empty string — Python's path.strip('/').split('/') does not | gotcha | 10/15 |
| GE-20260418-4d4c43 | In combat simulation tests, using an attack command as a 'standing still' baseline silently doubles DPS and moves the unit | gotcha | 10/15 |
| GE-20260418-93f8b2 | Maven duplicate dependency declarations — test scope silently overrides compile scope | gotcha | 9/15 |
| GE-20260418-9b272f | Java Sealed Interface Exhaustiveness Breaks Build Mid-Plan When Type Creation and Wiring Are Separate Tasks | gotcha | 10/15 |
| GE-20260420-81d143 | Maven targets main project instead of worktree when shell CWD resets between tool calls | gotcha | 11/15 |
| GE-20260420-b9c06c | java.util.zip.ZipInputStream rejects BZip2-compressed ZIP entries with 'invalid compression method' | gotcha | 12/15 |
| GE-20260420-c2f9d2 | PriorityBlockingQueue silently corrupts heap order when element sort keys are mutated after insertion | gotcha | 10/15 |
| GE-20260420-c94e2a | Java switch expressions on enum without default break compile when new enum values are added — even if other switches have defaults | gotcha | 9/15 |
| GE-20260420-f3e0a7 | Use `jar tf` to verify a class exists in an installed Maven artifact before attempting a compile | technique | 9/15 |
| GE-20260421-1192cd | Expose @ApplicationScoped parsing logic as static package-private methods for zero-overhead unit testing | technique | 12/15 |
| GE-20260421-1fa31e | mvn clean deletes APT-generated classes, triggering cascade failure from annotation processor version mismatch | gotcha | 10/15 |
| GE-20260421-707db1 | WeakHashMap uses equals/hashCode for key lookup — use IdentityHashMap for reference-equality keying | gotcha | 10/15 |
| GE-20260421-924fc7 | Creating a Java class with the same name as an existing class in the same package silently overwrites it | gotcha | 9/15 |
| GE-20260421-bd4121 | jsoup requires Parser.xmlParser() for XML sitemaps — default HTML parser lowercases element names silently | undocumented | 10/15 |
| GE-20260421-cdfff1 | Hibernate L1 cache returns stale entity after bulk JPQL DELETE — em.clear() required | gotcha | 10/15 |
| GE-20260426-4e3801 | java -jar: JVM -D flags after the jar path are app arguments, not JVM properties | gotcha | 10/15 |
| GE-20260427-edbacd | Java test infrastructure: adding a new collection to a class requires clearing it in BOTH reset() and clearAll() — missing one causes @QuarkusTest state bleed | gotcha | 11/15 |
| GE-20260428-3c89fa | Java overload erasure clash: same generic class with flipped type args is not a distinct signature | gotcha | 11/15 |
| GE-20260428-be6d8b | Wrap traversal variants at the DSL boundary — zero runtime changes for new collection types | technique | 9/15 |
| GE-20260504-059d1f | Maven `-pl <submodule>` resolves dependencies from .m2 cache — source changes in sibling modules invisible without `install` | gotcha | 11/15 |
| GE-20260505-8c57c2 | CDI events as a bridge for circular Maven module dependencies — fire from lower module, observe in upper | technique | 11/15 |
| GE-20260505-b04e30 | AssertJ: assertThat(() -> voidMethod()) won't compile — use assertThatCode() for void lambdas | gotcha | 9/15 |
| GE-20260511-a5f47d | Registry isKnown() silently bypasses capabilities() override when backed by a static field | gotcha | 10/15 |
| GE-20260513-436312 | mvn test -q 2>&1 | tail -N always exits 0 — pipe masks Maven failure | gotcha | 10/15 |
| GE-20260513-feea71 | SC2 armour reduces shield damage as well as HP damage — asserting rawDamage is off by armour | undocumented | 8/15 |
| GE-20260501-93f9a8 | Use javap -verbose to read @NamedQuery annotations from JPA entity class files in compiled JARs | technique | 10/15 |
| GE-20260501-a9ea1a | SNAPSHOT dependency upgrade silently breaks interface contracts — compile error points at your class, not the dep | gotcha | 10/15 |
| GE-20260529-8b17d1 | LinkedHashMap with accessOrder=true and removeEldestEntry is a zero-dependency LRU cache | technique | 10/15 |
