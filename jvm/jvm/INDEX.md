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
