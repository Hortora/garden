**Submission ID:** GE-0143
**Date:** 2026-04-09
**Type:** gotcha
**Project:** drools-vol2 (cross-project — applies to any Java hierarchy)
**Suggested target:** java/inheritance-gotchas.md (new file) or java/maven.md

---

## `final hashCode()` in parent — update protected field from setters instead of overriding

**Stack:** Java (all versions)

**Symptom:**
Compile error: `hashCode() in SubClass cannot override hashCode() in ParentClass — overridden method is final`

**Context:**
When implementing structural equality in a subclass where the parent class declares `hashCode()` as `final`. In Drools vol2: `BaseNode` has `public final int hashCode()` that returns `this.hashcode` (a protected field). Tried adding `@Override public int hashCode()` to `BetaNode` to implement structural equality based on node inputs.

**What was tried:**
```java
// In BetaNode — FAILS to compile
@Override
public int hashCode() {
    int h = getClass().hashCode();
    h = 31 * h + (leftInput  != null ? leftInput.getId()  : 0);
    h = 31 * h + (rightInput != null ? rightInput.getId() : 0);
    return h;
}
```

**Root cause:**
Java does not allow overriding `final` methods. The natural instinct to add `@Override public int hashCode()` is blocked at compile time. The error message correctly identifies the problem but gives no direction for the fix.

**Fix:**
If the parent exposes a `protected` field that its `final hashCode()` reads, write an `updateHashCode()` method in the subclass that computes the hash and assigns it directly to that field. Call it from every setter that affects the hash:

```java
// In BetaNode
private void updateHashCode() {
    int h = getClass().hashCode();
    h = 31 * h + (leftInput  != null ? leftInput.getId()  : 0);
    h = 31 * h + (rightInput != null ? rightInput.getId() : 0);
    this.hashcode = h;  // protected int hashcode declared in BaseNode
}

@Override
public void setLeftInput(BaseNode n) {
    super.setLeftInput(n);
    updateHashCode();
}

public void setRightInput(BaseNode n) {
    this.rightInput = n;
    updateHashCode();
}
```

**Why non-obvious:**
The compile error points at `hashCode()` but not at the solution. Standard advice ("implement hashCode in the subclass") doesn't apply when the method is final. The fix requires knowing (a) the parent has a mutable protected field that the final method reads, and (b) to update it from setters rather than at compute time. Both facts require reading the parent class internals.

*Score: 12/15 · Included because: non-obvious workaround to a hard compiler wall; the field-mutation approach is counterintuitive · Reservation: only applicable when parent exposes the mutable field*

**IDs scanned for duplicates:** GE-0004, GE-0023, GE-0024, GE-0037, GE-0058 (java/ category — none similar)
