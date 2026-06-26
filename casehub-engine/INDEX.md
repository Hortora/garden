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
| GE-20260603-e98633 | TaskDefinition.canActivate() default unconditionally returns true — entryCriteria() is ignored | gotcha | 13/15 |
| GE-20260603-a944d1 | CaseEngine.createAndSolve() returns pre-solve CaseFile — plugin-written keys absent from returned reference | gotcha | 11/15 |
| GE-20260604-97031b | Global WorkItem.find() in engine integration tests picks up WorkItems from other test cases — Awaitility timeout with wrong WorkItem completed | gotcha | 9/15 |
| GE-20260604-38e09e | casehub-engine does not transition case to CaseStatus.WAITING when humanTask binding fires — case stays RUNNING | undocumented | 10/15 |
| GE-20260605-fa1a51 | PlanItemCompletedEvent only fires for worker completions — context signals bypass it entirely | gotcha | 12/15 |
| GE-20260607-25a3fe | CaseHubRuntime.signal(caseId, dotPath, value) is a direct case context patch — not an event dispatch | undocumented | 12/15 |
| GE-20260607-e27c23 | DefaultWorkerExecutionRecoveryService is a non-obvious CDI dependency of SignalReceivedEventHandler — excluding it causes deployment failure | gotcha | 11/15 |
| GE-20260607-609772 | CasehubEnabledProfile excludes CaseStatusChangedHandler — cases satisfy goals but never reach CaseStatus.COMPLETED | gotcha | 12/15 |
| GE-20260612-b20b51 | casehub-engine YamlCaseHub.getDefinition() requires CDI-injected ObjectMapper — NPE in plain JUnit | gotcha | 11/15 |
| GE-20260613-25d1ce | casehub-engine YAML Binding schema has no 'worker:' field — capability is a direct String property on Binding, not nested | gotcha | 12/15 |
| GE-20260613-29d3b5 | casehub-engine ActionGateRejectedHandler/ActionGateExpiredHandler clear pendingActionGate before @ConsumeEvent application consumers run | gotcha | 11/15 |
| GE-20260613-51de5b | DB query over CaseInstanceCache for Vert.x @ConsumeEvent gate discrimination — race-free, restart-safe | technique | 9/15 |
| GE-20260615-35f52f | casehub-engine panels refactor silently breaks all consumer YAML JQ bindings — asJsonNode() returns panel document, not flat working data | gotcha | 14/15 |
| GE-20260616-ed9481 | CaseDefinitionRegistry.getCaseMetaModel() throws RuntimeException on not-found — no clean existence query | gotcha | 8/15 |
| GE-20260618-53a50a | casehub-core TaskDefinitionRegistry: safe to instantiate with new in unit tests — PoisonPillDetector is not used by register() or getForCaseType() | undocumented | 9/15 |
| GE-20260626-4a4790 | casehub-worker WorkerFunction interface version coupled to engine branch — #543 vs #567 produce incompatible APIs | gotcha | 12/15 |
| GE-20260626-9ce1c9 | FlowWorkerFunction relocated twice across engine releases — io.casehub.api.model then io.casehub.engine.flow | gotcha | 9/15 |
| GE-20260626-2e4a0d | Engine main HEAD (37b2eea8) does not compile — installed engine jars are from issue-570 branch, not main | gotcha | 11/15 |
