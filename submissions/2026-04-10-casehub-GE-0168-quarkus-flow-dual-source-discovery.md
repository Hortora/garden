**Submission ID:** GE-0168
**Type:** undocumented
**Suggested target:** quarkus/ or quarkus-flow/

# Quarkus Flow Discovers Workflows from Both YAML Files and Java Classes at Build Time

## The Behaviour
`DiscoveredWorkflowBuildItem` has two factory methods that produce identical `WorkflowDefinition` instances:
- `fromSpec(Path, Workflow)` — workflow discovered from a YAML/JSON file on the classpath
- `fromSource(String className)` — workflow discovered from a Java `Flow` subclass via Jandex

Both are processed identically by the deployment processor. The runtime never knows which source a workflow came from.

## Why This Matters
This confirms that YAML-defined workflows and Java DSL-defined workflows are genuinely first-class equals in Quarkus Flow — not "primary + alternative". Any framework that builds on Quarkus Flow can offer the same dual-source pattern for free by following the same `DiscoveredWorkflowBuildItem` model.

## Where to Find It
`io.quarkiverse.flow.deployment.DiscoveredWorkflowBuildItem` in the `core/deployment` module. The `FlowCollectorProcessor` scans both classpath resources (`.yaml`/`.json`) and Jandex index (subclasses of `Flow`) and produces items of both types.

## Why Non-Obvious
The Quarkus Flow documentation presents the Java DSL (`Flow` subclass) as the primary pattern. YAML support is mentioned but treated as secondary. The implementation treats them identically. The dual-source equality is only visible by reading the deployment processor source — not the docs.

## Versions
Quarkus Flow 0.6.0 (observed 2026-04-09)
