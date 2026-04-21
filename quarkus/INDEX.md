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
