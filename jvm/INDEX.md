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
