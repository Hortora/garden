# permuplate Index

| ID | Title | Type | Score |
|----|----|-------|-------|
| GE-0005 | @PermuteReturn methods with hand-written return types silently disappear via boundary omission | gotcha | 12/15 |
| GE-0007 | typeArgList(from, to, style) accepts dynamic JEXL expressions for from/to, not just constants | undocumented | 10/15 |
| GE-20260416-17bdf4 | PermuteTypeParamTransformer must run BEFORE applySourceTypeParams — wrong order causes type param doubling | gotcha | 10/15 |
| GE-20260416-9d1147 | PermuteMojo's generate() chain already handles template composition ordering — no extra infrastructure needed | technique | 11/15 |
| GE-20260416-f316e2 | @PermuteSource and other source-only annotations must be stripped from generated output | gotcha | 9/15 |
| GE-20260417-c01ea4 | typeArgList() inside @PermuteDeclr type strings requires single-quoted style argument | technique | 8/15 |
| GE-20260417-d1ba21 | Two independent @PermuteTypeParam axes in one class produce duplicate type parameters | gotcha | 8/15 |
| GE-20260417-f03d4f | @PermuteTypeParam on a non-first type parameter keeps A fixed and expands only the remainder | technique | 9/15 |
| GE-20260418-90907d | @PermuteCase body with Java string literals silently produces empty switch cases | gotcha | 12/15 |
| GE-20260420-362475 | Use IdentityHashMap when keying on JavaParser AST nodes that transformers will mutate | technique | 10/15 |
| GE-20260421-876557 | Cross-product SAM interface families from one template via @PermuteVar + JEXL ternary macros | technique | 11/15 |
| GE-20260421-bbc3a9 | @PermuteParam inside @PermuteMethod silently skips expansion — inner variable not in scope | gotcha | 9/15 |
| GE-20260421-c37188 | EvaluationContext.evaluate() always returns String — numeric macros silently break evaluateInt() | gotcha | 10/15 |
| GE-20260421-e86212 | PermuteAnnotationTransformer never called in non-inline pipeline — @PermuteAnnotation silently ignored | gotcha | 10/15 |
| GE-20260426-14d193 | Use T directly in @PermuteReturn typeArgs to avoid @PermuteTypeParam on standalone methods | technique | 10/15 |
| GE-20260426-55d1b1 | keepTemplate=true preserves sentinel type param even for empty @PermuteTypeParam range | gotcha | 9/15 |
| GE-20260426-f987a9 | @PermuteDeclr(name=..., type=...) on a METHOD causes duplicate generation for all arities | gotcha | 8/15 |
| GE-20260427-5413df | @PermuteReturn(when="i == N") generates a method only on a specific arity in a Permuplate template | technique | 9/15 |
| GE-20260427-5c5bab | @PermuteFilter is silently ignored on plain template methods — use single-clone @PermuteMethod to enable per-arity suppression | gotcha | 11/15 |
| GE-20260427-68030c | Introduce a new interface class family to add overloads that would otherwise conflict via Java type erasure | technique | 10/15 |
| GE-20260427-cf8a08 | @PermuteReturn(when=...) is silently ignored on methods with non-Object declared return types | gotcha | 12/15 |
| GE-20260428-28391e | Permuplate keepTemplate=true: @PermuteBody replaces generated classes only — template class body unchanged | gotcha | 11/15 |
