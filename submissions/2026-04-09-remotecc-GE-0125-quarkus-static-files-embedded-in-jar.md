**Type:** gotcha
**Submission ID:** GE-0125
**Date:** 2026-04-09
**Project:** remotecc
**Stack:** Quarkus 3.9.x, JVM mode (quarkus-run.jar)
**Suggested target:** `quarkus/testing.md` (existing file)

---

## Quarkus static files are embedded in the JAR — source changes require a full rebuild to take effect

**Symptom:** Changes to `src/main/resources/META-INF/resources/` (JS, CSS, HTML) made after `mvn package` are invisible when the production JVM jar is running. The server serves the old version regardless of how many times it is restarted.

**Context:** Running the Quarkus production jar (`java -jar target/quarkus-app/quarkus-run.jar`). Static files are served from the embedded JAR, not from the source tree. This caused a debugging loop where `console.log` statements were added to `terminal.js`, the server was restarted repeatedly, and no console output ever appeared — because the JAR still contained the pre-modification version.

**What was tried:** Restarting the server (multiple times). Hard-refreshing the browser (Cmd+Shift+R). Clearing service worker cache. None of these helped because the source of truth is the embedded JAR, not the source files.

**Root cause:** Quarkus embeds all `META-INF/resources/` content into the JAR at build time (`mvn package`). In dev mode (`mvn quarkus:dev`), static files are served live from the source tree with hot reload. In production mode, they are frozen in the JAR.

**Fix:** Always run `mvn package -DskipTests` before restarting the production server when static file changes have been made.

**Why non-obvious:** Dev mode hot-reloads static files transparently. Switching to prod mode (for testing auth, native image, etc.) silently changes this behaviour. The symptom (changes not appearing) is identical to a browser caching issue, which is the first thing developers check — causing significant time lost before the real cause is found.

*Score: 13/15 · Included because: high pain (caused extended debugging loop), high non-obviousness (dev vs prod behaviour divergence is invisible), applies to any Quarkus app with static resources · Reservation: none*
