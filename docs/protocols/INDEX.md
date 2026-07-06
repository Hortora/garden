# Garden Protocols

Standing conventions and rules captured from cross-project work. Each
namespace groups protocols by technology domain.

## Namespaces

| Namespace | Scope | Description |
|-----------|-------|-------------|
| [casehub/](casehub/FOUNDATION-INDEX.md) | Platform | CaseHub platform-wide conventions — API taxonomy, routing strategies |
| [universal/](universal/INDEX.md) | Universal | Technology-agnostic conventions — REST adapter modules, module structure |
| [web/](web/INDEX.md) | Universal | Web Component and browser-side conventions — Lit reactivity, shadow DOM events |

## Adding a new protocol

1. Determine scope: does this apply to a specific platform (`casehub/`),
   a technology domain (`web/`), or does it need a new namespace?
2. If a new namespace is needed, create `<namespace>/INDEX.md` and add a
   row to the table above.
3. Write the protocol file with YAML frontmatter (see any existing
   protocol for the format).
4. Add a row to the namespace's INDEX.md.
5. Commit to garden main.
