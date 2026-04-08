# Drools / Quarkus Gotchas and Techniques

---

## `DataSource.createStore()` fails with NullPointerException in plain JUnit when using `drools-quarkus`

**ID:** GE-0063
**Stack:** Apache KIE Drools 10.1.0, `drools-quarkus` extension, `drools-ruleunits-api`, Quarkus 3.34.2
**Symptom:**

```
NullPointerException: Cannot invoke "org.drools.ruleunits.api.DataSource$Factory.createStore()"
because the return value of "org.drools.ruleunits.api.DataSource$FactoryHolder.get()" is null
```

Occurs when calling `new MyRuleUnit()` in a plain JUnit test (not a `@QuarkusTest`). The `RuleUnitData` implementation creates `DataStore` fields in its constructor using `DataSource.createStore()`.

**Context:** Any `RuleUnitData` implementation with fields like `private final DataStore<X> store = DataSource.createStore()`, tested outside `@QuarkusTest`.

### What was tried

1. `RuleUnitProvider.get().createRuleUnitInstance(data)` — not reached because `new StrategyRuleUnit()` itself throws at field initialisation
2. Adding `drools-ruleunits-impl` explicitly — still fails; the impl module alone doesn't initialize the factory

### Root cause

`DataSource.createStore()` delegates to `DataSource.FACTORY.createStore()` where `FACTORY` is a service-loader-backed singleton. The `drools-quarkus` extension initializes this factory at **Quarkus build time** through its deployment processor. In plain JUnit — without Quarkus boot — the `FactoryHolder` is never populated, so `get()` returns `null`.

### Fix

Test using `@QuarkusTest` — it's the mandatory annotation for any test that exercises `RuleUnitData` or fires Drools rules via the `drools-quarkus` extension:

```java
@QuarkusTest
class DroolsStrategyTaskIT {

    @Inject @CaseType("starcraft-game") StrategyTask strategyTask;

    @Test
    void strategyIsDefendWhenEnemiesVisible() {
        DefaultCaseFile cf = buildCaseFile(50, 0);
        strategyTask.execute(cf);
        assertThat(cf.get(StarCraftCaseFile.STRATEGY, String.class)).contains("DEFEND");
    }
}
```

The Drools rule logic itself can be verified separately through a plain Java implementation (identical logic, no Drools dependency) — keeping the fast JUnit suite for logic coverage and `@QuarkusTest` only for DRL integration.

### Why non-obvious

`DataSource.createStore()` looks like a plain static factory — no parameters suggests it should be self-contained. Nothing in the method signature or Javadoc indicates it requires Quarkus boot. The NPE appears to be a classloading or initialization error (null factory), not a Drools-specific error, making it easy to misdiagnose as a missing dependency or classpath issue.

The natural approach — use `RuleUnitProvider.get()` for non-CDI testing (as documented in Drools standalone guides) — fails before you even reach `RuleUnitProvider` because the NPE is thrown in the `RuleUnitData` constructor.

*Score: 12/15 · Included because: `DataSource.createStore()` looks self-contained; error message doesn't mention Quarkus boot or the factory initialization model · Reservation: none*

---

## Drools 10 Rule Units DRL: three silent syntax traps with Java records and OOPath patterns

**ID:** GE-0056
**Stack:** Apache KIE Drools 10.1.0, DRL Rule Units (`unit` declaration), Java records
**Symptom:**

1. **Empty pattern brackets** — `$b: /builders[]` causes: `[ERR 101] no viable alternative at input ']'` at the `[` position.

2. **`type` keyword clash** — `$b: /buildings[type == BuildingType.GATEWAY]` causes: `[ERR 101] no viable alternative at input 'type'` — parser treats `type` as a keyword.

3. **`isComplete()` accessor** — `$b: /buildings[isComplete == true]` silently fails or produces a constraint error — the `is` prefix strips the property name per JavaBean convention, making Drools look for property `complete` not `isComplete`.

All three produce parse errors thrown as `DroolsParserException` at `@QuarkusTest` startup.

**Context:** DRL Rule Units with OOPath-style patterns (`/dataStoreName[constraints]`). Facts are Java records (immutable, component accessor methods only, no traditional getters).

### Root cause (per issue)

1. **Empty brackets**: In Drools OOPath, the no-constraint pattern is `/storeName` without any brackets. Empty `[]` is not valid syntax.

2. **`type` keyword**: In DRL, `type` is a reserved keyword used in `declare type` declarations. It cannot appear as a bare identifier in constraint position.

3. **`isComplete` accessor**: Java records with a boolean component named `isComplete` generate a method `isComplete()` which follows the JavaBean `is` prefix convention. Drools applies JavaBean property naming: `isComplete()` → property name `complete`. Use `complete == true` or `this.isComplete() == true` to bypass.

### Fix

Use `this.method()` explicit accessor syntax for ALL record-based constraints in DRL Rule Units:

```drl
// Wrong — empty brackets, type keyword, isComplete prefix ambiguity
$b: /buildings[ type == BuildingType.GATEWAY ]
$b: /buildings[ isComplete == true ]
$b: /builders[]

// Correct — explicit method calls, no-bracket no-constraint pattern
$b: /buildings[ this.type() == BuildingType.GATEWAY ]
$b: /buildings[ this.isComplete() == true ]
$b: /builders
```

Combined example from production code:
```drl
rule "Build Gateway"
    salience 100
when
    $builder: /builders                                                         // no constraint: no brackets
    not /buildings[ this.type() == BuildingType.GATEWAY ]                     // type() avoids keyword
    /buildings[ this.type() == BuildingType.PYLON, this.isComplete() == true ] // isComplete() explicit
then
    buildDecisions.add("GATEWAY");
end
```

### Why non-obvious

- Empty `[]` looks like "any element" in array/collection contexts (Java, most languages). The no-constraint OOPath pattern `/store` (without brackets) is not obviously different.
- `type` as a reserved keyword in DRL is not documented prominently.
- `isComplete` looks like a direct field name (matching the Java field `boolean isComplete`), but Drools applies JavaBean method-to-property mapping.
- The `this.method()` workaround is not in the DRL Rule Units getting-started guide for Java records.

*Score: 12/15 · Included because: three distinct traps all point at the same `this.method()` fix, which is non-obvious and not in the docs · Reservation: experienced Drools users may know about keyword clashes*
