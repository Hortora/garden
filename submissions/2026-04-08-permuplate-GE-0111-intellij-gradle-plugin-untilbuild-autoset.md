**Submission ID:** GE-0111
**Date:** 2026-04-08
**Type:** gotcha
**Suggested target:** `intellij-platform/inspections.md` (or `intellij-platform/gradle-build.md`)
**File header needed:** `# IntelliJ Platform — Gradle Build Gotchas` (if separate file)

---

## `intellij-platform-gradle-plugin` 2.x Auto-Sets `untilBuild` to `sinceBuild.*`, Blocking Newer IDEs

**Stack:** IntelliJ Platform Gradle Plugin 2.x (`org.jetbrains.intellij.platform`)

**Symptom:**
Plugin installs and works on the targeted IDE version but shows this error on
any newer IDE build:

```
Plugin 'MyPlugin' (version '1.0.0') is not compatible with the current version
of the IDE, because it requires build 232.* or older but the current build is IU-253.x
```

**Root cause:**
When only `sinceBuild` is specified in `ideaVersion`, the plugin 2.x automatically
derives `untilBuild` as `"${sinceBuild}.*"` — locking the plugin to that single
major version. Setting `sinceBuild = "232"` silently produces `until-build="232.*"`
in the generated `plugin.xml`, which IntelliJ interprets as "only compatible with
2023.2.x builds."

**Fix:**
Explicitly clear `untilBuild` using Kotlin's `provider { null }`:

```kotlin
intellijPlatform {
    pluginConfiguration {
        ideaVersion {
            sinceBuild = "232"                  // 2023.2 minimum
            untilBuild = provider { null }      // no upper bound — works on all future builds
        }
    }
}
```

The `provider { null }` idiom tells the plugin to omit the `until-build` attribute
from `plugin.xml` entirely, making the plugin compatible with all future IDE builds.

**Why non-obvious:**
The `untilBuild` derivation is not documented in the plugin 2.x migration guide.
Developers migrating from plugin 1.x (where omitting `untilBuild` meant "no upper bound")
expect the same behaviour. The error message says the plugin "requires build 232.* or
older" — suggesting the developer set an upper bound — when in fact they set nothing.
The `provider { null }` idiom is specific to Gradle's lazy property system and is
not mentioned in IntelliJ's documentation.

*Score: 12/15 · Included because: misleading error message, non-obvious fix, affects every new plugin targeting 2023.2+ · Reservation: may be fixed in a future plugin version*
