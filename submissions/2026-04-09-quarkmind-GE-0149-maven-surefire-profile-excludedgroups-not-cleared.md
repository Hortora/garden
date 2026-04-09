**Submission ID:** GE-0149
**Date:** 2026-04-09
**Project:** quarkmind
**Type:** gotcha
**Stack:** Maven Surefire Plugin 3.5.x, Maven 3.x

## Maven Surefire: profile `<excludedGroups/>` doesn't clear base config — use `combine.self="override"`

**Symptom:** A Maven profile intended to run only `@Tag("benchmark")` tests runs zero tests instead. The profile sets `<groups>benchmark</groups>` and clears `<excludedGroups/>`, but the base Surefire config has `<excludedGroups>benchmark</excludedGroups>` — and the exclusion wins.

**Context:** Standard Maven plugin configuration inheritance: base config defines `<excludedGroups>benchmark</excludedGroups>`. A profile defines its own `<configuration>` block with `<groups>benchmark</groups>` and `<excludedGroups/>` (empty element to clear). Activating the profile with `-Pbenchmark` still runs zero tests.

**What was tried:** Setting `<excludedGroups/>` in the profile configuration. Using `<excludedGroups></excludedGroups>`. Using `-Dgroups=benchmark` on the command line (also overridden by the base config's `<excludedGroups>`).

**Root cause:** Maven merges plugin `<configuration>` blocks from profiles with the base `<configuration>` by default. An empty `<excludedGroups/>` in the profile does not remove the base value — it merges to produce the base value unchanged. The base exclusion always wins.

**Fix:** Add `combine.self="override"` to the profile's `<configuration>` to completely replace the base config rather than merging with it. Must also re-declare any base config items you need (e.g., `<argLine>`, `<systemPropertyVariables>`):

```xml
<!-- Base surefire config -->
<configuration>
    <excludedGroups>benchmark</excludedGroups>
    <argLine>@{argLine}</argLine>
    <systemPropertyVariables>
        <java.util.logging.manager>org.jboss.logmanager.LogManager</java.util.logging.manager>
    </systemPropertyVariables>
</configuration>

<!-- Profile that runs only benchmarks -->
<profile>
    <id>benchmark</id>
    <build>
        <plugins>
            <plugin>
                <artifactId>maven-surefire-plugin</artifactId>
                <configuration combine.self="override">  <!-- ← required -->
                    <groups>benchmark</groups>
                    <!-- excludedGroups deliberately absent -->
                    <argLine>@{argLine}</argLine>
                    <systemPropertyVariables>
                        <java.util.logging.manager>org.jboss.logmanager.LogManager</java.util.logging.manager>
                    </systemPropertyVariables>
                </configuration>
            </plugin>
        </plugins>
    </build>
</profile>
```

**Why non-obvious:** Maven's default merge behaviour is not documented on the Surefire plugin page. `combine.self` and `combine.children` are Maven core features buried in the plugin configuration docs. An empty element looks like it should clear a value.

**Suggested target:** `tools/maven.md`

*Score: 11/15 · Included because: silently runs zero tests, no error, requires obscure Maven attribute to fix · Reservation: Maven docs do cover combine.self, just not prominently*
