**Submission ID:** GE-0114
**Date:** 2026-04-08
**Project:** cc-praxis (Hortora GitHub Pages site)
**Type:** gotcha
**Stack:** HTML, GitHub Pages, any static site opened locally via `file://`
**Suggested target:** `tools/markdown.md` (existing, or `tools/github-pages.md` new)

---

## `href="dir/"` serves `index.html` on a web server but opens a directory listing when opening files locally

**Symptom:** Navigation works correctly on the deployed GitHub Pages site but breaks when opening HTML files directly from the filesystem — clicking a link like `href="blog/"` either shows a browser directory listing or fails entirely instead of loading `blog/index.html`.

**Context:** Any static HTML site where navigation uses directory-style hrefs (`href="blog/"`, `href="../"`) that rely on web server directory index resolution, tested locally by opening files directly in the browser.

### Root cause
Web servers (GitHub Pages, nginx, Apache) automatically serve `index.html` when a directory URL is requested. The `file://` protocol does not — it shows the directory contents or fails. The same `href="blog/"` behaves differently in two environments.

### Fix
Use explicit `index.html` in all hrefs for local compatibility:
```html
<!-- ❌ Works on web server, breaks locally -->
<a href="blog/">Diary</a>
<a href="../">Home</a>

<!-- ✅ Works everywhere -->
<a href="blog/index.html">Diary</a>
<a href="../index.html">Home</a>
```
Explicit `index.html` hrefs work on both web servers and local `file://` browsing.

### Why non-obvious
The directory-style href is the conventional web practice — every web framework generates them. The discrepancy only surfaces when previewing locally, and only if you test navigation (not just visual rendering). A developer who always previews on a local dev server (which also resolves directory indexes) will never hit this.

*Score: 9/15 · Included because: cross-project, common for anyone building GitHub Pages sites, local preview is the natural test · Reservation: fairly well-known in web development generally*
