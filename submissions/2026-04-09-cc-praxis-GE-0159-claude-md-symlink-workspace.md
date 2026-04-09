**Type:** technique
**Date:** 2026-04-09
**Submission ID:** GE-0159
**Project:** cc-praxis

---

## Gitignored CLAUDE.md Symlink for Consistent AI Workspace Config

**Stack:** Claude Code, git (any version), any project

**The problem:** When designing a workspace model where Claude should always open in a dedicated workspace directory (not the project repo), IDE integrations and developer muscle memory keep opening Claude in the project directory instead. If the workspace CLAUDE.md isn't loaded, skills route incorrectly, artifact paths are wrong, and session context is lost.

**The technique:** Create a gitignored symlink at the project root pointing to the workspace CLAUDE.md:

```bash
# Create symlink: project's CLAUDE.md → workspace CLAUDE.md
ln -sf ~/claude/private/<project>/CLAUDE.md /path/to/project/CLAUDE.md

# Hide it from git WITHOUT touching tracked .gitignore
# (works for upstream repos you don't own — Drools, any open source project)
echo "CLAUDE.md" >> /path/to/project/.git/info/exclude
```

Claude Code follows project-level symlinks and reads the workspace CLAUDE.md regardless of where it opens. Opening in the project by mistake still loads the correct config — workspace paths, session-start add-dir instruction, skill routing table.

**Why .git/info/exclude, not .gitignore:**
`.gitignore` is a tracked file — modifying it creates a diff, and for projects you don't own you have no right to commit it. `.git/info/exclude` is local-only, never committed, never shared. It works identically but is invisible to other contributors. Use it consistently for all projects regardless of ownership.

**Why non-obvious:**
- Most developers know `.git/info/exclude` exists but never use it — it's rarely needed
- The symlink-to-config pattern is unusual; people typically copy config files or use environment variables
- The combination (symlink + local exclude) makes the project completely clean to other contributors while Claude gets the right config from either entry point

**Suggested target:** `tools/claude-code.md` (or `tools/ai-tools.md` if that exists)

*Score: 14/15 · Non-obvious approach combining two underused git mechanisms to solve a real workspace config problem*
