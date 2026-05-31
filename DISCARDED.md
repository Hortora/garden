| GE-20260414-75d145 | GE-20260414-937013 | 2026-04-21 | Duplicate: same @Tool overload technique, 937013 is more complete |
| GE-20260414-47437e | GE-20260414-a2e8a3 | 2026-04-21 | Duplicate: same @WithDefault("") gotcha, a2e8a3 is more complete |
| GE-20260414-32ef04 | GE-20260415-e92f89 | 2026-04-21 | Duplicate: same @TestTransaction + REST transaction boundary gotcha, e92f89 is longer |
| GE-20260418-b5775c | GE-0145 | 2026-04-21 | Duplicate: same Playwright waitForFunction overload gotcha, GE-0145 has higher score |
| GE-20260420-28143a | GE-20260420-c1d394 | 2026-04-22 | Duplicate: same InMemoryReactive delegate pattern with private-final field, c1d394 has higher score (11 vs 9) |
| GE-20260423-b87e1d | GE-20260421-1d2764 | 2026-04-23 | Duplicate: same QuarkusTest port 8081 bound after mvn test gotcha, 1d2764 has higher score (12 vs 9) |
| GE-20260420-93d1ae | GE-20260422-042f69 | 2026-04-23 | Duplicate: same *IT classes silently skipped by Surefire gotcha, 042f69 has higher score (11 vs 10) |
| GE-20260427-bebc2b | GE-20260422-e48245 | 2026-05-01 | Duplicate: same @DefaultBean io.quarkus.arc import gotcha, e48245 has higher score (11 vs 10) |
| GE-20260426-438139 | GE-20260501-04667c | 2026-05-05 | Duplicate: same continue-on-error step outcome masking gotcha; 04667c is newer with more depth on outcome vs conclusion |
| GE-20260422-1914e0 | GE-20260504-9c9b01 | 2026-05-05 | Duplicate: same Claude Code expansion check bypasses allowlist gotcha; 9c9b01 has higher score (11 vs 10) |

## 2026-05-13 — Audit 1 duplicates (superseded by new jvm/ entries from Audit 2)

| Discarded | Superseded by | Reason |
|---|---|---|
| quarkus/GE-20260414-1063be | jvm/GE-20260512-67b3b5 | Panache bare field names — newer entry more complete |
| quarkus/GE-20260414-9d9c85 | jvm/GE-20260512-a9ad9f | ManagedExecutor vs raw ExecutorService |
| quarkus/GE-20260420-33b95f | jvm/GE-20260512-a3838e | hibernate-reactive-panache H2 startup failure |
| quarkus/GE-20260421-d65fe5 | jvm/GE-20260512-b3f32a | @IfBuildProperty build-time only |
| quarkus/GE-20260429-f61708 | jvm/GE-20260512-0fe012 | CDI fireAsync dispatches before commit |
| jvm/GE-20260501-d6a70e | jvm/GE-20260512-66d997 | Panache static bypasses CDI alternatives |
| jvm/GE-20260501-fbd68d | jvm/GE-20260512-6d0c2b | BroadcastProcessor.onNext() throws on no subscribers |
| jvm/GE-20260501-dfc3c2 | jvm/GE-20260512-50b394 | @TestTransaction scheduler isolation technique |

## 2026-05-26 — Dedup sweep

| Discarded | Superseded by | Reason |
|---|---|---|
| jvm/GE-20260514-83ee13 | jvm/GE-20260422-e48245 | @DefaultBean import — e48245 has higher score (11 vs 9) |
| jvm/GE-20260521-a5e71b | jvm/GE-20260521-2b82e7 | Panache.withTransaction() default PU — 2b82e7 is longer (59 vs 53 lines), same score |
| quarkus/GE-20260414-a2e8a3 | quarkus/GE-20260513-a2f5b7 | @WithDefault("") @ConfigMapping — a2f5b7 is newer (2026-05-13 vs 2026-04-14), same score |
| quarkus/GE-20260512-ee7c07 | quarkus/GE-20260417-c59817 | Quarkus ArC beans.xml alternatives — c59817 has higher score (12 vs 11) |
| casehub-engine/GE-20260420-4a62d3 | quarkus/GE-20260427-c2b84f | @Alternative CDI beans in JAR without Jandex — c2b84f has higher score (12 vs 11) |
| tools/GE-20260521-1d5032 | tools/GE-20260521-9bef0c | git rebase -i pick on merge commits — 9bef0c has higher score (10 vs 8) |
| tools/GE-20260523-5b3204 | tools/GE-20260522-5b1589 | git rebase -i drop on merge commit — 5b1589 has higher score (11 vs 10) |
| tools/GE-20260518-d1775a | tools/GE-20260518-cf67e4 | git cherry-pick -X ours drops conflicting files — cf67e4 has higher score (14 vs 11) |
| jvm/GE-20260517-9006f7 | jvm/GE-20260519-f0967f | @DefaultBean blocking bridge for reactive SPI shim — identical technique, f0967f has higher score (12 vs 9) |
| jvm/GE-20260529-baf565 | jvm/GE-20260423-daef97 | @ObservesAsync silently skipped when event source uses fire() — same gotcha, daef97 has higher score (13 vs 12) |
| tools/GE-20260531-68222f | tools/GE-20260527-e0f70d | exec git commit --amend in rebase todo — same technique, e0f70d has higher score (10 vs 9) |
