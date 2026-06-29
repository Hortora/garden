| GE-20260521-1e981c | Duration.parse() accepts day-based periods like 'P1D' — does not throw DateTimeParseException | gotcha | 9/15 |
| GE-20260522-a69fa1 | Java String.matches() anchors the full string — not a substring search | gotcha | 9/15 |
| GE-20260519-b9719e | SmallRye Config throws NoSuchElementException for Map<String,String> @ConfigProperty when no keys match the prefix | undocumented | 8/15 |
| GE-20260525-c715ae | SlaBreachContext Javadoc says MapPreferences.empty() — method does not exist | gotcha | 8/15 |
| GE-20260525-f04530 | Inject Event<T> in @QuarkusTest as a synchronous test driver for @Observes handlers | technique | 9/15 |
| GE-20260529-8e127e | @Transactional on @QuarkusTest methods commits data — use @TestTransaction for rollback isolation | gotcha | 11/15 |
| GE-20260530-c3087c | Arc CDI proxy makes getClass().getAnnotation(Priority.class) return null — use InjectableBean.getPriority() instead | gotcha | 13/15 |
| GE-20260530-680285 | CDI 4.1 Instance.handles() returns Iterable not Stream — use Arc's InjectableInstance.handlesStream() | undocumented | 12/15 |
| GE-20260530-fcc6c3 | ConcurrentHashMap.putIfAbsent silently keeps stale TTL cache entries — need atomic conditional remove first | gotcha | 12/15 |
| GE-20260530-63f1cb | @EntityListeners @PrePersist callbacks don't fire in non-JPA (in-memory) repository implementations | gotcha | 11/15 |
| GE-20260530-c05d12 | entityManager.persist() inside @PrePersist of a different entity is unsafe — JPA spec doesn't guarantee flush ordering | gotcha | 12/15 |
| GE-20260530-82884a | Compose an abstract cache class with put() bypass when loadContext() can't receive the computation context | technique | 11/15 |
| GE-20260530-5a9f02 | @ObservesAsync + @Transactional(REQUIRES_NEW) decouples audit persistence from the parent write transaction | technique | 11/15 |
| GE-20260531-935576 | Python re.sub [^)]+ breaks on nested method calls during Java source migration | gotcha | 10/15 |
| GE-20260531-935576 | Python re.sub [^)]+ breaks on nested method calls during Java source migration | gotcha | 10/15 |
| GE-20260531-769f9c | casehub-ledger updateGlobalTrustScore() is a silent no-op for new actors — use upsert() to seed trust scores in tests | gotcha | 10/15 |
| GE-20260531-446fea | Quartz job data map is the correct mechanism for threading execution context through job listeners without CDI request scope | technique | 11/15 |
| GE-20260531-8b1f4e | Maven cross-tenant SPI interface in wrong module tier causes unresolvable dependency direction | gotcha | 10/15 |
| GE-20260531-22e747 | Adding a component to a Java record breaks every construction site — no compatible migration path | gotcha | 11/15 |
| GE-20260530-1a7e84 | casehub-qhorus MessageDispatch.builder() requires inReplyTo + correlationId for response-type messages (DONE, DECLINE, RESPONSE, FAILURE) | gotcha | 9/15 |
| GE-20260604-8b199c | Hardcoded MCP tool-count assertion breaks silently when embedded library adds new tools | gotcha | 10/15 |
| GE-20260606-bc1b15 | SmallRye Config ${sys:property} single-colon is fallback-value syntax, not a system-property handler | gotcha | 13/15 |
| GE-20260606-1c20a7 | @WithDefault expression + Path return type in @ConfigMapping: SmallRye resolves expression then converts to Path | undocumented | 11/15 |
| GE-20260606-668cee | Mockito: stubbing a nested @ConfigMapping sub-interface method NPEs during setUp, not at test execution | gotcha | 10/15 |
| GE-20260609-ddd4b8 | CaseHub.signal() is async (Vert.x event bus) — not a synchronous blackboard update | gotcha | 11/15 |
| GE-20260609-84290d | WorkItemLifecycleEvent has no workItem() method — use event.source() cast to WorkItem | undocumented | 9/15 |
| GE-20260609-bc8704 | H2 does not support partial (filtered) UNIQUE indexes even in MODE=PostgreSQL | gotcha | 11/15 |
| GE-20260609-45bd4c | @ActivateRequestContext required on methods called from Quartz worker threads | gotcha | 10/15 |
| GE-20260611-a42c0b | Quarkus JPA subclass @Inject EntityManager omits parent qualifier — silently uses wrong PU in multi-datasource | gotcha | 9/15 |
| GE-20260616-e15321 | JAX-RS @Path annotation shadows io.casehub.platform.api.path.Path — cannot import both in a REST resource | gotcha | 9/15 |
| GE-20260616-848099 | CFR subclause string assertions — contains("(c)(1)(i)") passes for "(c)(1)(ii)" (substring ambiguity) | gotcha | 9/15 |
| GE-20260616-ba2c72 | LedgerEntry.compliance() accessible in @ExtendWith(MockitoExtension.class) unit tests — no JPA context needed | technique | 9/15 |
| GE-20260616-0b20d0 | casehub-engine: context keys absent from YAML inputSchema are blackboard-only — capability agent never receives them | gotcha | 10/15 |
| GE-20260617-abe516 | GlobalOpenTelemetry.getTracer() in static final field returns no-op tracer — library instrumentation must call lazily | gotcha | 12/15 |
| GE-20260618-976009 | Quarkus ArC rejects @Transactional on private methods at augmentation time — DeploymentException with no runtime warning | gotcha | 11/15 |
| GE-20260517-e78ae8 | JPA entity returned from @Transactional method is detached — field mutations silently lost | gotcha | 13/15 |
| GE-20260609-ddd4b8 | CaseHub.signal() is async (Vert.x event bus) — not a synchronous blackboard update | gotcha | 11/15 |
| GE-20260629-ba73b8 | Hibernate @Version skips increment on unmodified entities — dirty-checking gate before OCC | gotcha | 11/15 |
| GE-20260629-7d2272 | Quarkus EntityManager returns stale cached entities with TxType.SUPPORTS and no ambient transaction | gotcha | 11/15 |
| GE-20260629-6928ab | Conditional UPDATE on a row that may not exist — JPQL UPDATE WHERE flag = false returns 0 rows, indistinguishable from 'already claimed' | gotcha | 11/15 |
| GE-20260629-17b961 | OCC claim must be reset before rethrowing SituationConflictException — two-phase claim+save leaves permanent deadlock | gotcha | 10/15 |
| GE-20260629-991c58 | Bifurcated claim path — claim-before-save for existing entities to preserve expiry timing, save-before-claim for new entities | technique | 10/15 |
| GE-20260629-e8b16d | EventStreamBus.clear() drops subscriptions — silent pipeline death on lifecycle reset | gotcha | 12/15 |
