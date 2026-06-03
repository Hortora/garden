| GE-20260518-980ad7 | Maven SNAPSHOT rebuilt by subagent mid-session causes NoSuchMethodError at test runtime despite clean compile | gotcha | 11/15 |
| GE-20260518-6ed073 | mvn install silently skips recompile of SNAPSHOT dependency when ~/.m2 JAR is stale | gotcha | 11/15 |
| GE-20260518-896005 | In-memory test doubles are not rolled back when @Transactional rolls back — JTA and non-JTA writes diverge | gotcha | 12/15 |
| GE-20260518-da7e91 | em.flush() + JPQL bulk UPDATE + em.clear() for same-transaction save-then-update | technique | 11/15 |
| GE-20260518-a61d1b | @ConsumeEvent(blocking=true) and @Transactional on the same method work correctly in Quarkus | undocumented | 9/15 |
| GE-20260518-d1e4b2 | Python paren-counting scripts miscount Java constructor args containing JSON string literals with internal commas | gotcha | 11/15 |
| GE-20260518-d1e4b2 | Python paren-counting scripts miscount Java constructor args containing JSON string literals with internal commas | gotcha | 11/15 |
| GE-20260518-069f64 | Calling @Transactional method via `this` inside Mutiny lambda silently bypasses CDI proxy — use CDI self-injection | gotcha | 12/15 |
| GE-20260518-e4fa52 | RESTEasy Reactive endpoints that call .await() on the IO thread throw BlockingOperationNotAllowedException — add @Blocking | gotcha | 11/15 |
| GE-20260518-bee1b3 | Virtual-thread offload + CDI self-injection: pattern for safe blocking JPA in a reactive pipeline | technique | 11/15 |
| GE-20260519-290cfb | persistence-memory/ vs testing/ — in-memory impls belong in persistence-memory/ only when they have a production use case | technique | 9/15 |
| GE-20260519-b9719e | SmallRye Config throws NoSuchElementException for Map<String,String> @ConfigProperty when no keys match the prefix | undocumented | 8/15 |
| GE-20260519-3ffbc0 | Class.isAssignableFrom() direction is silently wrong in reflection-based SPI parity tests | gotcha | 11/15 |
| GE-20260519-f0967f | Quarkus reactive SPI test shim: resolve Uni injections in @QuarkusTest without a Vert.x datasource | technique | 12/15 |
| GE-20260519-e13b01 | @QuarkusTest in casehub harness app crashes with ClassSelector resolution failed when casehub-ledger runtime is on classpath | gotcha | 11/15 |
| GE-20260519-73820e | InstanceHandle.close() default calls Arc.requireContainer() — fails silently in plain-Java tests | gotcha | 8/15 |
| GE-20260519-eb8340 | Instance<T>.handles() returns Iterable<? extends Instance.Handle<T>> — incompatible with Iterable<InstanceHandle<T>> | gotcha | 9/15 |
| GE-20260519-c1ce15 | Flyway baselineOnMigrate(true) default baselineVersion=1 silently skips V1 migration | gotcha | 10/15 |
| GE-20260519-f88597 | TDD for Flyway schema migrations: plain-Java test using Flyway+H2 + JDBC metadata assertions | technique | 10/15 |
| GE-20260519-12efe9 | QuarkusTestProfile.getEnabledAlternatives() scopes a CDI @Alternative to a single @QuarkusTest class | technique | 11/15 |
| GE-20260519-114395 | Call @ConsumeEvent/@ObservesAsync handlers directly via injected CDI proxy — preserves @Transactional, eliminates async waiting in tests | technique | 12/15 |
| GE-20260519-28275c | @Transactional(REQUIRES_NEW) must return normally — a throw rolls back its own transaction too | gotcha | 12/15 |
| GE-20260519-23b704 | Lifecycle guard ordering: status check must precede policy check to prevent phantom audit entries | gotcha | 10/15 |
| GE-20260519-685b4b | DB UNIQUE constraint on a shared @QuarkusTest H2 instance forces @BeforeEach template cleanup across all test classes | gotcha | 9/15 |
| GE-20260519-28967d | ChannelGateway.receiveHumanMessage() rejects messages whose type isn't in the channel's allowedTypes | gotcha | 10/15 |
| GE-20260519-dcdac5 | @Transactional on a called method is silently dropped when invoked via self-call from an @ObservesAsync observer | gotcha | 11/15 |
| GE-20260519-e193d2 | Awaitility polling lambdas in @QuarkusTest have no JTA context — Panache reads throw ContextNotActiveException | gotcha | 9/15 |
| GE-20260519-4a42e6 | Panache.withTransaction() requires a duplicated Vert.x context — executeBlocking() root context still fails VertxContextSafetyToggle | gotcha | 11/15 |
| GE-20260519-f9624b | CDI @Alternative reactive wrapper with private new Impl() delegate is a separate instance from the CDI bean — @AfterEach clear() silently targets the wrong object | gotcha | 11/15 |
| GE-20260519-d32fc0 | RESTEasy Reactive silently serializes raw Uni<T> passed to Response.ok() — no compile error, 500 at runtime | gotcha | 12/15 |
| GE-20260519-f33c66 | 'Reactive' Quarkus service classes may use blocking services or Panache statics internally — CDI @Alternative in-memory stores don't intercept those paths | undocumented | 9/15 |
| GE-20260519-098413 | @ConfigRoot(BUILD_TIME) in deployment module does not suppress SRCFG00050 if a runtime @ConfigMapping owns the same prefix | gotcha | 10/15 |
| GE-20260519-244ad2 | Gate optional beans in a Quarkus extension with ExcludedTypeBuildItem + @ConfigRoot(BUILD_TIME) — not @IfBuildProperty on runtime beans | technique | 12/15 |
| GE-20260520-1e294c | jsonschema2pojo generates absent array/list fields as empty ArrayList, not null | gotcha | 10/15 |
| GE-20260520-48e1d4 | @BuildStep producing ExcludedTypeBuildItem silently not invoked during Quarkus test augmentation from workspace deployment module | gotcha | 12/15 |
| GE-20260520-c52767 | BUILD_TIME @ConfigRoot properties in application.properties cause SRCFG00050 SmallRye Config runtime validation error | gotcha | 10/15 |
| GE-20260520-ec2f39 | Use jakarta.ws.rs-api (provided) not quarkus-rest when you only need JAX-RS @Provider annotations | gotcha | 9/15 |
| GE-20260520-e15ff0 | Use @QuarkusTestProfile.getConfigOverrides() to isolate per-class @QuarkusTest config | technique | 9/15 |
| GE-20260520-45312d | @QuarkusTest enricher tests pass silently when no signing key is configured — @InjectMock the provider | gotcha | 9/15 |
| GE-20260520-c0e5b4 | Podman on macOS requires explicit DOCKER_HOST for Testcontainers — no /var/run/docker.sock without podman-mac-helper | gotcha | 13/15 |
| GE-20260521-0bd1e6 | @Alternative without @Priority silently disables @IfBuildProperty-gated beans — dependencies activate, service does not | gotcha | 11/15 |
| GE-20260521-d72294 | Blocking and reactive store interfaces have irreconcilable put() signatures — one class cannot implement both | gotcha | 10/15 |
| GE-20260521-2b82e7 | Panache.withTransaction() uses the default persistence unit — silently wrong in apps with only a named PU | gotcha | 11/15 |
| GE-20260521-49e7fd | CDI delegate pattern: reactive in-memory store wraps blocking store to share state across both interfaces in @QuarkusTest | technique | 11/15 |
| GE-20260521-6f257b | JAX-RS @QueryParam endpoint silently ignores JSON request body — body field name is irrelevant | gotcha | 11/15 |
| GE-20260521-6f257b | JAX-RS @QueryParam endpoint silently ignores JSON request body — body field name is irrelevant | gotcha | 11/15 |
| GE-20260521-effd2f | Flyway scans classpath:db/migration recursively — subdirectory db/migration/<module>/ is visible to any datasource scanning the parent path | gotcha | 11/15 |
| GE-20260521-effd2f | Flyway scans classpath:db/migration recursively — subdirectory db/migration/<module>/ is visible to any datasource scanning the parent path | gotcha | 11/15 |
| GE-20260521-aba9c9 | assertNotNull on a primitive boolean return silently passes — autoboxing defeats the null check | gotcha | 10/15 |
| GE-20260428-9571b8 | Bayesian Beta trust model may store confidence as a field but not use it in the update weight | gotcha | 10/15 |
| GE-20260429-a9bd85 | CaseInstanceRepository.updateStateAndAppendEvent() already appends the EventLog — calling append() first duplicates the write | undocumented | 9/15 |
| GE-20260512-59a501 | CaseContextImpl.snapshot() returns CaseContextImpl — subclasses lose their type on copy | gotcha | 11/15 |
| GE-20260512-5bcc7b | Preserve subclass type in CaseContextImpl.snapshot() without accessing private deepCopy | technique | 10/15 |
| GE-20260512-b0eea3 | CaseContextImpl.set(key, null) on an absent key is a no-op — the key is never inserted | gotcha | 10/15 |
| GE-20260501-11ce7f | MessageLedgerEntry.content is null for EVENT entries — LIKE content search silently returns nothing | gotcha | 11/15 |
| GE-20260501-b12416 | MessageLedgerEntry.sequenceNumber is per-channel, not global — wrong ORDER BY for cross-channel queries | gotcha | 10/15 |
| GE-20260423-3be346 | WorkerCandidate.of(id) creates empty capabilities — WorkBroker filters all candidates when requiredCapabilities is non-null | gotcha | 12/15 |
| GE-20260501-29e3b8 | QuarkusTest: notification rules persist across tests — dynamic WireMock port reuse causes false positives | gotcha | 8/15 |
| GE-20260502-c77725 | MultiInstanceSpawnService.onThresholdReached defaults to CANCEL — tests completing all children race with coordinator cancelling the surplus | gotcha | 12/15 |
| GE-20260513-74dc72 | casehub-work requires io.casehub.work.runtime.filter in Hibernate scan packages — omitting it causes FilterRule entity-not-found at startup | gotcha | 10/15 |
| GE-20260421-09d636 | EigenTrust: pre-trusted distribution as dangling-node fallback creates 3-cycle non-convergence | gotcha | 11/15 |
| GE-20260421-28c521 | Serializable functional interface enables SerializedLambda reflection to extract generic return type from method reference | technique | 13/15 |
| GE-20260421-473024 | Rebasing a branch onto upstream silently breaks downstream interface implementors in multi-module Maven — CI catches what local tests miss | gotcha | 11/15 |
| GE-20260421-efa107 | Maven -Dexcludes does not suppress Quarkus @QuarkusTest class-loader failures — use Maven profiles instead | gotcha | 11/15 |
| GE-20260422-0ed3e5 | CDI container wiring vs service-loader wiring in large JVM frameworks | architectural | 11/15 |
| GE-20260422-53d0f7 | JPA @EntityListeners can be @ApplicationScoped CDI beans in Quarkus — injection works | technique | 10/15 |
| GE-20260422-70b817 | Span.wrap(SpanContext).makeCurrent() creates OTel trace context in tests without SDK | technique | 10/15 |
| GE-20260422-e48245 | @DefaultBean lives in io.quarkus.arc, not jakarta.enterprise.inject | gotcha | 11/15 |
| GE-20260423-037747 | quarkus.flyway.out-of-order=true required when Testcontainers DB is reused across runs with RYUK disabled | undocumented | 10/15 |
| GE-20260423-29f45a | BeanManager.resolveObserverMethods() for zero-cost startup observer detection in CDI | technique | 11/15 |
| GE-20260423-878486 | quarkus-langchain4j-jlama fails at test bootstrap with 'Unsupported value type: [ALL-UNNAMED]' on Quarkus 3.32+ | gotcha | 10/15 |
| GE-20260423-bcb5b7 | quarkus-work-core registers both LeastLoadedStrategy and ClaimFirstStrategy as @ApplicationScoped CDI beans — injecting WorkerSelectionStrategy interface causes AmbiguousResolutionException | gotcha | 11/15 |
| GE-20260423-c8d8cb | ConcurrentHashMap.computeIfAbsent() + .add() is not atomic with concurrent remove() — futures can be permanently lost | gotcha | 13/15 |
| GE-20260423-daef97 | CDI event.fire() does not deliver to @ObservesAsync observers — fireAsync() required separately | gotcha | 13/15 |
| GE-20260423-fce720 | quarkus-work-core FilterRule JPA entity requires a datasource — modules using in-memory persistence fail startup | gotcha | 11/15 |
| GE-20260424-275fdc | Maven SNAPSHOT jar persists in ~/.m2 when source bumps version — stale annotations cause misleading CDI errors | gotcha | 13/15 |
| GE-20260424-318ef3 | Service unit tests can't go in runtime/src/test/ when service depends on a class in the testing/ module | gotcha | 9/15 |
| GE-20260424-439ccb | JPA unique constraint on a business key blocks delegation chains where multiple records share the same key | gotcha | 10/15 |
| GE-20260424-647a6d | Encode group membership in a string field to avoid a join table — deterministic scoping without schema changes | technique | 10/15 |
| GE-20260424-807b7e | assertj-core not on runtime test classpath in Quarkiverse multi-module — produces misleading compiler error | gotcha | 8/15 |
| GE-20260424-a02588 | CDI @Qualifier + AnnotationLiteral producer for configurable named resource in Quarkus extensions | technique | 12/15 |
| GE-20260424-a55003 | Adding a field to a Java record breaks every positional constructor call silently until compile time | gotcha | 9/15 |
| GE-20260424-e33d79 | Hardcoding a consumer-specific @PersistenceUnit in a generic Quarkus extension silently breaks all other consumers | gotcha | 13/15 |
| GE-20260427-0e7508 | Reactive scope evaluation (scopeGuard wrapping JoinRightInlet) loses left outer facts for 2-source rules | gotcha | 10/15 |
| GE-20260427-226217 | Wrap at store time to add ctx-optional API variants without changing the fire path | technique | 9/15 |
| GE-20260427-23f4a7 | Reflection-based predicate invocation must detect ctx-first vs no-ctx arity to avoid wrong-number-of-arguments | gotcha | 10/15 |
| GE-20260427-c94b12 | Java erasure conflict at specific arity boundaries when adding ctx-optional filter overloads | gotcha | 10/15 |
| GE-20260428-096e90 | JPA FK without CASCADE requires manual child deletion before parent deletion | gotcha | 10/15 |
| GE-20260428-29b30e | Reuse an already-required query to drive a second operation inside REQUIRES_NEW — avoids extra DB round-trips and transaction visibility issues | technique | 9/15 |
| GE-20260428-5c3e93 | REQUIRES_NEW suspends outer transaction — inner JPA queries see pre-commit state | gotcha | 12/15 |
| GE-20260428-6d75d7 | Panache/JPA count methods may return int rather than long — check the actual return type | undocumented | 8/15 |
| GE-20260428-7e57f9 | @QuarkusTest always runs in mock profile — Playwright tests pass while the real application (replay/emulated) is broken | gotcha | 12/15 |
| GE-20260428-b966bd | Vert.x pub/sub fan-out race: mutable completion index overwritten by re-triggered component | gotcha | 10/15 |
| GE-20260428-f075ef | Race-free CompletableFuture per-item pattern for CDI async event tests | technique | 10/15 |
| GE-20260429-101efe | H2 2.4.240 supports UNIQUE NULLS NOT DISTINCT — no sentinel value needed for nullable unique columns | undocumented | 11/15 |
| GE-20260429-177cbe | Map.of() / Map.ofEntries() throw NPE on get(null), not return null | gotcha | 10/15 |
| GE-20260429-21e6cf | Quarkus: JPA entity in a dependency artifact forces datasource config on ALL downstream consumers | gotcha | 11/15 |
| GE-20260429-42fb02 | Bayesian Beta trust score returns 0.5 for no evidence, not 1.0 | gotcha | 9/15 |
| GE-20260429-61810f | JPA findByActorIdAndTypeAndKey(nonGlobalType, null) silently queries GLOBAL rows | gotcha | 10/15 |
| GE-20260429-68ee24 | @ConsumeEvent handler silently deadlocks if .join() is called without blocking = true | gotcha | 11/15 |
| GE-20260429-a79d0e | @Alternative @Priority(N) in Quarkus CDI auto-activates without quarkus.arc.selected-alternatives config | technique | 9/15 |
| GE-20260429-ede58e | quarkus.flyway.migrate-at-start is build-time fixed — test application.properties cannot override a jar's microprofile-config.properties value | gotcha | 9/15 |
| GE-20260429-f17b24 | Recency decay tests silently pass wrong assertion when attestation.occurredAt is null | gotcha | 8/15 |
| GE-20260430-0042ff | Transitive SNAPSHOT dependencies unreliable on GitHub Packages — explicit dep required | gotcha | 11/15 |
| GE-20260430-3275b1 | GitHub Packages SNAPSHOT CI timing race — downstream fails before upstream publishes | gotcha | 12/15 |
| GE-20260430-84bef2 | serverlessworkflow sdk-java: WorkflowExecutionListener exceptions are silently swallowed as suppressed exceptions — listener appears not to have fired | gotcha | 9/15 |
| GE-20260430-b015f5 | quarkus-mcp-server silently drops @Tool on methods with public same-name overloads | undocumented | 13/15 |
| GE-20260501-56e179 | ThreadLocal set on calling thread is invisible inside CompletableFuture.supplyAsync() | gotcha | 12/15 |
| GE-20260501-697d3e | Quarkus identity-tokenised repository query returns empty when tokeniseForQuery omitted on new method | gotcha | 11/15 |
| GE-20260501-76cc3c | IntelliJ ide_refactor_rename with relatedRenamingStrategy:none renames one overload precisely — declaration and internal call sites updated, sibling overloads untouched | technique | 10/15 |
| GE-20260501-ab68c1 | Hibernate persistAndFlush() flushes ALL tracked entities — @Version entity loaded read-only causes OCC | gotcha | 10/15 |
| GE-20260501-b1874b | Test CDI @Inject fields in plain unit tests by making them package-private and setting directly | technique | 10/15 |
| GE-20260501-b88737 | Parallel SPI interfaces in api/ and runtime/ modules diverge silently — no compile error, no usage | gotcha | 10/15 |
| GE-20260501-b89a0d | Use '*' sentinel string instead of NULL for 'applies to all' in scoped fields | technique | 10/15 |
| GE-20260501-e13ed0 | Maven mvn test in a child module silently skips sibling example/integration modules — need mvn install from root | gotcha | 9/15 |
| GE-20260504-104371 | @ConfigProperty fields are null when @ApplicationScoped bean is instantiated with new outside CDI | gotcha | 10/15 |
| GE-20260504-5b9269 | Nested Collectors.groupingBy produces O(M) multi-key grouping without re-streaming | technique | 10/15 |
| GE-20260505-43a73b | Mockito `thenReturn(stream)` exhausts CDI Instance<T> mock on second providerFor() call | gotcha | 10/15 |
| GE-20260505-c07ffa | Testing fail-closed config in @QuarkusTest using @TestProfile with blank-string override | technique | 9/15 |
| GE-20260505-da346d | @ApplicationScoped CDI beans are always-active in Quarkus — safe to call from any thread | undocumented | 8/15 |
| GE-20260505-e89194 | PlayerState refactor leaves supply=0 — silently blocks all TrainIntent processing | gotcha | 10/15 |
| GE-20260508-3a77c5 | Quarkus multi-module: mvn compile fails with NoSuchFileException when api/ submodule has no sources yet | gotcha | 12/15 |
| GE-20260508-b4c9b4 | quarkus-rest does not include Bean Validation — @NotBlank/@Valid silently ignored without quarkus-hibernate-validator | gotcha | 11/15 |
| GE-20260508-ce2285 | UUID-suffix business keys in @QuarkusTest to prevent H2 in-memory shared-state conflicts | technique | 11/15 |
| GE-20260511-0b3fa2 | Quarkus BOM manages mockito-junit-jupiter — explicit version pin silently shadows it | undocumented | 9/15 |
| GE-20260511-2b3d3e | Express trust-phase logic as methods on the routing policy value object, not the router | technique | 9/15 |
| GE-20260511-5be2d2 | Maven -rf resume uses stale .m2 jar from failed earlier module — causes impossible compilation errors | gotcha | 12/15 |
| GE-20260511-ce1c9d | Java package move breaks wildcard imports and same-package implicit imports — two silent failures | gotcha | 10/15 |
| GE-20260512-0fe012 | CDI fireAsync() inside @Transactional dispatches immediately — observer can run before the triggering transaction commits | gotcha | 12/15 |
| GE-20260512-1fa51e | @Scheduled interval without $ prefix silently uses literal string as duration — fires at wrong frequency | gotcha | 11/15 |
| GE-20260512-2c2eff | Non-ANSI SQL types in Flyway migrations pass H2 tests silently but fail on PostgreSQL at deployment | gotcha | 13/15 |
| GE-20260512-47f92e | quarkus-junit5 is a relocation stub since Quarkus 3.31 — quarkus-junit is the real artifact | gotcha | 10/15 |
| GE-20260512-493c90 | @QuarkusTest classes named *IT.java silently report 0 tests — maven-failsafe collects them instead of surefire | gotcha | 12/15 |
| GE-20260512-50b394 | Use @TestTransaction + unique identifiers to prevent @Scheduled interference in Quarkus tests | technique | 11/15 |
| GE-20260512-523f68 | Quarkus dev mode hot-reload silently breaks WebSocket endpoint registration — full restart required | gotcha | 10/15 |
| GE-20260512-552405 | @ConfigMapping interface methods without Javadoc cause a compile error — not a runtime warning | gotcha | 11/15 |
| GE-20260512-66d997 | Panache static methods bypass CDI @Alternative stores — returns empty results silently | gotcha | 12/15 |
| GE-20260512-67b3b5 | Panache find() alias-prefixed field names return empty results silently — bare field names required | gotcha | 12/15 |
| GE-20260512-6887c9 | @ObservesAsync + @Transactional on the same method is unreliable — delegate transactional logic to a separate bean | gotcha | 11/15 |
| GE-20260512-6d0c2b | BroadcastProcessor.onNext() throws BackPressureFailure when no subscribers are registered | gotcha | 10/15 |
| GE-20260512-7720ab | H2-reserved words as column names pass PostgreSQL but fail silently in H2 test mode | gotcha | 11/15 |
| GE-20260512-9f4de6 | Java class implementing both factory and product interfaces causes NPE when null sentinel calls shared constructor | gotcha | 9/15 |
| GE-20260512-a09bd3 | Enforce blocking/reactive SPI method parity with a reflection test — silent drift causes downstream compile failures | technique | 10/15 |
| GE-20260512-a3838e | Transitive hibernate-reactive-panache on classpath causes H2 test startup failure — disable reactive datasource in test config | gotcha | 12/15 |
| GE-20260512-a9ad9f | Raw ExecutorService drops CDI context — @Transactional silently broken on background threads | gotcha | 11/15 |
| GE-20260512-b3f32a | @IfBuildProperty/@UnlessBuildProperty evaluated at augmentation only — QuarkusTestProfile properties have no effect on bean activation | gotcha | 13/15 |
| GE-20260512-c246b0 | Test Quarkus CDI SPI implementations with @Alternative static inner classes — Mockito cannot be injected as CDI beans | technique | 11/15 |
| GE-20260512-c30f52 | @QuarkusIntegrationTest in the runtime module causes class loading failures — separate integration-tests/ module required | gotcha | 11/15 |
| GE-20260512-e3e525 | OCC + policyTriggered flag for M-of-N threshold completion — prevents duplicate trigger under READ COMMITTED | technique | 12/15 |
| GE-20260512-e552f7 | @ApplicationScoped bean state persists across @QuarkusTest classes — tests pass in isolation but fail in suite | gotcha | 12/15 |
| GE-20260512-ea776c | Quarkus named persistence units silently skip schema generation — explicit config required per named PU | gotcha | 12/15 |
| GE-20260513-3c1a03 | @TestSecurity silently ignored on @QuarkusTest classes that never touch HTTP | gotcha | 11/15 |
| GE-20260513-4c4205 | Use AtomicInteger call counter in Supplier<String> to distinguish SSE events by content in tests | technique | 10/15 |
| GE-20260513-a49d06 | CDI this.method() call bypasses @Transactional proxy — annotation silently dead on delegating overloads | gotcha | 12/15 |
| GE-20260513-b15933 | @ObservesAsync CDI events are silently not delivered in @QuarkusTest — call observer directly | gotcha | 11/15 |
| GE-20260513-b9df01 | Prove a Java interface default method via anonymous implementation test — the compiler error is the RED state | technique | 10/15 |
| GE-20260513-e04f26 | Store configuration on the runtime entity to eliminate a parallel callback registry | architectural | 10/15 |
| GE-20260514-056bc5 | Java 21 switch expression over enum gives compiler-enforced exhaustiveness for type dispatch | technique | 9/15 |
| GE-20260514-36f3ef | Early-return overwrite branches must explicitly set every new entity field — the normal path won't run for them | gotcha | 10/15 |
| GE-20260514-421a6e | ConcurrentHashMap.newKeySet().add() provides atomic idempotent registration without explicit locks | technique | 10/15 |
| GE-20260514-477d2f | Hibernate 6 SessionFactoryObserverForNamedQueryValidation throws at boot for schema-drifted JARs — quarkus property overrides don't suppress it | gotcha | 11/15 |
| GE-20260514-636916 | Flyway migration numbering: always verify existing files before naming — prior sessions may have added higher-numbered migrations | gotcha | 9/15 |
| GE-20260514-83ee13 | @DefaultBean in Quarkus is io.quarkus.arc.DefaultBean, not jakarta.enterprise.inject | gotcha | 9/15 |
| GE-20260514-875f82 | Quarkus extension testing module creates circular Maven dependency — InMemory stores unavailable in runtime unit tests | gotcha | 9/15 |
| GE-20260514-e340ee | Evaluate a JQ template against an external map by constructing a temporary CaseContextImpl | technique | 9/15 |
| GE-20260514-e5797b | CHECK constraint tying discriminator to key column nullity makes schema self-enforcing | technique | 11/15 |
| GE-20260515-6e8205 | Three-tier Maven module structure — api/common/runtime | convention | 12/15 |
| GE-20260515-70021c | Always scope Maven commands to a specific module with -pl | technique | 9/15 |
| GE-20260515-99cf39 | Config-driven @Produces @DefaultBean for engine-internal strategy selection with consumer override | technique | 11/15 |
| GE-20260515-c272d2 | Quartz job store: RAM store for stateless scheduling | convention | 10/15 |
| GE-20260515-cd1653 | Testcontainers with Podman: set DOCKER_HOST to Podman socket — no docker binary needed | gotcha | 10/15 |
| GE-20260515-da8abd | Maven submodule folder names — short, no repo-name prefix | convention | 9/15 |
| GE-20260515-ed10ee | Awaitility untilAsserted gives weaker guarantee than during for exact async event counts | gotcha | 13/15 |
| GE-20260515-fd3156 | @DefaultBean on @Produces method makes the produced bean default — placing it on the class does not | gotcha | 13/15 |
| GE-20260515-ffde26 | Optional Quarkus features: Jandex library module pattern | convention | 12/15 |
| GE-20260516-2805b7 | Abstract superclasses indexed by Jandex are treated as CDI bean candidates and fail deployment | gotcha | 9/15 |
| GE-20260516-3a27dc | Maven surefire profile without combine.self="override" silently skips tagged tests — Tests run: 0, BUILD SUCCESS | gotcha | 13/15 |
| GE-20260516-4bf0dc | quarkus.arc.exclude-types does not gate JAX-RS @Path resources — REST scanner is independent of CDI | gotcha | 12/15 |
| GE-20260516-8375d5 | A jar with application.properties at its root causes Quarkus to scan all its classes as an application archive | gotcha | 12/15 |
| GE-20260516-e137f6 | QuarkusTestProfile.getConfigOverrides() replaces %test.-prefixed config entirely for that profile | technique | 10/15 |
| GE-20260517-0823c8 | Cross-repo TDD: downstream repo compiles against installed JAR, not source — mvn install required between repos | gotcha | 12/15 |
| GE-20260517-11dd6b | IllegalArgumentException catch around UUID.fromString + downstream call swallows unrelated errors | gotcha | 11/15 |
| GE-20260517-5879a9 | ChannelGateway.receiveHumanMessage() passes correlationId=null — Commitment auto-state-machine never fires for human responses | gotcha | 13/15 |
| GE-20260517-5b8e78 | casehub-qhorus core services (MessageService, CommitmentService, ChannelService, ChannelGateway) are CDI-injectable despite only being documented as MCP tools | undocumented | 12/15 |
| GE-20260517-5de55b | MessageService.send() auto-opens qhorus Commitment when type=COMMAND and correlationId is non-null | undocumented | 11/15 |
| GE-20260517-66d611 | Jackson ObjectMapperCustomizer mixin adds @JsonTypeInfo to sealed interface without polluting pure-Java api/ module | technique | 10/15 |
| GE-20260517-712fe5 | Use `@ApplicationScoped` capture bean with `CountDownLatch` to test `@ObservesAsync` CDI events in `@QuarkusTest` | technique | 11/15 |
| GE-20260517-7471c7 | Java HttpClient silently returns empty result for file:// URLs | gotcha | 11/15 |
| GE-20260517-8d62e3 | casehub-qhorus: tools.sendMessage("handoff") throws IllegalArgumentException when target is null | gotcha | 10/15 |
| GE-20260517-9006f7 | `@DefaultBean @ApplicationScoped` blocking bridge for reactive SPI in `@QuarkusTest` — no CDI ambiguity, no production impact | technique | 9/15 |
| GE-20260517-9181a6 | Per-entity qhorus channels as correlation mechanism when receiveHumanMessage() loses correlationId | technique | 11/15 |
| GE-20260517-92a95d | WorkItemCreateRequest record fields expanded in casehub-work 0.2-SNAPSHOT — parentId (UUID) and labels (List<String>) added | gotcha | 9/15 |
| GE-20260517-9e571a | @Typed required when CDI bean implements a framework-owned interface to prevent AmbiguousResolutionException | gotcha | 10/15 |
| GE-20260517-a6d608 | DefaultBean @ApplicationScoped + MicroProfile Config @ConfigProperty enables zero-config SPI with deployment-level overrides | technique | 11/15 |
| GE-20260517-aaf0a7 | List.getLast() — O(1) last-element access via Java 21 SequencedCollection | technique | 10/15 |
| GE-20260517-da2a42 | casehub-work IllegalStateExceptionMapper silently maps IllegalStateException to HTTP 409 | gotcha | 9/15 |
| GE-20260517-e10a0f | casehub-qhorus: after HANDOFF, findByCorrelationId returns the child OPEN commitment, not the parent DELEGATED | gotcha | 10/15 |
| GE-20260517-e78ae8 | JPA entity returned from @Transactional method is detached — field mutations silently lost | gotcha | 13/15 |
| GE-20260517-f28d15 | qhorus InboundNormaliser SPI is application-wide — domain-specific normaliser misclassifies messages on unrelated channels | gotcha | 10/15 |
| GE-20260517-f31786 | `event.fireAsync()` returns `CompletionStage<Event<T>>` not `CompletionStage<Void>` — Mutiny bridge needs `.replaceWith()` | gotcha | 9/15 |
| GE-20260521-3ce7ca | @Alternative @Priority(1) from an external JAR does not override a non-alternative bean in Quarkus — needs exclude-types + selected-alternatives | gotcha | 11/15 |
| GE-20260521-4de4f1 | QuarkusTestProfile.getEnabledAlternatives() replaces quarkus.arc.selected-alternatives entirely — does not append | gotcha | 9/15 |
| GE-20260420-1d1452 | @NamedQuery on entity classes validates JPQL at Hibernate startup — typos fail at boot not at query time | technique | 9/15 |
| GE-20260420-86180e | em.merge() + em.remove() on JOINED inheritance entity throws OptimisticLockException from wrong EntityManager context | gotcha | 12/15 |
| GE-20260420-d99177 | @QuarkusTest classes sharing the same H2 in-memory JDBC URL contaminate each other's data | gotcha | 10/15 |
| GE-20260424-883890 | Quarkus JAX-RS duplicate endpoint error when an interrupted agent leaves a stale resource file | gotcha | 8/15 |
| GE-20260427-543663 | @Produces @DefaultBean for library-level overridable CDI defaults without @Alternative | technique | 11/15 |
| GE-20260427-59ea5d | Flyway version collision when optional Quarkus module shares classpath with runtime module | gotcha | 12/15 |
| GE-20260427-893862 | @Observes(during = AFTER_SUCCESS) for post-commit side effects that must not fire on rollback | technique | 12/15 |
| GE-20260501-0586a4 | Awaitility during() asserts a count is stable — prevents false-pass when concurrent events arrive just after the condition is met | technique | 10/15 |
| GE-20260501-4c94b8 | Vert.x Mutiny PgPool.getConnection() returns SqlConnection wrapper — casting to PgConnection throws ClassCastException | gotcha | 13/15 |
| GE-20260501-884024 | @Observes(during = AFTER_SUCCESS) CDI observer silently does not fire when no JTA transaction is active | gotcha | 11/15 |
| GE-20260501-9de50b | @ObservesAsync events from one @QuarkusTest method leak into the next via @BeforeEach clear() | gotcha | 12/15 |
| GE-20260513-4f26a7 | @DefaultBean + plain @ApplicationScoped enables CDI layer displacement without config switches or @Alternative @Priority | technique | 10/15 |
| GE-20260521-3ce7ca | @Alternative @Priority(1) from an external JAR does not override a non-alternative bean in Quarkus — needs exclude-types + selected-alternatives | gotcha | 11/15 |
| GE-20260521-4de4f1 | QuarkusTestProfile.getEnabledAlternatives() replaces quarkus.arc.selected-alternatives entirely — does not append | gotcha | 9/15 |
| GE-20260521-3ce7ca | @Alternative @Priority(1) from an external JAR does not override a non-alternative bean in Quarkus — needs exclude-types + selected-alternatives | gotcha | 11/15 |
| GE-20260521-a5e71b | Panache.withTransaction(() -> ...) silently routes to default PU even when consumer has only a named datasource | gotcha | 11/15 |
| GE-20260521-3e030b | mvn test-compile -pl runtime succeeds but test runtime fails with NoClassDefFoundError after moving types to api module — installed jar is stale | gotcha | 10/15 |
| GE-20260521-981f62 | SC2 replay PlayerStats events fire every ~10 seconds, not every game tick — GT mineral readings are stale | gotcha | 9/15 |
| GE-20260521-f50602 | quarkus-oidc: discovery-disabled requires jwks-path or introspection-path | gotcha | 9/15 |
| GE-20260521-8b39bd | ArtifactResultBuildItem lives in io.quarkus.deployment.pkg.builditem, not io.quarkus.deployment.builditem | gotcha | 9/15 |
| GE-20260521-47ab45 | Plain-Java Flyway contract test picks up src/test/resources SQL files when scanning production classpath location | gotcha | 9/15 |
| GE-20260521-0278e2 | Stale target/test-classes from mid-session file moves cause spurious Flyway duplicate-version errors | gotcha | 8/15 |
| GE-20260521-977e3e | Void @BuildStep in Quarkus extension is silently elided unless anchored with @Produce(ArtifactResultBuildItem.class) | undocumented | 11/15 |
| GE-20260521-0278e2 | Stale target/test-classes from mid-session file moves cause spurious Flyway duplicate-version errors | gotcha | 8/15 |
| GE-20260521-debce2 | Test @RequestScoped CDI beans directly with @InjectMock + manual Arc request context — no HTTP layer needed | technique | 9/15 |
| GE-20260521-c04e27 | Java Map/Set class fields declared without initializer silently NPE on first use | gotcha | 11/15 |
| GE-20260521-537d58 | Flyway plain-Java schema test: specify all real locations instead of manually bootstrapping dependency tables | technique | 8/15 |
| GE-20260521-0e0122 | @Transactional(REQUIRES_NEW) retry inside same bean is a dead retry — poisoned transaction cannot restart | gotcha | 11/15 |
| GE-20260521-998034 | Multi-catch with exception subclass is a compile error — OptimisticLockException | PersistenceException is illegal | gotcha | 10/15 |
| GE-20260521-45e61c | casehub-connectors-core TwilioSmsConnector and WhatsAppConnector fail CDI validation in JDBC-only test environments | gotcha | 10/15 |
| GE-20260521-1e95dc | Static test capture list in @ObservesAsync @Mock bean is a data race with the test thread | gotcha | 9/15 |
| GE-20260521-a92d07 | Quarkus extensions using application.properties for defaults ARE overridable — microprofile-config.properties is not | undocumented | 10/15 |
| GE-20260521-a92d07 | Quarkus extensions using application.properties for defaults ARE overridable — microprofile-config.properties is not | undocumented | 10/15 |
| GE-20260521-4fa9cf | IntelliJ VFS refresh silently reverts working-tree file changes after git rebase -i | gotcha | 10/15 |
| GE-20260511-ce1c9d | Java package move breaks wildcard imports and same-package implicit imports — two silent failures | gotcha | 10/15 |
| GE-20260522-f0d1ec | SC2EGSet ToonPlayerDescMap userID is not playerID-1 — game event filter silently returns 0 results | gotcha | 10/15 |
| GE-20260522-eccbde | SC2 replay abilLink IDs are patch-specific — same binary protocol, different ability IDs across SC2 versions | gotcha | 12/15 |
| GE-20260522-a575c3 | Range-bounded modal algorithm for empirical calibration of simulation timing constants from paired event streams | technique | 11/15 |
| GE-20260522-27d097 | SC2 unit training times are integer game loops — the community formula (seconds × 22.4) gives wrong values | undocumented | 11/15 |
| GE-20260522-a69fa1 | Java String.matches() anchors the full string — not a substring search | gotcha | 9/15 |
| GE-20260522-1bc491 | Quarkus @Blocking SSE endpoint auto-wraps Multi<String> items — manual 'data: ' prefix produces double-frame | gotcha | 13/15 |
| GE-20260522-daca26 | Mutiny MultiEmitter.emit() from virtual thread does not flush SSE frames to browser in @Blocking Quarkus endpoint | gotcha | 12/15 |
| GE-20260522-2a4009 | onTermination() on inner Multi in Mutiny concatenation does not fire when outer Multi is cancelled during first stream | gotcha | 11/15 |
| GE-20260522-567cc5 | InMemoryChannelStore.put() auto-assigns UUID — test assertions against explicit channelUuid fail silently | gotcha | 8/15 |
| GE-20260522-adb5cd | Moving @ApplicationScoped bean from Quarkus app module to library JAR silently breaks CDI discovery | gotcha | 8/15 |
| GE-20260522-5685ba | Synchronous CDI Event.fire() in @Observes StartupEvent propagates observer exceptions — can abort Quarkus startup | gotcha | 10/15 |
| GE-20260522-831b53 | Unit test @Observes StartupEvent handlers via package-private method + mocks — avoids @QuarkusTest transaction visibility issues | technique | 10/15 |
| GE-20260522-945518 | JPQL LIKE prefix query treats _ as wildcard — byNamePrefix("case_123") matches "case-123/work" | gotcha | 11/15 |
| GE-20260522-945518 | JPQL LIKE prefix query treats _ as wildcard — byNamePrefix("case_123") matches "case-123/work" | gotcha | 11/15 |
| GE-20260522-5685ba | Synchronous CDI Event.fire() in @Observes StartupEvent propagates observer exceptions — can abort Quarkus startup | gotcha | 10/15 |
| GE-20260522-831b53 | Unit test @Observes StartupEvent handlers via package-private method + mocks — avoids @QuarkusTest transaction visibility issues | technique | 10/15 |
| GE-20260522-99b6a0 | @ApplicationScoped CDI proxy swallows field writes — use @Singleton for test doubles needing direct field access | gotcha | 12/15 |
| GE-20260522-bc642c | ArrayList unsafe for @ObservesAsync test captures — @ObservesAsync dispatches on managed executor thread, not test thread | gotcha | 10/15 |
| GE-20260522-2664b9 | @QuarkusComponentTest silently auto-stubs external beans — use value[] to wire real instances | undocumented | 10/15 |
| GE-20260522-3e2589 | LangChain4j ChatModel cannot be stubbed as a lambda — override doChat(ChatRequest) not chat(ChatRequest) | gotcha | 8/15 |
| GE-20260522-98b286 | ConcurrentHashMap.remove(key, value) uses equals() — reflexive equality on mutable list values creates TOCTOU window | gotcha | 11/15 |
| GE-20260522-6c22a3 | ConcurrentHashMap.computeIfPresent returning null atomically removes the map entry — eliminates TOCTOU in prune-if-empty patterns | technique | 12/15 |
| GE-20260522-1bc491 | Quarkus @Blocking SSE endpoint auto-wraps Multi<String> items — manual 'data: ' prefix produces double-frame | gotcha | 13/15 |
| GE-20260522-0d8d9e | JavaMethod.isSynthetic() does not exist in ArchUnit 1.4.1 — filter by PUBLIC modifier only | gotcha | 9/15 |
| GE-20260522-05f4f1 | ArchUnit rules pass silently when no classes match the that() predicate — vacuous green | gotcha | 10/15 |
| GE-20260522-aa4ff0 | ArchUnit cross-class ArchCondition: capture JavaClasses in outer scope to look up related classes inside check() | technique | 9/15 |
| GE-20260522-3fce33 | Fluent DSL builder using List.set() instead of List.add() silently discards all but the last chained call | gotcha | 9/15 |
| GE-20260522-5ff0b2 | Runnable switch expression pattern gives compile-time exhaustiveness for void dispatch over sealed interfaces in Java 21 | technique | 10/15 |
| GE-20260522-44bbf3 | Uncaught RuntimeException in @Transactional loop rolls back all iterations — silent infinite retry on scheduled jobs | gotcha | 11/15 |
| GE-20260522-e6eb70 | Maven 'cannot access' compile error from peer-repo deleted class — no direct import | gotcha | 10/15 |
| GE-20260522-8df6a6 | Panache MongoDB list() JPQL-style query string is unvalidated — use Filters.in() for $in queries | gotcha | 9/15 |
| GE-20260522-483b67 | Use a compound natural key string as @BsonId to eliminate the MongoDB unique index and get upsert-by-identity for free | technique | 8/15 |
| GE-20260522-e570ee | @Startup @ApplicationScoped + @PostConstruct is the correct pattern for idempotent MongoDB index creation in Quarkus | technique | 9/15 |
| GE-20260522-99d52d | Java 21 pattern-matching switch does not match null with default — NPE without explicit case null arm | gotcha | 11/15 |
| GE-20260522-a87fd7 | Path.parent() returns null for single-segment paths — root scope silently excluded from ancestor walk | gotcha | 12/15 |
| GE-20260522-ac6b1d | Removing a @ConfigMapping method — grep ALL application.properties including integration-tests/ or dead keys survive | gotcha | 10/15 |
| GE-20260522-f63c9f | REQUIRES_NEW commits persist across @TestTransaction rollback — cross-test correlationId contamination in cross-channel ledger queries | gotcha | 13/15 |
| GE-20260522-259812 | Pass a plain record (not JPA entities) across REQUIRES_NEW boundary to eliminate LazyInitializationException | technique | 12/15 |
| GE-20260522-672965 | @JsonInclude and @Nullable cannot annotate records in a framework-free api module — Jackson not on classpath | gotcha | 10/15 |
| GE-20260523-54f02a | quarkus.arc.exclude-types on a non-indexed JAR triggers full JAR scan — activating beans instead of suppressing them | gotcha | 13/15 |
| GE-20260523-afab1d | @ApplicationScoped bean present in JAR bytecode is invisible to Quarkus ARC without a Jandex index | undocumented | 10/15 |
| GE-20260523-c2cca8 | Quartz 'Unable to create Scheduler / Cron expression contains 5 parts' caused by dormant @Scheduled bean becoming active | gotcha | 13/15 |
| GE-20260523-20046c | %prod.quarkus.index-dependency limits JAR indexing to production augmentation — prevents @QuarkusTest CDI side-effects | technique | 10/15 |
| GE-20260523-60365e | Quarkus application module quarkus:build fails CDI validation even when all @QuarkusTests pass — test-scoped deps absent from production classpath | gotcha | 12/15 |
| GE-20260523-51620a | Removed SNAPSHOT API method compiles locally against stale cached jar but fails on CI where fresh SNAPSHOT is resolved | gotcha | 11/15 |
| GE-20260523-53430a | Quarkus Arc resolves CDI cycles between @ApplicationScoped beans via client proxies — even with constructor injection | gotcha | 12/15 |
| GE-20260523-fc50d0 | Unified lazy Supplier combines instance capability tags + synthetic role tag to make ACL checks work for both registered and external senders | technique | 11/15 |
| GE-20260523-fc29ea | Stale qhorus local snapshot causes TABLE NOT FOUND in consuming project @QuarkusTest — schema-generation-strategy mismatch hides root cause | gotcha | 10/15 |
| GE-20260523-7fcea7 | ArchUnit JavaParameterizedType is guaranteed to have ≥1 type argument — isEmpty() guard is dead code | gotcha | 9/15 |
| GE-20260523-0ecc24 | Detect JCA signing algorithm from raw X.509/PKCS8 key bytes via trial-load — no ASN.1 parsing needed | technique | 11/15 |
| GE-20260523-45d97e | @TestTransaction wraps each test in a rolled-back transaction — ledger/audit writes committed during the test become invisible to subsequent queries within the same test | gotcha | 10/15 |
| GE-20260523-722840 | Test that an ArchUnit rule catches a violation using rule.evaluate().hasViolation() — not rule.check() | technique | 9/15 |
| GE-20260523-5b90bf | Maven Surefire -Dtest=: '+' separator silently fails — error says 'No tests matching pattern' | gotcha | 10/15 |
| GE-20260523-80cc31 | Synchronous exceptions thrown inside Mutiny flatMap suppliers are wrapped as failed Uni — works correctly including from Optional.ifPresent() | technique | 10/15 |
| GE-20260523-bd68ba | @ObservesAsync CDI handlers run without the caller's OTel span — traceId silently null on async thread | gotcha | 8/15 |
| GE-20260523-06e8b6 | Panache PanacheEntity.list(query) ignores query limit — loads all rows into heap before Java-side truncation | gotcha | 12/15 |
| GE-20260523-fa7407 | CapabilityHealth probe SPI: ProbeContext.taskDomain ≠ capabilityTag — conflating them silently disables EpistemicallyWeak | gotcha | 8/15 |
| GE-20260523-de55e8 | @ApplicationScoped CDI proxy silently returns empty/null for direct field access — only method calls dispatch to the real bean | gotcha | 12/15 |
| GE-20260523-fc1fe7 | Quarkus bytecode enhancement changes @Entity public fields to protected in test classloader — direct access from non-subclass causes IllegalAccessError | gotcha | 12/15 |
| GE-20260524-cf232c | Quarkus CDI validation fails with reactive service beans from transitive deps unless quarkus.datasource.reactive=false is explicit | gotcha | 10/15 |
| GE-20260524-2b587e | quarkus.arc.selected-alternatives does not activate @Alternative beans during quarkus:build | gotcha | 13/15 |
| GE-20260524-baae14 | Maven BOM scope inheritance: omitting scope in child pom does NOT override parent BOM's test scope | gotcha | 9/15 |
| GE-20260524-122018 | Maven parent POM bootstrap in CI: project's own pom needs <repositories> to resolve the parent | gotcha | 11/15 |
| GE-20260524-d75218 | CDI @Alternative bypass for quarkus:build: non-@Alternative subclass in app module | technique | 13/15 |
| GE-20260524-c1e573 | quarkus.arc.exclude-types silently fails for beans registered by a Quarkus extension | gotcha | 10/15 |
| GE-20260525-a8c35a | SC2 building-type mapper that aliases addon names to parent type silently contaminates calibration modal values | gotcha | 12/15 |
| GE-20260525-1a1a7f | SC2 building construction time calibration requires no command matching — UnitInit/UnitDone tracker events give exact T_real directly | technique | 9/15 |
| GE-20260525-fd4868 | LangChain4j 1.x: ChatLanguageModel renamed to ChatModel; chat() replaced by doChat() as extension point | breaking | 12/15 |
| GE-20260525-80e370 | LangChain4j 1.x UserMessage: text accessor is singleText(), not text() | gotcha | 10/15 |
| GE-20260525-606069 | YAML string values with special chars produce invalid YAML unless single-quoted | gotcha | 9/15 |
| GE-20260525-c24dbe | Java records have deterministic toString() — use SHA-256(record.toString()) for cache-invalidation hashes | technique | 9/15 |
| GE-20260525-d5b5eb | JQ `to_entries | select(expr)` silently fails — select tests the whole array, not individual elements; use `to_entries[]` to iterate | gotcha | 12/15 |
| GE-20260525-6f8b88 | Calling startCase().toCompletableFuture().join() inside @Transactional while holding an Agroal connection causes connection-pool deadlock under JPA engine persistence | gotcha | 13/15 |
| GE-20260525-4e0b24 | Java method references from different call sites produce distinct JVM objects — IdentityHashMap keyed by accessor fails across rules | gotcha | 10/15 |
| GE-20260525-8c0ba2 | AtomicInteger refcount + record CTX re-application removes per-unit tracking for pub/sub adapter cleanup | technique | 9/15 |
| GE-20260525-531f36 | Google-style test method naming: subject_state with one underscore, lowerCamelCase components | convention | 8/15 |
| GE-20260525-65a5c1 | LOG.debugf on high-frequency CDI observer early-return paths floods logs and buries the events you care about | gotcha | 10/15 |
| GE-20260525-00cbde | Remove JAX-RS coupling from @ApplicationScoped service beans using inner static domain exception classes | technique | 9/15 |
| GE-20260525-c942c0 | @Transactional on a coordinator writing to two Quarkus datasources attempts XA — H2 rejects it with a misleading connection error | gotcha | 11/15 |
| GE-20260525-56c580 | Freezing simulation entities mid-test by setting movement target to current position only works if the movement system does not remove targets on arrival | technique | 9/15 |
| GE-20260525-c01bb4 | String.equals(null) is null-safe (returns false) — NPE comes from the receiver, not the argument | gotcha | 9/15 |
| GE-20260525-55d8f6 | Mutiny idiom for synchronous delegation: invoke(delegate::method).replaceWithVoid(), not call-then-return-voidItem | technique | 9/15 |
| GE-20260525-a8bd9a | quarkus-langchain4j AiServicesProcessor throws 'Duplicate key null' when -parameters javac flag is missing | gotcha | 12/15 |
| GE-20260525-99837c | PostgreSQL UNIQUE constraint creates an implicit B-tree index usable for prefix scans — no separate CREATE INDEX needed | undocumented | 11/15 |
| GE-20260526-fa0e3e | CasePlanModel.getPlanItemByBindingName() silently excludes terminal PlanItems — completed bindings always re-dispatch | undocumented | 10/15 |
| GE-20260526-a5bbd2 | LedgerEntry.attach() sets supplement.ledgerEntry = this — bidirectional back-reference handled automatically | undocumented | 9/15 |
| GE-20260526-5247f2 | ChannelService.create() does not register the channel in ChannelGateway — fanOut() silently does nothing | gotcha | 10/15 |
| GE-20260526-f8e3bf | MessageService.pollAfter(channelId, 0L, limit) returns all messages — afterId=0 matches all stored IDs | undocumented | 8/15 |
| GE-20260526-3c8553 | @WithSession CDI interceptor swallows synchronous throws — failures propagate via Uni, not caller stack | gotcha | 8/15 |
| GE-20260526-399a43 | quarkus-rest (RESTEasy Reactive) + JDBC Panache requires @Blocking on resource classes — tests pass without it, production degrades silently | gotcha | 12/15 |
| GE-20260526-cacddb | UniAsserter.assertFailedWith has a Consumer<Throwable> overload for message assertion | technique | 9/15 |
| GE-20260526-a08a81 | Quarkus MicroProfile REST Client throws WebApplicationException on non-2xx when return type is Response | gotcha | 14/15 |
| GE-20260526-5a7d46 | jakarta.ws.rs.core.Response does not implement AutoCloseable — try-with-resources fails to compile | gotcha | 10/15 |
| GE-20260526-286ac7 | Use QuarkusTestResourceLifecycleManager to inject WireMock dynamic port before REST client configuration | technique | 9/15 |
| GE-20260526-43a51d | Maven incremental compile silently passes after changing a record's component count in an installed jar | gotcha | 12/15 |
| GE-20260526-08e14c | JPQL atomic increment (UPDATE SET count = count + 1) is simpler than @Version OCC for single-counter atomicity | technique | 11/15 |
| GE-20260526-e21a7c | JPA @PrePersist enrichers can be made idempotent by null-guarding existing field values | undocumented | 9/15 |
| GE-20260526-bfc589 | REST Assured Instant equality fails intermittently — Jackson and Instant.toString() diverge on sub-second precision | technique | 11/15 |
| GE-20260526-1653dc | @All List<T> in Quarkus/ArC gives testable multi-bean injection without Instance<T> | technique | 12/15 |
| GE-20260527-714661 | PostgreSQL LISTEN/NOTIFY @QuarkusTest: subscribe to unfiltered stream to confirm channel active before asserting on filtered results | technique | 11/15 |
| GE-20260522-daca26 | Mutiny MultiEmitter.emit() from Vert.x I/O thread silently drops SSE frames in @Blocking Quarkus endpoint | gotcha | 12/15 |
| GE-20260527-8c3ff5 | Merging two transformToUniAndConcatenate Mutiny streams allows concurrent DB fetches — duplicate SSE frames delivered | gotcha | 12/15 |
| GE-20260527-cad5ba | Place fireAsync() before internal dispatch to decouple delivery paths in @Transactional methods | technique | 11/15 |
| GE-20260423-daef97 | CDI event.fire() does not deliver to @ObservesAsync observers — fireAsync() required separately | gotcha | 13/15 |
| GE-20260528-74914d | @Blocking rejected on @ApplicationScoped CDI bean methods returning Uni — only valid on framework entrypoints | gotcha | 13/15 |
| GE-20260528-f0a75c | @DefaultBean BlockingToReactiveBridge — wrap any blocking SPI as reactive, displaced by native async @Alternative | technique | 12/15 |
| GE-20260528-55a526 | Extract security enforcement to a static utility when it must be callable from both blocking and reactive-only SPI adapters | technique | 10/15 |
| GE-20260528-d4b81d | casehub-engine SNAPSHOT: internal package refactor breaks VertxProcessor augmentation — masked by cached augmentation | gotcha | 13/15 |
| GE-20260528-35a81c | WorkItemPriority has no NORMAL value — enum values are LOW, MEDIUM, HIGH, URGENT; NORMAL causes Hibernate IllegalArgumentException at read time | gotcha | 11/15 |
| GE-20260528-936918 | Response.Status.UNPROCESSABLE_ENTITY doesn't exist in Jakarta EE 9 JAX-RS — use raw integer 422 | gotcha | 9/15 |
| GE-20260528-3d3847 | @Transactional on @BeforeAll static methods in @QuarkusTest has no effect — CDI interceptors cannot intercept static methods; results in ContextNotActive at runtime | gotcha | 12/15 |
| GE-20260528-c968e2 | Inject ExpiryLifecycleService directly in @QuarkusTest to test SLA breach without scheduler interference | technique | 11/15 |
| GE-20260528-3b9ccb | Sc2ReplayShared.makeTag() uses r- prefix — breaks IEM10 JSON tag construction | gotcha | 9/15 |
| GE-20260528-6ebb38 | SC2EGSet JSON replays emit an extra UnitBorn at loop 0 in some games — breaks strict initial unit count check | gotcha | 8/15 |
| GE-20260528-f89f62 | SC2EGSet JSON training commands identified by data: {None: null} — not documented anywhere | undocumented | 9/15 |
| GE-20260528-ed3022 | Quarkus FlywayConfigurationCustomizer runtime location additions silently ignored by QuarkusPathLocationScanner | gotcha | 12/15 |
| GE-20260528-5e2fb5 | Stale target/classes/ from git mv of resource files causes false-positive test passes — migrations silently run from old path | gotcha | 10/15 |
| GE-20260528-8e51f1 | NativeImageResourcePatternsBuildItem constructor and includePatterns() are deprecated in Quarkus 3.x — use builder().includeGlob() | undocumented | 8/15 |
| GE-20260528-fa4655 | Quarkus FlywayConfigurationCustomizer without @FlywayDataSource applies to default datasource only — not all datasources | undocumented | 10/15 |
| GE-20260528-e9564b | LangChain4j Anthropic: ResponseFormat.JSON without schema throws UnsupportedFeatureException — not a degradation | undocumented | 14/15 |
| GE-20260528-e9ed9f | LLM renderer cache key must hash all output-affecting context, not just LLM input fields | gotcha | 12/15 |
| GE-20260528-1e92db | Capture @ConfigProperty field as final local before anonymous-class capture in @PostConstruct | technique | 10/15 |
| GE-20260529-c6ff44 | Math.abs(0.8 - 0.7) > 0.1 in Java IEEE 754 — exact decimal boundary tests fail silently | gotcha | 9/15 |
| GE-20260529-c4ed43 | Shared @ApplicationScoped CDI bean as algorithmic kernel across @Alternative @Priority strategy implementations | technique | 9/15 |
| GE-20260529-ff186e | emitOn(Infrastructure.getDefaultWorkerPool()) — correct way to shift blocking I/O off Vert.x IO thread in a reactive SPI | technique | 9/15 |
| GE-20260529-37764f | OptionalDouble over double+NaN sentinel for absent numeric primitives in records | technique | 8/15 |
| GE-20260529-9d2ad0 | Panache count(String, Object...) prepends FROM Entity WHERE — passing 'WHERE predicate' causes double-WHERE syntax error | gotcha | 10/15 |
| GE-20260529-18fc5f | Quarkus QuarkusTestProfile.getConfigProfile() REPLACES %test profile — production application.properties becomes active, Dev Services cannot inject URLs | gotcha | 9/15 |
| GE-20260529-010101 | @Transactional(REQUIRES_NEW) try-catch doesn't intercept commit-time exceptions — they escape as ArcUndeclaredThrowableException | gotcha | 12/15 |
| GE-20260529-78ecb9 | @QuarkusTest methods calling Panache.withTransaction() on JUnit thread fail with 'No current Vertx context' — use @RunOnVertxContext + UniAsserter | gotcha | 9/15 |
| GE-20260529-ab148d | Multiple CDI constructors without @Inject → UnsatisfiedResolutionException for the bean itself, not a constructor | gotcha | 12/15 |
| GE-20260529-c1e783 | Dual-constructor CDI pattern: @Inject CDI constructor delegates to package-private test constructor accepting Consumer<T> instead of Event<T> | technique | 11/15 |
| GE-20260529-709049 | Java 21 sealed interface with nested records requires no explicit permits clause | undocumented | 9/15 |
| GE-20260529-d57945 | JAX-RS HttpHeaders.getRequestHeaders() preserves original case — must normalise to lower-case at the boundary for HTTP header lookup | gotcha | 10/15 |
| GE-20260529-9f3557 | @TestTransaction + JPA auto-flush makes store-seam compliance tests pass before the fix is applied | gotcha | 11/15 |
| GE-20260529-fef800 | casehub-engine in-memory: CaseCompleted CDI event unreliable in @QuarkusTest — GoalReached fires first and is more reliable | gotcha | 9/15 |
| GE-20260529-b994c2 | Uni.createFrom().item(supplier) with emitOn() — supplier still runs on the subscription thread | gotcha | 12/15 |
| GE-20260529-a4dadf | Maven test-jar export for cross-module abstract contract test sharing | technique | 11/15 |
| GE-20260529-166347 | @TestTransaction at class level rolls back all inherited abstract test methods in @QuarkusTest | technique | 10/15 |
| GE-20260520-c0e5b4 | Podman on macOS requires explicit DOCKER_HOST for Testcontainers — no /var/run/docker.sock without podman-mac-helper | gotcha | 13/15 |
| GE-20260529-b510e4 | @Transactional on @ObservesAsync observer fires on every event, exhausting DB connections even when body returns early | gotcha | 12/15 |
| GE-20260529-586849 | io.casehub.qhorus.runtime.channel.Channel — entity is in runtime.channel not runtime.model | gotcha | 9/15 |
| GE-20260529-24cb03 | ChannelService.findByName(String) and findById(UUID) exist for exact-match channel lookup | undocumented | 9/15 |
| GE-20260529-d1397c | Observing ChannelInitialisedEvent gives Qhorus ChannelBackend free startup recovery | technique | 10/15 |
| GE-20260529-88b7b6 | ChannelService.create() is not idempotent — use findByName() before create() for idempotent openChannel() | gotcha | 9/15 |
| GE-20260529-8e127e | @Transactional on @QuarkusTest methods commits data — use @TestTransaction for rollback isolation | gotcha | 11/15 |
| GE-20260529-bc1eaa | TIMESTAMPTZ not recognised by H2 in MODE=PostgreSQL — use TIMESTAMP WITH TIME ZONE | gotcha | 10/15 |
| GE-20260529-7985ba | quarkus.flyway.migrate-at-start defaults to false — must be set explicitly in @QuarkusTest application.properties | gotcha | 10/15 |
| GE-20260529-a488bf | Jakarta Mail MimeMessage defaults to text/plain until saveChanges() is called — isMimeType() is wrong on freshly-constructed messages | gotcha | 13/15 |
| GE-20260529-636a36 | JAX-RS @Provider exception mapper bypassed when exception extends a type caught by a generic resource handler | gotcha | 9/15 |
| GE-20260529-6eccfe | Strict-on-write / lenient-on-read parse modes for deploying type constraints against existing data | technique | 9/15 |
| GE-20260529-5a8158 | Quarkus @ConfigMapping strict mode rejects @ConfigProperty keys under the same prefix from other CDI beans | gotcha | 9/15 |
| GE-20260529-bfa5d5 | WatchdogAlertEvent carries no correlationId — observer must query by notificationChannel | gotcha | 14/15 |
| GE-20260529-e32a4d | MessageDispatch.Builder.build() requires actorType — omitting it throws IllegalArgumentException | gotcha | 13/15 |
| GE-20260529-aa8445 | GreenMailExtension has no public deliver() method — MimeMessage delivery requires SMTP or internal MailFolder.appendMessage() | gotcha | 11/15 |
| GE-20260529-72f189 | Greenmail fixed ports (ServerSetupTest.SMTP_IMAP) conflict when @QuarkusTestResource and @RegisterExtension both run in the same Maven test execution | gotcha | 9/15 |
| GE-20260529-dbea23 | Greenmail SMTP server silently adds Message-ID header — tests asserting header absence must bypass SMTP | gotcha | 9/15 |
| GE-20260529-4691e8 | Deliver MimeMessage directly to Greenmail IMAP mailbox (bypassing SMTP) using MailFolder.appendMessage() | technique | 10/15 |
| GE-20260529-59d35a | GreenMailExtension.getGreenMail() is protected — inaccessible from test code without subclassing | undocumented | 8/15 |
| GE-20260529-baf565 | @ObservesAsync observers are silently skipped when the event source uses Event.fire() | gotcha | 12/15 |
| GE-20260529-d8156d | ConcurrentHashMap.computeIfAbsent blocks all same-bucket keys while mapping function runs — unusable for network calls | gotcha | 13/15 |
| GE-20260529-8eb96e | Java .properties colon is a key-value separator — actorId strings like 'claude:reviewer@v1' silently split at the colon | gotcha | 11/15 |
| GE-20260529-04a5a5 | WireMock 3.x wireMockServer.verify() takes RequestPatternBuilder not MappingBuilder — get() vs getRequestedFor() confusion | gotcha | 9/15 |
| GE-20260529-0b8284 | Uni.createFrom().emitter() is wrong for one-shot callback bridging — use completionStage() + CompletableFuture.orTimeout() | gotcha | 9/15 |
| GE-20260529-0c80ca | LangChain4j StreamingChatModel: mock doChat() not chat() — default chat() wraps handler in observingHandler before calling doChat() | undocumented | 8/15 |
| GE-20260529-d7b6f8 | TrustBootstrapSource SPI is never invoked on a fresh deployment | gotcha | 11/15 |
| GE-20260513-b15933 | @ObservesAsync CDI events are silently not delivered in @QuarkusTest — call observer directly | gotcha | 11/15 |
| GE-20260529-e43076 | Await CDI fireAsync() delivery in @ConsumeEvent reactive chain via Uni.createFrom().completionStage() | technique | 11/15 |
| GE-20260529-d3d4b6 | PLATFORM.md documents MessageDispatch.builder() as positional-args factory — actual API is no-arg builder with chained setters | gotcha | 10/15 |
| GE-20260526-e21a7c | JPA @PrePersist enrichers can be made idempotent by null-guarding existing field values | undocumented | 9/15 |
| GE-20260529-a2095c | quarkus-playwright shared BrowserContext + unclosed pages exhausts SSE connection pool by test 3 | gotcha | 12/15 |
| GE-20260530-3562b0 | ExceptionMapper<IllegalArgumentException> does not catch compact constructor violations during Jackson deserialization — Jackson wraps them as ValueInstantiationException | gotcha | 15/15 |
| GE-20260530-29545c | Quarkiverse WireMock 1.4.1 incompatible with Quarkus 3.32.2 — TypeNotPresentException on GlobalDevServicesConfig$Enabled | gotcha | 12/15 |
| GE-20260530-b68c00 | Maven caches GitHub Packages 401 failure in *.lastUpdated markers — fixing auth alone doesn't unblock resolution | gotcha | 10/15 |
| GE-20260530-0178fd | Quarkus @QuarkusTest augmentation requires extension deployment JARs in ~/.m2 — mvn compile/test-compile is insufficient | gotcha | 11/15 |
| GE-20260530-385dbb | @Provider @ApplicationScoped on ClientRequestFilter bypasses CDI injection in Quarkus @RegisterRestClient | gotcha | 12/15 |
| GE-20260530-01bcfe | JPA @Column(nullable=false) NOT NULL violation fires at REQUIRES_NEW commit (flush), not at save() | gotcha | 12/15 |
| GE-20260530-7426b7 | Use a naturally-nullable column to distinguish failure modes instead of making a NOT NULL column nullable | technique | 9/15 |
| GE-20260530-da427e | Quarkus multi-PU sub-package matching assigns LedgerEntry subclass entities to the wrong persistence unit | gotcha | 12/15 |
| GE-20260530-5e5c67 | runSubscriptionOn(workerPool) in a reactive adapter deadlocks when callers are already on the worker pool | gotcha | 14/15 |
| GE-20260530-0dc6de | casehub-ledger LedgerProcessor doesn't self-register db/ledger/migration/*.sql for native image | gotcha | 11/15 |
| GE-20260518-bee1b3 | Virtual-thread offload + CDI self-injection: pattern for safe blocking JPA in a reactive pipeline | technique | 11/15 |
| GE-20260530-1ce875 | Set.of().contains(null) throws NullPointerException — unlike HashSet which returns false | gotcha | 11/15 |
| GE-20260530-4359ee | AbstractMethodError at runtime after mvn -U pulls newer SNAPSHOT — testing artifact compiled against old interface | gotcha | 11/15 |
| GE-20260530-1a7e84 | casehub-qhorus MessageDispatch.builder() requires inReplyTo + correlationId for response-type messages (DONE, DECLINE, RESPONSE, FAILURE) | gotcha | 9/15 |
| GE-20260530-4387cb | casehub-qhorus MessageService methods using Panache static calls bypass InMemory store in @QuarkusTest — @InjectSpy required | gotcha | 8/15 |
| GE-20260530-3cc195 | String.format("%.4f") uses JVM default locale — use Locale.ROOT for canonical decimal formatting | gotcha | 12/15 |
| GE-20260530-02ef50 | Breaking API changes in multi-module Java projects require updating test files across ALL modules, not just the changed module | gotcha | 9/15 |
| GE-20260530-5400f3 | Hibernate 6 supports List<String> parameters in native SQL IN clauses via setParameter(name, Collection) | undocumented | 12/15 |
| GE-20260530-a14b49 | Narayana JTA: registerInterposedSynchronization throws on ROLLBACK_ONLY — 'state 1' is not STATUS_ACTIVE | gotcha | 11/15 |
| GE-20260530-c13942 | CDI event observers in @QuarkusTest test classpath do not reliably receive synchronous Event.fire() from production code — use Mockito unit tests instead | gotcha | 9/15 |
| GE-20260521-3e030b | mvn test-compile -pl runtime succeeds but test runtime fails with NoClassDefFoundError after moving types to api module — installed jar is stale | gotcha | 10/15 |
| GE-20260530-9cdfb5 | MapPreferences.get() returns null when key absent — PreferenceKey.defaultValue is never used as fallback | gotcha | 10/15 |
| GE-20260530-0bee65 | Plain JAR (non-Quarkus extension) does not auto-register Flyway migrations — consumers must configure locations explicitly | gotcha | 9/15 |
| GE-20260530-9b5bbe | Per-field PreferenceKey<T> pattern for YAML-backed structured config avoids opaque single-string encoding | technique | 9/15 |
| GE-20260531-dd44a2 | @Path("/") root resource captures all paths in Quarkus RESTEasy Reactive — specific endpoints return 404 | gotcha | 9/15 |
| GE-20260531-70e07c | Quarkus test-profile arc.exclude-types does not apply to production augmentation — mvn test passes, mvn install fails | gotcha | 10/15 |
| GE-20260531-c41c7f | Part.getInputStream() throws UnsupportedDataTypeException for binary MIME parts constructed in-memory — use getContent() and dispatch on type | gotcha | 10/15 |
| GE-20260531-ed2f7a | @Transactional @ObservesAsync try/catch: caught exception enables outer TX commit — REQUIRES_NEW fallback also commits, double-recording the event | gotcha | 12/15 |
| GE-20260531-5137f7 | mvn install reports BUILD SUCCESS on wrong git branch — installed jar silently missing new class | gotcha | 11/15 |
| GE-20260531-9118e7 | runtime Maven scope on a shared mock library silently expands CDI scan, breaking @DefaultBean suppression | gotcha | 11/15 |
| GE-20260531-1ec900 | Quarkus ARC registers non-CDI abstract class as @Dependent bean when it declares @Observes and implements a CDI SPI interface | gotcha | 12/15 |
| GE-20260531-a6bd23 | SmallRye Config rejects @WithDefault("") for plain String @ConfigMapping methods — use Optional<String> instead | gotcha | 10/15 |
| GE-20260531-e1ce47 | CDI @Observes and @ObservesAsync are separate delivery channels — @Observes never receives fireAsync() events | gotcha | 11/15 |
| GE-20260531-0f0688 | Strengthen cache-eviction integration tests: change the stub, assert the new value — not just call count | technique | 9/15 |
| GE-20260531-2ec49a | IMAPFolder.idle(boolean once) — once=false blocks indefinitely; once=true returns after first notification | gotcha | 9/15 |
| GE-20260531-6298f4 | RESTEasy Reactive Multi<String> with text/event-stream auto-wraps each item as 'data: <string>\n\n' | undocumented | 10/15 |
| GE-20260531-18fa72 | Package-private members in a JAR are accessible from the same package name in a different JAR on a flat classpath | technique | 9/15 |
| GE-20260531-6298f4 | RESTEasy Reactive Multi<String> with text/event-stream auto-wraps each item as 'data: <string>\n\n' | undocumented | 10/15 |
| GE-20260531-6298f4 | RESTEasy Reactive Multi<String> with text/event-stream auto-wraps each item as 'data: <string>\n\n' | undocumented | 10/15 |
| GE-20260531-4354e3 | JSON substring completeness check silently always-passes for JSON output formats | gotcha | 11/15 |
| GE-20260531-686150 | Adding a member to an enum dimension set breaks evaluators that iterate EvalDimension.values() | gotcha | 11/15 |
| GE-20260531-5e6553 | Put format-to-dimension mapping on the enum as a static factory method shared by all consumers | technique | 9/15 |
| GE-20260531-afc422 | Name output format enums after structure (MARKDOWN, PROSE, JSON), not LLM provider | convention | 9/15 |
| GE-20260531-2ca323 | HikariCP addDataSourceProperty cannot set a Properties object on SQLiteDataSource — PropertyElf reflection coercion fails | gotcha | 10/15 |
| GE-20260531-db10ab | SQLite TEXT timestamp ordering breaks with variable ISO-8601 fractional-second digits — Instant.toString() is not safe for lexicographic sort | gotcha | 11/15 |
| GE-20260531-20d80a | Correct HikariCP + xerial SQLite PRAGMA configuration — SQLiteConfig as pre-built DataSource, not addDataSourceProperty | technique | 10/15 |
| GE-20260531-df79cb | SQLite FTS5 content-table pattern — live full-text index maintained by triggers, ranked by built-in BM25 column | technique | 10/15 |
| GE-20260531-ac2489 | quarkus-mcp-server @ToolArg is rejected on @ResourceTemplate methods — IllegalStateException at augmentation | gotcha | 11/15 |
| GE-20260531-769f9c | casehub-ledger updateGlobalTrustScore() is a silent no-op for new actors — use upsert() to seed trust scores in tests | gotcha | 10/15 |
| GE-20260531-bd4b53 | quarkus-langchain4j-anthropic 0.26.1 fails with 'Run time configuration cannot be consumed in Build Steps' on Quarkus 3.33+ | gotcha | 9/15 |
| GE-20260508-3a77c5 | Quarkus multi-module: mvn compile fails with NoSuchFileException when api/ submodule has no sources yet | gotcha | 12/15 |
| GE-20260601-8ff52b | Surefire rerunFailingTestsCount + JUnit 5 assumeTrue — skip on retry does not override initial failure | gotcha | 8/15 |
| GE-20260601-17fa50 | PSQLException extends java.sql.SQLException — not SQLIntegrityConstraintViolationException — so instanceof catches miss in production PostgreSQL | gotcha | 14/15 |
| GE-20260601-13fc26 | JAX-RS §4.2.4: IOException from message body reader bypasses all exception mappers | gotcha | 12/15 |
| GE-20260601-0eb1b6 | Quarkus augmentation cache masks @DefaultBean CDI conflicts — only surfaces on clean builds or targeted test runs | gotcha | 9/15 |
| GE-20260601-3dbc80 | quarkus.arc.exclude-types resolves @DefaultBean ambiguity between two Jandex-indexed framework JARs | technique | 9/15 |
| GE-20260601-a35fb3 | InMemoryCaseInstanceRepository.findByUuid(UUID, String) silently returns null when stored tenancyId is null — NPE buried as Suppressed in ConditionTimeoutException | gotcha | 11/15 |
| GE-20260601-b76fba | QuarkusTestResourceLifecycleManager.start() silently ignores build-time fixed properties | gotcha | 11/15 |
| GE-20260601-7a3b38 | @DefaultBean implementations invisible to CDI when their supertype JAR has no Jandex index | gotcha | 12/15 |
| GE-20260601-b9a489 | Quarkus extension descriptor validation reads installed .m2 deployment JAR, not source pom — stale cache causes false 'missing dependencies' failure | gotcha | 9/15 |
| GE-20260601-7a3b38 | @DefaultBean implementations invisible to CDI when their supertype JAR has no Jandex index | gotcha | 12/15 |
| GE-20260601-ad6203 | Quarkus ARC validates disabled-feature bean dep chains at augmentation time — quarkus.arc.exclude-types must cover the whole chain | gotcha | 10/15 |
| GE-20260601-33dd8e | @Alternative @Priority(N) from external library JAR does not auto-win over @ApplicationScoped default in Quarkus ARC 3.x — needs selected-alternatives | gotcha | 9/15 |
| GE-20260601-aa7b04 | TDD for constant renames — write a PASS test first to pin existing behaviour | technique | 11/15 |
| GE-20260601-848232 | quarkus.arc.exclude-types silently does nothing for beans from Jandex-indexed JARs | gotcha | 12/15 |
| GE-20260601-cee623 | QuarkusTestProfile.getEnabledAlternatives() replaces quarkus.arc.selected-alternatives — does not merge | gotcha | 12/15 |
| GE-20260601-81be07 | Resolve CDI ambiguity between two competing @DefaultBean implementations by introducing a concrete non-default bean | technique | 9/15 |
| GE-20260601-08a351 | quarkus-oidc-client on the classpath triggers Keycloak DevServices even when tests use static token auth | gotcha | 10/15 |
| GE-20260529-5a8158 | Quarkus @ConfigMapping strict mode rejects @ConfigProperty keys under the same prefix from other CDI beans | gotcha | 9/15 |
| GE-20260601-fcf0d9 | Two @DefaultBean beans for the same type → Quarkus AmbiguousResolutionException, not Unsatisfied | gotcha | 12/15 |
| GE-20260601-6170a6 | Java record: inserting a field in the middle shifts all subsequent positional arguments — callers compile but pass wrong values | gotcha | 12/15 |
| GE-20260530-4387cb | casehub-qhorus MessageService methods using Panache static calls bypass InMemory store in @QuarkusTest | gotcha | 8/15 |
| GE-20260602-e7824c | Convert sealed interface to enum when all variants become stateless after refactoring | technique | 8/15 |
| GE-20260601-85afd0 | Three-check quality sweep for ARC42STORIES.MD after generation from LAYER-LOG | technique | 13/15 |
| GE-20260601-b0eabf | ARC42STORIES.MD Key files class names may not exist in production — verify with find | gotcha | 12/15 |
| GE-20260601-c09f71 | ARC42STORIES.MD §12 issue references stale at migration time — verify before publishing | gotcha | 11/15 |
| GE-20260601-b0eabf | ARC42STORIES.MD Key files class names may not exist in production — verify with find | gotcha | 12/15 |
| GE-20260601-c09f71 | ARC42STORIES.MD §12 issue references stale at migration time — verify before publishing | gotcha | 11/15 |
| GE-20260601-85afd0 | Three-check quality sweep for ARC42STORIES.MD after generation from LAYER-LOG | technique | 13/15 |
| GE-20260602-2cff5e | Jackson cannot set absent YAML key into primitive boolean record field — MismatchedInputException misdirects to field type | gotcha | 11/15 |
| GE-20260602-a4d290 | new ObjectMapper(new YAMLFactory()) silently produces null record fields — findAndRegisterModules() required | undocumented | 11/15 |
| GE-20260602-f2ca07 | Pass rendered.content() not the eval case to a blind judge — prevents descriptor from leaking into LLM payload | technique | 10/15 |
| GE-20260602-286f16 | Mutiny Infrastructure.getDefaultBlockingExecutor() does not exist — use getDefaultExecutor() | gotcha | 9/15 |
| GE-20260602-793302 | Checkstyle AvoidStarImport applies to static imports — test assertion methods caught | gotcha | 8/15 |
| GE-20260602-bacaf2 | Cross-repo Maven multi-module: modifying a SPI in repo A requires mvn install before repo B compiles | gotcha | 9/15 |
| GE-20260602-047ac4 | Visitor/accumulator pattern for thread-safe multi-backend aggregation — typed methods replace shared response objects | technique | 10/15 |
| GE-20260602-c4a68a | Dual-constructor aggregator: CDI constructor with ManagedExecutor + package-private test constructor for plain JUnit | technique | 9/15 |
| GE-20260602-6cfbdb | ConcurrentHashMap.put() rejects null values — breaks fault-tolerance catch blocks that use e.getMessage() | gotcha | 12/15 |
| GE-20260602-c38360 | PanacheQuery.stream() does not exist in Quarkus Hibernate Reactive Panache | gotcha | 10/15 |
| GE-20260602-488fa9 | Mutiny collect().in() takes BiConsumer (void mutation), not BiFunction — functional fold functions don't compose directly | gotcha | 9/15 |
| GE-20260602-6941d6 | Separate @ApplicationScoped @Transactional delegate controls commit timing — ensures writes are visible before outer method returns | technique | 11/15 |
| GE-20260602-298736 | Uni.createFrom().item(supplier) with null-returning lambda infers Uni<Object> — use .<Void>item(...) type witness | gotcha | 8/15 |
| GE-20260602-fd91cb | jakarta.ws.rs.@Path conflicts with custom Path type in JAX-RS resources — must use fully qualified name | gotcha | 10/15 |
| GE-20260602-9eb73f | Java record toString() in REST response maps returns type representation, not value — silently corrupts output | gotcha | 11/15 |
| GE-20260602-63b535 | JPA @Converter(autoApply = true) globally converts all fields of that type — use autoApply = false for value types shared with non-entity contexts | gotcha | 9/15 |
| GE-20260602-dfc29a | Awaitility failMessage() does not exist in 4.3.0 — embed message via assertThat().as() inside untilAsserted() | gotcha | 9/15 |
| GE-20260529-4691e8 | Deliver MimeMessage directly to Greenmail IMAP mailbox (bypassing SMTP) using MailFolder.appendMessage() | technique | 10/15 |
| GE-20260602-093fea | @Blocking on plain CDI @ApplicationScoped service methods is invalid in Quarkus 3 — only framework entrypoints support it | gotcha | 10/15 |
| GE-20260602-f8c7db | claude-agent-sdk-java (spring-ai-community) is not published to Maven Central — JitPack required | gotcha | 9/15 |
| GE-20260602-093fea | @Blocking on plain CDI @ApplicationScoped service methods is invalid in Quarkus 3 — only framework entrypoints support it | gotcha | 10/15 |
| GE-20260602-f8c7db | claude-agent-sdk-java (spring-ai-community) is not published to Maven Central — JitPack required | gotcha | 9/15 |
| GE-20260602-9ae24a | @ObservesAsync REQUIRES_NEW write added to a listener causes intermittent findBySubjectId count failure in unrelated @QuarkusTest | gotcha | 10/15 |
| GE-20260603-d67333 | PostgreSQL SET LOCAL rejects JDBC bind parameters — string interpolation required | gotcha | 13/15 |
| GE-20260603-268164 | quarkus:build on a library JAR module forces CDI validation on compile-scope classpath only — spurious 'Unsatisfied dependency' errors | gotcha | 11/15 |
| GE-20260603-1559a3 | Quarkus Dev Services PostgreSQL creates a superuser — FORCE ROW LEVEL SECURITY is silently bypassed in integration tests | gotcha | 12/15 |
| GE-20260603-4b1d1b | quarkus.datasource.devservices.init-script-path pre-creates PostgreSQL roles before tests run | technique | 9/15 |
| GE-20260603-d7aa80 | Mutiny Multi.createBy().merging() waits for ALL upstreams — wrong for wall-clock timeout | gotcha | 15/15 |
| GE-20260603-b17e57 | Scheduled subprocess closure for wall-clock timeout in subprocess-backed reactive streams | technique | 14/15 |
| GE-20260603-fdc6d5 | @Startup @ApplicationScoped prevents blocking @PostConstruct from running on Vert.x IO thread | technique | 13/15 |
| GE-20260603-1c03a1 | Mutiny Multi.createFrom().publisher() requires Flow.Publisher — JdkFlowAdapter needed for Reactor Flux | gotcha | 11/15 |
| GE-20260603-301b80 | langchain4j-agentic DeclarativeUtil has a single CDI resolver hook for @ChatModelSupplier only — no equivalent for other supplier types | undocumented | 12/15 |
| GE-20260603-8f582a | Java nested wildcard inference: List.of() with wildcards fails assignment to List<? extends Foo<?>> | gotcha | 11/15 |
| GE-20260603-f32ff2 | @Transactional catch block cannot prevent TransactionalException from propagating to the caller | gotcha | 10/15 |
| GE-20260603-dfcecc | Fail-open + @Transactional atomicity: extract write pair to a separate CDI bean | technique | 9/15 |
| GE-20260603-7ea359 | Qhorus ChannelProjection<S> implementations need no CDI annotations — discovered by Qhorus via SPI at startup | undocumented | 9/15 |
| GE-20260603-86f2a9 | H2 2.4.x in MODE=PostgreSQL does not support INSERT ... ON CONFLICT DO NOTHING | gotcha | 9/15 |
| GE-20260603-83883c | JBoss LogManager handler chain reset during Quarkus test bootstrap — startup event logs not captured | gotcha | 11/15 |
| GE-20260603-753526 | Binary else on multi-value enum silently misclassifies — CREATED events produced FLAGGED attestations | gotcha | 13/15 |
| GE-20260603-5a5cc0 | ConfigFilePreferenceProvider returns empty Preferences when YAML file is missing from classpath — no error | gotcha | 9/15 |
| GE-20260603-ed5e47 | Package-private concurrent-state accessor enables deterministic Awaitility polling instead of Thread.sleep | technique | 9/15 |
