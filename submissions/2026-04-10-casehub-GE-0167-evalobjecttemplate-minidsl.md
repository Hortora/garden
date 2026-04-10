**Submission ID:** GE-0167
**Type:** undocumented
**Suggested target:** casehub-engine/ (new) or java/

# casehub-engine `StateContextImpl.evalObjectTemplate()` is a Full Mini-Template DSL

## The Behaviour
`StateContextImpl.evalObjectTemplate(String template)` parses a template string and returns a `Map<String, Object>` by evaluating path expressions against the current context. It is not JQ — it is a custom mini-DSL baked into the implementation.

## Syntax
```
{ key: .path.to.value, "quoted-key": "literal string", count: 42, flag: true }
```
- Unquoted keys: identifier syntax
- Quoted keys: string literals
- Values starting with `.`: dot-path traversal into the context (e.g. `.document.id`)
- Values without `.`: JSON literals (string, number, boolean, null)
- Nested structures: supported via auto-vivification

## Where It's Used
Capability `inputSchema` and `outputSchema` fields are evaluated via this method to extract worker input from `StateContext` and merge worker output back. It's the bridge between the JSON context and the worker contract — not JQ, despite JQ being used everywhere else in the system.

## Why Non-Obvious
The system uses JQ for all condition evaluation. A developer reading the codebase would assume `inputSchema`/`outputSchema` are also JQ expressions. `evalObjectTemplate()` is never mentioned in any README, design doc, or comment explaining the schema fields. Only discoverable by reading `StateContextImpl.java`.

## Versions
casehub-engine (pre-1.0, observed 2026-04-09)
