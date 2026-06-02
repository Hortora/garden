# casehub-engine Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0167 | `StateContextImpl.evalObjectTemplate()` is a full mini-template DSL — not JQ | gotcha | 9/15 |
| GE-20260521-a0f5a6 | HumanTaskScheduleHandler skips WorkItem creation — PlanningStrategyLoopControl pre-marks PlanItems RUNNING | gotcha | 11/15 |
| GE-20260523-fd8725 | binding 'when' field silently ignored for contextChange triggers — conditions must be in on.contextChange.filter | gotcha | 12/15 |
| GE-20260523-4ca5e7 | casehub-work 5-field Unix cron scheduler beans fail at startup when casehub-engine-scheduler-quartz is on the classpath | gotcha | 13/15 |
| GE-20260523-86ed13 | casehub-engine requires casehub-platform and casehub-platform-expression on the classpath — without them, engine CDI beans fail to resolve JQEvaluator and @DefaultBean injection points | undocumented | 13/15 |
| GE-20260525-f09688 | CaseHubRuntime.eventLog() WORKER_EXECUTION_COMPLETED events do not carry workerName in metadata — use WORKER_SCHEDULED instead | gotcha | 13/15 |
| GE-20260525-d06282 | casehub-engine-testing must be indexed in @QuarkusTest — without it TestCaseMetaModelRepository is undiscovered and CaseDefinition lookups fail on test retry | gotcha | 13/15 |
| GE-20260526-34a4c4 | Adding casehub-engine-scheduler-quartz as test dep cascades to WorkerExecutionRecoveryService CDI failures | gotcha | 11/15 |
| GE-20260526-2ee43b | New @ApplicationScoped engine bean injecting an excluded type surfaces as SmokeTest load failure | gotcha | 9/15 |
| GE-20260529-b5723e | casehub-engine (full runtime) as compile dep causes 31+ CDI deployment failures in implementing module | gotcha | 11/15 |
| GE-20260529-0c23f1 | quarkus.arc.exclude-types should only exclude no-op SPI beans the implementing module actually replaces | gotcha | 10/15 |
| GE-20260531-864d8e | @Observes silently never fires for casehub-engine WorkerDecisionEvent — must use @ObservesAsync | gotcha | 8/15 |
| GE-20260531-1e51d4 | casehub-engine-persistence-memory @Alternative beans need explicit selected-alternatives for SubCaseGroupRepository and PlanItemStore | gotcha | 10/15 |
| GE-20260531-4e21c1 | casehub-engine SNAPSHOT binary incompatibility — CaseMetaModelRepository.findByKey and PlanItemSaveRequest constructor signature drift | gotcha | 11/15 |
| GE-20260531-d896bf | SubCase M-of-N fields (groupId, totalInGroup, requiredCount, onThresholdReached) are DSL-only — not supported in YAML case definitions | gotcha | 10/15 |
| GE-20260531-e5a1aa | Milestone YAML field is 'condition' not 'completionCriteria' — mapper converts between them | undocumented | 8/15 |
| GE-20260602-c68651 | casehub-ledger: TrustWeightedAgentStrategy requires casehub-engine-ledger on classpath | gotcha | 10/15 |
| GE-20260602-c68651 | casehub-ledger: TrustWeightedAgentStrategy requires casehub-engine-ledger on classpath | gotcha | 10/15 |
