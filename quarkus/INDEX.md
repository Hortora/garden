# quarkus Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0031 | `<packaging>quarkus</packaging>` in pom.xml is non-standard and causes tooling issues — Quarkus doesn't generate it | undocumented | 12/15 |
| GE-0032 | Quarkus `@Scheduled` allows overlapping executions by default — no warning, just a race | gotcha | 13/15 |
| GE-0033 | Use `@UnlessBuildProfile("prod")` to strip debug/QA beans from production at CDI level | technique | 14/15 |
| GE-0036 | @ApplicationScoped bean state accumulates across @QuarkusTest classes in the same run | gotcha | 15/15 |
| GE-0045 | Quarkus WebAuthn config keys use wrong names — silently ignored, no warning | gotcha | 12/15 |
| GE-0046 | WebAuthn session cookie encryption key is `quarkus.http.auth.session.encryption-key` — not documented in WebAuthn extension docs | gotcha | 13/15 |
| GE-0047 | Use javap to find the actual Quarkus config property name from a field annotation | technique | 12/15 |
| GE-0052 | `@UnlessBuildProfile` has undocumented `anyOf` attribute for multi-profile exclusion | gotcha | 12/15 |
| GE-0062 | `HttpAuthenticationMechanism` injections resolve before `@Observes StartupEvent` fires | gotcha | 13/15 |
| GE-0065 | Quarkus `quarkus:dev` silently skips and returns BUILD SUCCESS if the `build` goal is missing from plugin executions | gotcha | 13/15 |
| GE-0066 | `@UnlessBuildProfile` on a bean causes "Unsatisfied dependency" in any bean that injects it without a matching profile guard | gotcha | 13/15 |
| GE-0068 | Quarkus Flow `consume` steps re-deserialize input — mutable mutations don't propagate | gotcha | 14/15 |
| GE-0069 | Quarkus Flow: plain mutable POJO as workflow input → `FAIL_ON_EMPTY_BEANS` at runtime | gotcha | 14/15 |
| GE-0070 | Quarkus Flow `listen` task does not receive from SmallRye in-memory channels | gotcha | 13/15 |
| GE-0071 | Bridge SmallRye in-memory channel to Quarkus Flow using @Incoming + startInstance() | technique | 13/15 |
| GE-0076 | -D Flags After -jar Don't Override Config Expressions in Quarkus | gotcha | 11/15 |
| GE-0077 | Patch a Vert.x Internal Handler Map via Reflection in a Quarkus CDI Startup Bean | technique | 12/15 |
| GE-0078 | Quarkus WebAuthn Actual HTTP Endpoint Paths (Only Discoverable via Bytecode) | gotcha | 13/15 |
| GE-0094 | @QuarkusTest HTTP endpoint tests fire real @ApplicationScoped beans — including side-effectful adapters | gotcha | 14/15 |
| GE-0095 | Use a dedicated @QuarkusTest class with @InjectMock to isolate side-effectful endpoint tests | technique | 12/15 |
| GE-0104 | Authenticator.publicKeyAlgorithm has no getter/setter — field cannot be persisted in WebAuthnUserProvider | gotcha | 8/15 |
| GE-0123 | Use Java-Managed Event Buffers + Fresh RuleUnitInstance per Tick Instead of Drools Fusion STREAM Mode for Temporal CEP in Quarkus Rule Units | technique | 13/15 |
| GE-0125 | Quarkus static files are embedded in the JAR — source changes require a full rebuild to take effect | gotcha | 13/15 |
| GE-0126 | Quarkus WebAuthn generates a new random session key on restart — REST APIs return 401, WebSocket stays alive | gotcha | 13/15 |
| GE-0128 | `quarkus.webauthn.login-page` defaults to `/login.html` — undocumented, causes 404 on protected routes | gotcha | 11/15 |
| GE-0133 | Quarkus CDI silently ignores `@ApplicationScoped` beans in jars without a Jandex index | gotcha | 14/15 |
| GE-0134 | `mvn install -DskipTests` runs Quarkus augmentation on library modules and fails if CDI is unsatisfied | gotcha | 12/15 |
| GE-0138 | `PanacheRepositoryBase.findById()` return type blocks SPI interface implementation | gotcha | 12/15 |
| GE-0142 | Hibernate `@OneToMany` collections must be initialized with `ArrayList`, not `CopyOnWriteArrayList` | gotcha | 12/15 |
| GE-0146 | Tyrus WebSocket client causes `ArC container not initialized` in `@QuarkusTest` | gotcha | 13/15 |
| GE-0148 | Quarkus JAX-RS resource without `@ApplicationScoped` silently breaks instance-level caches | gotcha | 12/15 |
| GE-0168 | Quarkus Flow discovers workflows from both YAML files and Java classes at build time | gotcha | 11/15 |
| GE-20260414-9ada73 | Panache entity.persist() on a detached entity silently rolls back the transaction | gotcha | 13/15 |
| GE-20260414-879c59 | HQL cast(enum as string) returns the enum type, not a String — causes QueryTypeMismatch | gotcha | 10/15 |
| GE-20260421-03fa72 | Quarkus optional module jar missing Jandex index — CDI beans not discovered by consuming modules | gotcha | 13/15 |
| GE-20260421-3b3104 | Hibernate bytecode enhancement silently zeros all fields when accessed via reflection | gotcha | 14/15 |
| GE-20260421-4a9364 | JpaWorkItemStore.scan() with assigneeId also matches candidateUsers LIKE '%actorId%' | gotcha | 12/15 |
| GE-20260421-9498ff | WorkItemService.delegate() must run strategy BEFORE clearing assigneeId or Hibernate auto-flush corrupts workload counts | gotcha | 11/15 |
| GE-20260421-cd3f95 | CDI @Observes lifecycle events re-enter the observer recursively when actions fire new events | gotcha | 12/15 |
| GE-20260420-93d1ae | @QuarkusTest classes named *IT are silently routed to failsafe, not surefire — Tests run: 0 | gotcha | 10/15 |
| GE-20260417-c59817 | quarkus.arc.selected-alternatives in application.properties activates @Alternative beans in @QuarkusTest — beans.xml is ignored | undocumented | 12/15 |
| GE-20260415-884e48 | @Alternative @Priority(n) in CDI 4.0/Quarkus globally activates the alternative — causes AmbiguousResolutionException | gotcha | 12/15 |
| GE-20260417-c59817 | quarkus.arc.selected-alternatives in application.properties activates @Alternative beans in @QuarkusTest — beans.xml is ignored | undocumented | 12/15 |
| GE-20260414-10d4da | CNCF Serverless Workflow CallableTaskBuilder.accept(Class) cannot distinguish custom callable names | gotcha | 13/15 |
| GE-20260414-f4f539 | casehub-engine CaseHubReactor.startCase() no longer calls registerCaseDefinition() — definitions only register at startup | undocumented | 9/15 |
| GE-20260417-3887be | Reset shared test counter immediately after a blocking startCase() call to minimise async contamination | technique | 10/15 |
| GE-20260417-4a3c22 | Worker lambda receives null for context fields added to inputSchema — keys may not survive event log serialization | gotcha | 10/15 |
| GE-20260417-d67b22 | Use per-case DB query instead of shared AtomicInteger to isolate @QuarkusTest async worker assertions | technique | 12/15 |
| GE-20260420-18fbd4 | casehub-engine ExpressionEvaluator is a marker-only interface — actual evaluation requires instanceof dispatch to LambdaExpressionEvaluator.test() | undocumented | 11/15 |
| GE-20260420-4a62d3 | casehub-persistence-memory as Maven test dependency fails for @QuarkusTest — copy sources instead | gotcha | 11/15 |
| GE-20260421-88296e | casehub-engine persistence-memory Maven profile required for all engine tests without Docker | undocumented | 10/15 |
| GE-20260428-9311f8 | casehub-engine @ApplicationScoped no-op SPI beans collide with consumer implementations when engine is indexed | gotcha | 13/15 |
| GE-20260428-a67806 | casehub-engine Vert.x event-bus handlers lack @Blocking — JPA consumer calls fail from IO thread | gotcha | 12/15 |
| GE-20260420-b9259e | LedgerAttestation in quarkus-ledger 1.0.0-SNAPSHOT is plain @Entity — Panache statics cause compile error | gotcha | 10/15 |
| GE-20260424-6b88a0 | `quarkus.ledger.datasource` routes LedgerEntityManagerProducer to a named PU — not documented | undocumented | 10/15 |
| GE-20260427-97650e | CDI ambiguity when adding second implementation of a quarkus-ledger repository interface | gotcha | 10/15 |
| GE-20260429-2e1c4f | quarkus-ledger sequence_number index is not unique — race yields silent duplicate sequences | gotcha | 8/15 |
| GE-20260414-23982b | `check_messages` excludes EVENT messages by design — tests expecting EVENTs via check_messages always get fewer results than sent | gotcha | 8/15 |
| GE-20260508-492336 | casehub-qhorus activates quarkus-hibernate-reactive unconditionally — fails with JDBC H2 at startup | gotcha | 12/15 |
| GE-20260421-4a9364 | JpaWorkItemStore.scan() with assigneeId also matches candidateUsers LIKE '%actorId%' | gotcha | 12/15 |
| GE-20260421-9498ff | WorkItemService.delegate() must run strategy BEFORE clearing assigneeId or Hibernate auto-flush corrupts workload counts | gotcha | 11/15 |
| GE-20260427-5d7c67 | quarkus-work (full) brings JpaWorkloadProvider that clashes with any other WorkloadProvider bean | gotcha | 11/15 |
| GE-20260427-bf4338 | WorkItemStatus.EXPIRED.isTerminal() returns false — EXPIRED is not treated as terminal by quarkus-work | gotcha | 10/15 |
| GE-20260427-cc77a7 | WorkItemLifecycleEvent.workItem() doesn't exist — access WorkItem via source() cast | undocumented | 11/15 |
| GE-20260429-cd60ee | Add completeFromSystem()/rejectFromSystem() to WorkItemService to bypass human-actor lifecycle guards | technique | 9/15 |
| GE-20260511-a28064 | Quarkus Flyway classpath:db/migration scans transitive JARs — casehub-work V1-V21 conflicts with consumer domain migrations | gotcha | 13/15 |
| GE-20260414-14d244 | quarkus-flow TaskExecutorFactory SPI — undocumented extension point for custom task execution | undocumented | 11/15 |
| GE-20260414-1b00a0 | @ConfigProperty with defaultValue="" causes SRCFG00014 for optional String properties in Quarkus | gotcha | 11/15 |
| GE-20260414-2263db | Jackson deserializes Java records without @JsonProperty when Maven -parameters flag is enabled | undocumented | 12/15 |
| GE-20260414-22f094 | H2 rejects 'key' as a column name — syntax error with no hint it's a reserved word | gotcha | 8/15 |
| GE-20260414-278875 | QuarkusTransaction.requiringNew() pattern for testing DB constraints that need independent commits | technique | 11/15 |
| GE-20260414-2ec494 | Panache `find("ORDER BY field ASC")` without a WHERE clause returns empty silently | gotcha | 11/15 |
| GE-20260414-3153fe | @QuarkusIntegrationTest must live in a separate module from the extension runtime | gotcha | 13/15 |
| GE-20260414-3fff4a | Call Entity.getEntityManager().clear() after JPQL bulk updates in @QuarkusTest to see DB state | technique | 12/15 |
| GE-20260414-5b3897 | quarkus-flow uses the CNCF Serverless Workflow SDK directly — not Kogito | gotcha | 9/15 |
| GE-20260414-5fc8e0 | CNCF Serverless Workflow CallableTaskBuilder SPI — exact interface signatures (v7.13) | undocumented | 10/15 |
| GE-20260414-614675 | Use Optional<String> in @ConfigMapping for optional string properties that can be legitimately absent | technique | 9/15 |
| GE-20260414-62a6df | COLLECT and EPHEMERAL channel semantics: SELECT-then-DELETE is not atomic under READ_COMMITTED isolation | gotcha | 13/15 |
| GE-20260414-7ce32b | @TestTransaction swallows unique-constraint violations — Hibernate never flushes within the test body | gotcha | 10/15 |
| GE-20260414-868f32 | Quarkiverse extension-descriptor goal validates ALL transitive deployment JARs — not just direct ones | gotcha | 13/15 |
| GE-20260414-872786 | Quarkus @Scheduled interval expressions require ${property} not {property} | gotcha | 11/15 |
| GE-20260414-926cee | RestAssured percent-encodes `:` in URL paths, breaking JAX-RS routes like `/a2a/message:send` | gotcha | 13/15 |
| GE-20260414-937013 | Add a non-@Tool overload to evolve an MCP @Tool method signature without breaking test call sites | technique | 11/15 |
| GE-20260414-963a6d | Hibernate @PreUpdate fires at flush time, not at persist() — denormalized fields are stale in the returned object | gotcha | 11/15 |
| GE-20260414-99854d | @TestTransaction + Hibernate JPQL bulk update = silently stale first-level cache | gotcha | 12/15 |
| GE-20260414-99a2a3 | Field-inject CDI Event with null guard to keep unit tests free of CDI | technique | 11/15 |
| GE-20260414-9b2b14 | `wait_for_reply` cancellation requires the cancel to happen WHILE the poll loop is running | gotcha | 10/15 |
| GE-20260414-a2e8a3 | @WithDefault("") in @ConfigMapping throws ConfigValidationException — empty string treated as null | gotcha | 11/15 |
| GE-20260414-bd3f85 | Deleting a Panache entity with a self-referencing FK throws `JdbcSQLIntegrityConstraintViolationException` | gotcha | 11/15 |
| GE-20260414-be9977 | Quarkus extension activation uses quarkus-extension.properties not quarkus-extension.yaml for deployment-artifact | undocumented | 10/15 |
| GE-20260414-c18090 | Quarkus 3.32+ automatically registers REST records, enums, and @Provider classes for native reflection | undocumented | 11/15 |
| GE-20260414-c2f74c | Hibernate Reactive Panache calls throw 'No current Mutiny.Session found' when invoked directly from @QuarkusTest thread | gotcha | 12/15 |
| GE-20260414-c87a14 | @ConfigMapping in a Quarkus extension requires Javadoc on every method, including group accessors | gotcha | 11/15 |
| GE-20260414-fa6489 | quarkus-mcp-server @ToolArg has 'required' and 'defaultValue' attributes — not in docs, only in bytecode | undocumented | 10/15 |
| GE-20260414-fbf82f | Test scheduled services directly via injection instead of waiting for Quarkus Scheduler to fire | technique | 12/15 |
| GE-20260415-53068a | RestAssured deserialises JSON floats as Float not Double — (Double) cast throws ClassCastException | gotcha | 11/15 |
| GE-20260415-5c2136 | @QuarkusTest binds hardcoded port 8081 — add test-port=0 to prevent 'Port already bound' cascades | gotcha | 12/15 |
| GE-20260415-748447 | Quarkiverse extension depending on a sibling quarkus-ledger library requires manual mvn install of that library first | undocumented | 9/15 |
| GE-20260415-a13ed7 | A @Transactional JAX-RS method that calls @Transactional CDI beans sees their writes immediately — no flush needed | technique | 10/15 |
| GE-20260415-d7a439 | Quarkus extension Flyway migrations run in global numeric order — subclass join tables must be numbered above the extension's base schema | gotcha | 10/15 |
| GE-20260415-dfa8ba | @RegisterProvider on @RegisterRestClient not honoured by RestClientBuilder.newBuilder() | gotcha | 12/15 |
| GE-20260415-e5fa33 | Quarkiverse extension-descriptor rejects deployment pom that depends on X-deployment unless runtime pom depends on X | gotcha | 13/15 |
| GE-20260415-e92f89 | @TestTransaction + @Transactional method call + REST assertion — data invisible across transaction boundary | gotcha | 13/15 |
| GE-20260415-ffcbdd | Multiple @QuarkusTest classes in Surefire cause intermittent TIME_WAIT port conflict | gotcha | 11/15 |
| GE-20260416-1a2d0e | Quarkus dev mode compiles at startup — mvn test after server start does not update the running app | gotcha | 10/15 |
| GE-20260416-58b555 | @QuarkusTest CDI singletons populated only via HTTP remain null — server startup never calls endpoints | gotcha | 10/15 |
| GE-20260416-8466a8 | Use a no-profile-guard @ApplicationScoped bridge bean to flow profile-specific data to general-purpose consumers | technique | 10/15 |
| GE-20260416-8fc4c5 | Quarkus dev mode log file deleted while JVM holds it open — 161GB invisible disk usage, only visible via lsof | gotcha | 13/15 |
| GE-20260416-99d4c6 | Profile-scoped Quarkus file logging enables grep-based remote debugging | technique | 9/15 |
| GE-20260416-e10d09 | Use `session.getReference()` to set a `@ManyToOne` FK target in Panache `persist()` without `TransientPropertyValueException` | technique | 11/15 |
| GE-20260416-f02f95 | Hibernate Reactive in Quarkus 3.x: `runOnContext()` alone throws context safety error — use `VertxContextSupport.subscribeAndAwait()` | gotcha | 13/15 |
| GE-20260417-01b5d5 | WrapBusinessErrorInterceptor only wraps methods annotated with @Tool — class-level placement is safe | undocumented | 11/15 |
| GE-20260417-2e4d46 | Editing Flyway SQL source files changes checksum — use mvn clean test or H2 silently reuses stale schema | gotcha | 11/15 |
| GE-20260417-45f47f | Class-level @WrapBusinessError wraps all CDI callers of @Tool methods, not just the MCP server | gotcha | 11/15 |
| GE-20260417-691885 | Class-level @WrapBusinessError converts @Tool method exceptions to isError:true MCP responses without changing return types | technique | 12/15 |
| GE-20260417-a405a4 | quarkus-maven-plugin build goal in extension runtime pom breaks mvn install with datasource error | gotcha | 10/15 |
| GE-20260417-bbaa4b | Maven module order causes 'missing table' schema validation failure when Flyway lives in a later module | gotcha | 12/15 |
| GE-20260417-e71f46 | Downstream @QuarkusTest modules fail with 'qrtz_triggers does not exist' after Flyway moves to a separate module | gotcha | 12/15 |
| GE-20260418-03a6f4 | Config-driven CDI strategy selection: Instance<T>.select(NamedLiteral.of(name)).get() in @PostConstruct | technique | 11/15 |
| GE-20260418-0eda84 | Quarkus Hibernate ORM schema generation rejects 'create-drop' — correct value is 'drop-and-create' | gotcha | 9/15 |
| GE-20260418-0f137f | Inject the MCP tool bean as a REST facade — avoids rewriting N+1-safe queries already inside @Tool methods | technique | 10/15 |
| GE-20260418-5a5689 | CDI @Inject silently does nothing on plain Java objects owned by CDI beans — inject into the owning bean instead | gotcha | 11/15 |
| GE-20260418-d123af | Quarkus @WrapBusinessError converts IllegalArgumentException to ToolCallException at CDI proxy — catching IAE alone silently misses it | gotcha | 13/15 |
| GE-20260420-05dca8 | REST Assured hangs permanently on SSE endpoints — use java.net.http.HttpClient instead | gotcha | 12/15 |
| GE-20260420-1417ca | UserTransaction injection in @QuarkusTest for cleaning up DB state created via HTTP requests — @TestTransaction can't help | technique | 10/15 |
| GE-20260420-45d53b | quarkus.datasource.reactive=false suppresses Hibernate Reactive boot when extension is on classpath but no reactive pool exists | undocumented | 10/15 |
| GE-20260420-4b55e2 | Micrometer Gauge beans need @Startup + public @Transactional methods — three interacting gotchas | gotcha | 13/15 |
| GE-20260420-58520c | Reactive PanacheRepository<E> takes one type arg; use PanacheRepositoryBase<E,Id> for non-Long primary keys | gotcha | 9/15 |
| GE-20260420-7d28fa | PanacheRepository<PlainEntity, UUID> listAll() throws implementationInjectionMissing at runtime when entity is plain @Entity | gotcha | 11/15 |
| GE-20260420-8f9e26 | @Scheduled methods must return void — returning int causes cryptic Type mismatch build failure | gotcha | 11/15 |
| GE-20260420-c1d394 | Zero-duplication reactive test doubles: wrap InMemory*Store in a delegation shell returning Uni | technique | 11/15 |
| GE-20260420-cb4c7a | Micrometer Gauge named with _total suffix silently absent from Prometheus output | gotcha | 10/15 |
| GE-20260420-cbd0fa | Quarkus Hibernate Reactive @QuarkusTest cannot use H2 — vertx-jdbc-client alone doesn't register the reactive pool factory | gotcha | 10/15 |
| GE-20260420-daf5dc | quarkus-hibernate-reactive-panache as <optional>true</optional> dep still activates Hibernate Reactive extension in the module's own tests | gotcha | 10/15 |
| GE-20260420-dcec35 | quarkus-hibernate-reactive-panache in an extension forces Hibernate Reactive to boot for all consumers — @Alternative does not prevent it | gotcha | 13/15 |
| GE-20260420-e61431 | @WrapBusinessError on Quarkus MCP Server CDI proxy wraps exceptions into ToolCallException(cause) — must inspect getCause() to distinguish error types | gotcha | 11/15 |
| GE-20260420-eb0bcb | quarkus-mcp-server @Tool methods support Uni<T>, CompletionStage, and @NonBlocking | undocumented | 9/15 |
| GE-20260420-f0a37a | Quarkus Vert.x eventBus.publish() is fan-out; eventBus.send() is point-to-point — multiple @ConsumeEvent handlers require publish() | undocumented | 11/15 |
| GE-20260420-fa98a8 | H2 does not support partial indexes — WHERE clause in CREATE INDEX causes Flyway failure | gotcha | 10/15 |
| GE-20260421-1cfae6 | @Produces @DefaultBean @ApplicationScoped on producer methods enables consumer-replaceable CDI defaults | technique | 11/15 |
| GE-20260421-1d2764 | QuarkusTest leaves Quarkus server on port 8081 between mvn test runs — next run sees 'Address already in use' | gotcha | 12/15 |
| GE-20260421-566d3d | CDI @Any Instance<T> + name() method builds a self-registering strategy registry with O(1) lookup and startup validation | technique | 11/15 |
| GE-20260421-67bdd2 | @Blocking @Tool + private blockingXxx helper — pattern for mixing blocking and reactive in quarkus-mcp-server | technique | 11/15 |
| GE-20260421-7b8196 | @Singleton nested static class inside @QuarkusTest is discovered by CDI and injectable as EventCaptor | technique | 11/15 |
| GE-20260421-83560c | @WithTransaction on Quarkus Hibernate Reactive store methods uses REQUIRED propagation — joins outer Panache.withTransaction(), does not create nested | undocumented | 11/15 |
| GE-20260421-a00d0a | Quarkus %test profile serves /qa/emulated/config with HTTP 200 — gating a panel on HTTP status alone shows it in tests | gotcha | 10/15 |
| GE-20260421-ac12d5 | Uni.join().all(list).andFailFast() — ordered parallel reactive collection in Mutiny | technique | 10/15 |
| GE-20260421-bdf1a4 | RESTEasy Reactive: {path:.*} wildcard route captures GET / — bare @GET is never reached | gotcha | 11/15 |
| GE-20260421-cba54e | Use @Observes StartupEvent to mirror Python/Ruby auto-activation of shared singleton state at boot | technique | 12/15 |
| GE-20260422-042f69 | Maven Surefire silently skips *IT test classes — they only run under maven-failsafe-plugin | gotcha | 11/15 |
| GE-20260422-13f53b | Quarkus @TestProfile restarts don't inherit test application.properties datasource config | gotcha | 10/15 |
| GE-20260422-1b6a56 | Quarkus Vert.x @ConsumeEvent on a request() address silently starves the primary consumer | undocumented | 12/15 |
| GE-20260422-3242bf | Use Instance<T> for optional CDI injection — resolves gracefully to null when no bean exists | technique | 12/15 |
| GE-20260422-334eb8 | Quarkus named persistence unit EntityManager injection uses io.quarkus.hibernate.orm.PersistenceUnit — not jakarta.persistence.PersistenceUnit | undocumented | 9/15 |
| GE-20260422-50c33c | CDI @Observes on an abstract base type catches all subtype events — useful for generifying event observers | undocumented | 9/15 |
| GE-20260422-6997d5 | @Scheduled bean testability via package-private Clock+Duration constructor | technique | 10/15 |
| GE-20260422-7ace3d | Stale Maven JAR after branch merge causes NoSuchMethodError in @QuarkusTest | gotcha | 11/15 |
| GE-20260422-a00b81 | Quarkus dev mode hot-reload silently stops detecting file changes while Maven process appears healthy | gotcha | 10/15 |
| GE-20260422-b0c097 | Quarkus game engine leaveGame() silently breaks WebSocket state delivery for late-connecting clients | gotcha | 11/15 |
| GE-20260422-ebb91d | CDI AmbiguousResolutionException when multiple @ApplicationScoped beans implement the same SPI interface | gotcha | 10/15 |
| GE-20260422-f86f42 | Quarkus dual-PU setup with a library dependency that injects @Default EntityManager requires a dummy default datasource + minimal packages config | undocumented | 10/15 |
| GE-20260422-f922f3 | quarkus-langchain4j-core Quarkus extension stalls @QuarkusTest augmentation when no model provider is configured | gotcha | 13/15 |
| GE-20260423-3240d2 | Panache delete() returns deleted row count — use it to collapse find-then-delete into one call | technique | 9/15 |
| GE-20260423-4aa1e0 | JPA InheritanceType.JOINED forces all hierarchy entities into one persistence unit | gotcha | 10/15 |
| GE-20260423-7c5214 | Quarkus dev mode fails with ClassTooLargeException after large enum or switch growth | gotcha | 13/15 |
| GE-20260423-885412 | Quarkus @PersistenceUnit injection does not use @Inject — adding it breaks CDI resolution | undocumented | 10/15 |
| GE-20260423-8dfa90 | mvn clean does not fix ClassNotFoundException after Quarkus dependency inner class moves | gotcha | 10/15 |
| GE-20260423-a01832 | Quarkus CDI does not scan @Alternative beans in third-party test jars without explicit index config | gotcha | 9/15 |
| GE-20260423-ad5d5e | Quarkus profile swap silently breaks QA endpoint seeding — different CDI bean broadcasts state | gotcha | 11/15 |
| GE-20260423-e96787 | EntityManager.merge() return value must be captured — the original instance stays detached | gotcha | 11/15 |
| GE-20260424-4b7aa2 | @ConfigMapping in library JAR causes SRCFG00050 when properties exist in application.properties — even with Jandex | gotcha | 12/15 |
| GE-20260424-59906a | Quarkus CDI does not scan @ApplicationScoped beans in plain JAR module dependencies | undocumented | 10/15 |
| GE-20260424-a29f1c | IntelliJ Java formatter silently strips @PersistenceUnit qualifier and its import | gotcha | 11/15 |
| GE-20260424-e9df70 | Library JPA repository without @ApplicationScoped causes UnsatisfiedResolutionException — even if Jandex-indexed | gotcha | 11/15 |
| GE-20260426-6ed53b | @IfBuildProfile is resolved at build time — runtime profile switch cannot add excluded beans | gotcha | 13/15 |
| GE-20260427-3dab14 | Quarkus formatter plugin rejects files written by external tools before mvn process-sources | gotcha | 10/15 |
| GE-20260427-452889 | @TestTransaction + REQUIRES_NEW: @BeforeEach setup becomes invisible to test method — entity lookup silently fails | gotcha | 12/15 |
| GE-20260427-62d3ab | Use @Alternative @Priority(1) inner beans in @QuarkusTest to spy on SPI call sites without Mockito | technique | 10/15 |
| GE-20260427-7162b2 | Quarkus @QuarkusTest self-referencing REST client silently hits the default port, not the test port | gotcha | 10/15 |
| GE-20260427-725833 | WebSocket test break-on-marker fires on echoed shell command, not on actual output — regex required | gotcha | 11/15 |
| GE-20260427-987198 | quarkus.arc.exclude-types suppresses CDI beans from library JARs without removing the JPA entity | undocumented | 10/15 |
| GE-20260427-aa0cf9 | JPQL positional IN parameter requires parentheses: IN (?N) not IN ?N | gotcha | 11/15 |
| GE-20260427-c2b84f | @Alternative @Priority(1) beans in a test-helper jar are invisible to downstream @QuarkusTest — no Jandex index | gotcha | 12/15 |
| GE-20260427-c77ee9 | JPA repository test stub: new method overloads silently fall through to base JPA impl — NullPointerException on EntityManager | gotcha | 9/15 |
| GE-20260427-d0172f | @TestTransaction in @QuarkusTest auto-rolls back JPA changes — zero cleanup code needed | technique | 10/15 |
| GE-20260428-0482d3 | Quarkus augmentation cache is disk-based — reuseForks=false does NOT clear it | gotcha | 13/15 |
| GE-20260428-336f35 | Quarkus bakes JDBC driver class into Agroal at augmentation time — switching db-kind at runtime silently fails | gotcha | 14/15 |
| GE-20260428-539732 | quarkus.arc.exclude-types in test application.properties replaces (not appends) the main config list | gotcha | 10/15 |
| GE-20260428-5dbd37 | Flyway migrations written against H2 silently fail on PostgreSQL — H2 accepts non-standard SQL types | gotcha | 11/15 |
| GE-20260428-73d821 | Quarkus @TestProfile and QuarkusTestResource config overrides are NOT visible to the augmentation cache decision | undocumented | 12/15 |
| GE-20260428-92e34e | CDI Event.fireAsync().toCompletableFuture().join() waits until all @ObservesAsync handlers commit | technique | 11/15 |
| GE-20260428-a0240c | @Blocking on a JUnit @Test method causes classLoader=null and 0 tests run — no error | gotcha | 11/15 |
| GE-20260428-e75d4d | Run PostgreSQL Surefire execution first to force correct Quarkus augmentation in a dual-database test module | technique | 13/15 |
| GE-20260428-fb8c51 | CAST(date_trunc('day', field) AS LocalDate) in Hibernate 6 HQL forces a portable LocalDate return type | technique | 11/15 |
| GE-20260428-fd7a65 | @Transactional(SUPPORTS) makes JPA reads callable from any thread — including Vert.x IO thread | technique | 9/15 |
| GE-20260429-07114f | PlaywrightBase BASE_URL hardcoded to 8081 breaks Quarkus random-port E2E tests | gotcha | 11/15 |
| GE-20260429-272e6b | Quarkus sets `test.url` MicroProfile Config property in @QuarkusTest — actual bound URL including random port | undocumented | 11/15 |
| GE-20260429-3d4e35 | Test @ObservesAsync CDI observers in @QuarkusTest with @TestTransaction + fireAsync().join() | technique | 8/15 |
| GE-20260429-603196 | Quarkus/Narayana: OptimisticLockException from JTA commit is not catchable as jakarta.persistence.OptimisticLockException | gotcha | 13/15 |
| GE-20260429-d20380 | JPA JOINED inheritance: filtering by subclass column vs inherited column for same UUID — only inherited uses the index | undocumented | 8/15 |
| GE-20260429-da95ec | Two-bean pattern for @ObservesAsync + @Transactional with OCC retry in Quarkus | technique | 12/15 |
| GE-20260430-ef928c | Quarkus SRCFG00050 at test startup presents as ClassLoader failure, not config error | gotcha | 9/15 |
| GE-20260501-311bd8 | quarkus.mcp.server.tools.page-size controls tools/list pagination — undocumented default of 50 silently truncates large tool sets | undocumented | 12/15 |
| GE-20260501-3c0de6 | Hibernate generates invalid `check ((dtype in ()))` DDL when JPA subclasses are not on test classpath | gotcha | 13/15 |
| GE-20260501-50a9f4 | quarkus-mcp-server silently caps tools/list at 50 — tools beyond alphabetical position 50 simply don't appear | gotcha | 14/15 |
| GE-20260504-45a947 | Quarkus test profile enabling a `@Scheduled` feature must also disable the scheduler — or it races direct `runComputation()` calls | gotcha | 11/15 |
| GE-20260505-2c199a | Quarkus SSE Multi<String> auto-wraps each item with "data:" prefix — return plain text, not pre-formatted frames | gotcha | 13/15 |
| GE-20260505-48085a | static new ObjectMapper() silently fails to serialize Instant in Quarkus — use @Inject ObjectMapper | gotcha | 12/15 |
| GE-20260505-84577e | @ApplicationScoped CDI proxy field writes go to the proxy, not the bean — silent in @QuarkusTest | gotcha | 11/15 |
| GE-20260505-c8514a | @TestTransaction prevents cross-test message leakage when gateway inbound persists messages inside @QuarkusTest | technique | 9/15 |
| GE-20260505-d702f0 | Routing through a gateway method inside @Transactional causes double-persist — split the persistence call from the fan-out | gotcha | 10/15 |
| GE-20260505-fc9770 | ThreadLocal<Deque<T>> on @ApplicationScoped bean as CDI interceptor context — works in tests and scheduled jobs, cleans up automatically | technique | 10/15 |
| GE-20260508-a2b49e | Quarkus dev-mode live-reload scanner adds ~1.5s latency to HTTP requests after idle | gotcha | 11/15 |
| GE-20260512-4d6f48 | Panache entities cannot be scanned by two Quarkus persistence units simultaneously | gotcha | 9/15 |
| GE-20260512-d0fa82 | H2 + two Agroal datasources in one @Transactional method fails with 'Failed to enlist' — requires transactions=xa | gotcha | 11/15 |
| GE-20260512-ee7c07 | Quarkus ArC ignores beans.xml <alternatives> — use quarkus.arc.selected-alternatives | gotcha | 11/15 |
| GE-20260513-a2f5b7 | @WithDefault("") on a String method in @ConfigMapping causes ConfigValidationException at Quarkus startup | gotcha | 11/15 |
| GE-20260514-641df6 | @BeforeEach @Transactional works in @QuarkusTest — lifecycle methods go through the CDI proxy | technique | 8/15 |
| GE-20260514-8a6191 | Quarkus Dev Services: 'Could not load class' is a misleading error when Docker not running | gotcha | 8/15 |
| GE-20260420-4a62d3 | @Alternative CDI beans in a JAR are invisible to @QuarkusTest — two fixes: copy sources or add Jandex index | gotcha | 11/15 |
| GE-20260511-a28064 | Quarkus Flyway classpath:db/migration scans transitive JARs — casehub-work V1-V21 conflicts with consumer domain migrations | gotcha | 13/15 |
| GE-20260415-884e48 | @Alternative @Priority(n) in CDI 4.0/Quarkus globally activates the alternative — causes AmbiguousResolutionException | gotcha | 12/15 |
| GE-20260427-5d7c67 | quarkus-work (full) brings JpaWorkloadProvider that clashes with any other WorkloadProvider bean | gotcha | 11/15 |
| GE-0134 | `mvn install -DskipTests` runs Quarkus augmentation on library modules and fails if CDI is unsatisfied | gotcha | 12/15 |
| GE-20260424-6b88a0 | `quarkus.ledger.datasource` routes LedgerEntityManagerProducer to a named PU — not documented | undocumented | 10/15 |
| GE-20260415-884e48 | @Alternative @Priority(n) in CDI 4.0/Quarkus globally activates the alternative — causes AmbiguousResolutionException | gotcha | 12/15 |
