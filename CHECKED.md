# Garden Duplicate Check Log

Tracks which entry pairs have been semantically compared for duplicate detection.
Only within-category pairs are checked — cross-category entries cannot be duplicates.
Pairs not appearing here are unchecked candidates for the next DEDUPE sweep.

---

| Pair | Result | Date | Notes |
|------|--------|------|-------|
| GE-0021 × GE-0027 | related | 2026-04-06 | gotcha + technique for same ocraft debug threading restriction; kept distinct, cross-referenced |
| GE-0022 × GE-0025 | related | 2026-04-06 | stateful mock design (GE-0025) + parity enforcement (GE-0022); complementary, kept distinct |
| GE-0003 × GE-0012 | related | 2026-04-06 | verification workflow (GE-0003) + git hash arbiter technique (GE-0012); cross-referenced |
| GE-0009 × GE-0018 | related | 2026-04-06 | corruption signature check (GE-0009) + layered pipeline testing (GE-0018); GE-0018 includes GE-0009 pattern as layer 1; cross-referenced |
| GE-0011 × GE-0012 | distinct | 2026-04-06 | GE-0011 is about LLM overconfidence from commit messages; GE-0012 is the git hash arbiter technique |
| GE-0034 × GE-0035 | related | 2026-04-06 | sparse pair log (GE-0034) + activity-count sweep trigger (GE-0035); companion techniques for the same deduplication system; cross-referenced |
| GE-0038 × GE-0039 | related | 2026-04-06 | Panama FFM PTY crash gotcha (GE-0038) + reuseForks=false fix (GE-0039); same root cause, gotcha and technique; cross-referenced |
| GE-0036 × GE-0032 | distinct | 2026-04-06 | GE-0036 is about @ApplicationScoped bean state across test classes; GE-0032 is about @Scheduled concurrent execution |
| GE-0024 × GE-0023 | distinct | 2026-04-06 | GE-0024 is volatile torn snapshot (concurrency); GE-0023 is records List immutability (different concern) |
| GE-0015 × GE-0018 | related | 2026-04-06 | GE-0015 is browser cache symptom; GE-0018's Layer 4 (Playwright) is the test that catches GE-0015; cross-referenced |
| GE-0043 × GE-0050 | related | 2026-04-07 | both are conventional commit scope clustering techniques; GE-0043 covers extraction pattern, GE-0050 covers no-diff-read approach for bulk retrospective; kept distinct, cross-referenced in git.md |
| GE-0053 × GE-0059 | revise | 2026-04-07 | GE-0059 is a REVISE of GE-0053 — solution now known (firstVariadicArg); integrated into GE-0053 body |
| GE-0053 × GE-0061 | related | 2026-04-07 | GE-0053 is the gotcha (IOC_OUT silent zero); GE-0061 is the workaround technique (use tput); cross-referenced |
| GE-0060 × GE-0061 | related | 2026-04-07 | GE-0060 is TERM env var gotcha; GE-0061 cites GE-0060 as a prerequisite caveat |
| GE-0052 × GE-0066 | related | 2026-04-07 | GE-0052 is @UnlessBuildProfile anyOf (undocumented attribute); GE-0066 is Unsatisfied dependency when injecting profile-excluded bean; different problems, same annotation |
| GE-0056 × GE-0063 | related | 2026-04-07 | both are Drools/Quarkus testing issues; GE-0063 is DataSource factory NPE in plain JUnit; GE-0056 is DRL syntax traps with records; distinct concerns |
| GE-0064 × GE-0065 | distinct | 2026-04-07 | GE-0064 is Maven aggregator packaging; GE-0065 is quarkus:dev skipping — different Maven concerns |
| GE-0008 × GE-0016 | distinct | 2026-04-08 | lxml double-encoding vs hardcoded path traversal — different bugs |
| GE-0008 × GE-0017 | distinct | 2026-04-08 | lxml double-encoding vs html.parser body wrapper — different bugs |
| GE-0016 × GE-0017 | distinct | 2026-04-08 | path traversal vs parser fragment handling — different bugs |
| GE-0056 × GE-0057 | distinct | 2026-04-08 | DRL OOPath syntax traps vs rule-builder-dsl addParamsFact() build-time issue |
| GE-0063 × GE-0057 | distinct | 2026-04-08 | DataSource JUnit NPE vs DSL build-time wrong-fact extraction |
| GE-0038 × GE-0053 | distinct | 2026-04-08 | SIGTRAP JVM crash (PTY slave fd) vs IOC_OUT buffer zeroed — different failure modes |
| GE-0038 × GE-0060 | distinct | 2026-04-08 | SIGTRAP crash vs tput/TERM env var gotcha |
| GE-0038 × GE-0061 | distinct | 2026-04-08 | SIGTRAP crash vs tput dimension-verify technique |
| GE-0053 × GE-0060 | related | 2026-04-08 | GE-0053 IOC_OUT investigation led to TERM env var discovery (GE-0060); same PTY debugging chain |
| GE-0051 × GE-0072 | distinct | 2026-04-08 | WKWebView smoke-test technique vs performSelectorOnMainThread async scheduling gotcha |
| GE-0051 × GE-0073 | distinct | 2026-04-08 | WKWebView smoke-test vs NSEvent BOOL flag mode interception |
| GE-0072 × GE-0073 | related | 2026-04-08 | both AppKit main-thread execution patterns; 0072 is the async scheduling gotcha, 0073 is the BOOL flag technique that avoids it |
| GE-0005 × GE-0007 | distinct | 2026-04-08 | @PermuteReturn boundary omission vs typeArgList JEXL expression technique |
| GE-0033 × GE-0066 | related | 2026-04-08 | 0033 is the technique (use @UnlessBuildProfile to strip beans); 0066 is the gotcha (consumers fail with Unsatisfied dependency) |
| GE-0033 × GE-0062 | distinct | 2026-04-08 | @UnlessBuildProfile technique vs HttpAuthenticationMechanism startup ordering |
| GE-0062 × GE-0066 | distinct | 2026-04-08 | auth mechanism timing vs @UnlessBuildProfile consumer dependency failure |
| GE-0031 × GE-0065 | distinct | 2026-04-08 | quarkus packaging non-standard vs quarkus:dev silently skips — different Maven concerns |
| GE-0045 × GE-0046 | distinct | 2026-04-08 | WebAuthn config keys wrong names vs session cookie encryption key undocumented — different bugs |
| GE-0068 × GE-0069 | distinct | 2026-04-08 | consume re-serializes vs POJO FAIL_ON_EMPTY_BEANS — different runtime issues |
| GE-0068 × GE-0071 | distinct | 2026-04-08 | consume re-serializes vs SmallRye bridge technique |
| GE-0069 × GE-0070 | distinct | 2026-04-08 | POJO serialization vs listen doesn't receive SmallRye — different issues |
| GE-0069 × GE-0071 | distinct | 2026-04-08 | POJO serialization vs SmallRye bridge technique |
| GE-0070 × GE-0071 | related | 2026-04-08 | GE-0070 is the gotcha (listen doesn't receive SmallRye); GE-0071 is the technique fix (bridge via @Incoming + startInstance()) |
