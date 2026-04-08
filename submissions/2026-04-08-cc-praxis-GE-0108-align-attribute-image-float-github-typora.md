**Submission ID:** GE-0108
**Date:** 2026-04-08
**Project:** cc-praxis (Hortora blog illustration work)
**Type:** technique
**Stack:** GitHub Flavored Markdown, Typora, any Markdown renderer that allows inline HTML
**Labels:** `#markdown` `#documentation` `#blogging`
**Suggested target:** `tools/markdown.md` (existing)

---

## Use deprecated HTML `align` attribute (not `style="float"`) for image wrapping in Markdown

**What it achieves:** Floats an image left or right with text wrapping around it, in both GitHub-rendered Markdown and Typora. Works without CSS.

**Context:** Standard Markdown `![alt](img.png)` renders as a block element — text always goes above or below, never beside. `style="float:left"` is stripped by GitHub for security. The deprecated HTML `align` attribute is honoured by both GitHub and Typora.

### The technique

```markdown
<img align="left" width="200" src="image.png" alt="description">
Text that wraps around the image starts immediately here — no blank line.

More paragraphs continue wrapping until the image height is exhausted.

<br clear="left">

This content starts below the image.
```

Key requirements:
1. **No blank line** between the `<img>` tag and the first text — a blank line breaks the float in Typora
2. **`<br clear="left">`** after the wrapped section to stop wrapping
3. **`align="left"` or `align="right"`** — not `style="float:left"` (GitHub strips style attributes)

### Why non-obvious
`style="float:left"` is the modern CSS equivalent and works in Typora but is stripped by GitHub's HTML sanitiser. `align` is a deprecated HTML 4 attribute that GitHub preserves (it predates the CSS security concern). The no-blank-line requirement for Typora is undocumented — a blank line causes Typora to treat the image as a block and ignore the float.

### When to use it
- Blog posts or documentation with thumbnail illustrations alongside text
- Any Markdown file that needs to render correctly on both GitHub and in Typora

*Score: 12/15 · Included because: `style` is the natural first attempt, GitHub stripping it is not surfaced as an error, `align` as the fix is non-obvious; no-blank-line Typora requirement is undocumented · Reservation: `align` is deprecated HTML — may eventually stop working*
