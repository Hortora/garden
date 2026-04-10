**Submission ID:** GE-0165
**Type:** gotcha
**Suggested target:** intellij-mcp/ or intellij-platform/

# IntelliJ MCP `ide_index_status` Errors When Multiple Projects Are Open Without `project_path`

## The Surprising Behaviour
Calling `ide_index_status` (or any IntelliJ MCP tool) without specifying `project_path` returns a `multiple_projects_open` error when more than one project is open in the IDE — even when you expect only one project to be active. The error includes a full list of all open projects and their paths.

## Root Cause
The IntelliJ MCP server is attached to an IDE instance, not a project. When multiple projects are open in the same IDE window or across IDE windows sharing the MCP server, the server cannot infer which project to target. It refuses rather than guessing.

## Fix
Always pass `project_path` explicitly to every IntelliJ MCP tool call:
```
ide_index_status({ "project_path": "/absolute/path/to/project" })
```

## Why Non-Obvious
The parameter is listed as optional in the tool schema. It only becomes required when multiple projects are open — which is the normal state for any developer working across multiple repos. The error message is clear once you see it, but the assumption that it "just works" for the active project is natural.

## Versions
IntelliJ IDEA 2025.x + IntelliJ Index MCP plugin (any version observed)
