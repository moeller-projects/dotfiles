# Examples

## 1. Audit Mode — Local Complexity Issue

Input:
“Review this handler for maintainability.”

Output:
```text
A) Context
- Goal: maintainability audit
- Scope: OrderHandler.ts
- Tier: Small
- Constraints: no behavior change requested
- Assumptions: [ASSUMPTION] full test suite not provided

B) Findings
| Item | Location | Debt Type | Severity | Evidence | Recommendation |
| 1 | OrderHandler.handle | Structural Debt | Medium | [OBSERVED] Nested branching depth is 4 with repeated validation paths. | Extract guard clauses + isolate validation. |
| 2 | OrderHandler.handle | Testability Debt | Medium | [OBSERVED] Method constructs Date directly. | Inject time provider or isolate timestamp generation. |

C) Complexity Snapshot
| Symbol | Cyclomatic | Nesting | Length | Fan-out | Notes |
| handle | ~9 | 4 | 58 | 3 | [INFERRED] complexity from visible branches |

D) Maintainability Score
- Score: 74
- Band: Warning
- Top 3 drivers:
  - nested control flow
  - repeated validation paths
  - direct time dependency

E) Budget Violations
- None observed

F) Refactor Guidance
| Step | Change | Risk | Verification | Expected Metric Reduction |
| 1 | Add guard clauses for invalid states | Low | unit tests for each early-return case | Nesting 4 -> 2 |
| 2 | Extract validation helper | Low | characterization test for validation matrix | reduce duplication |
| 3 | Isolate time access | Low | deterministic test using fake clock | improve testability |

G) Test Strategy
- add branch coverage for all validation exits
- freeze time in tests

H) Decision
- IMPROVE
````

---

## 2. Audit Mode — No Change

Input:
“Check this service for clean code issues.”

Output:

```text
Decision: NO CHANGE

Why:
- [OBSERVED] Cyclomatic complexity appears low.
- [OBSERVED] Naming is specific and domain-oriented.
- [OBSERVED] No meaningful duplication or boundary mixing found.
- [OBSERVED] Public surface area is small and cohesive.

Recommendation:
- Keep implementation as-is.
- Add or maintain tests around critical behavior only.
```

---

## 3. Plan Mode — God Class

Input:
“Create a safe refactor plan for this billing service.”

Output:

```text
Goal:
Reduce structural complexity in BillingService without changing behavior.

Constraints:
- preserve public API
- avoid schema changes
- incremental only

Assumptions:
- [ASSUMPTION] BillingService is used by multiple callers
- [ASSUMPTION] change budget favors low-to-medium risk steps first

1. Hotspots
- [OBSERVED] BillingService validates input, computes pricing, calls repository, and emits notifications.
- [OBSERVED] 11 public methods and 6 injected dependencies indicate low cohesion.

2. Refactor sequence
1. add characterization tests for current billing flows
2. extract pricing computation into pure domain component
3. extract notification orchestration behind interface
4. isolate persistence mapping from business rules
5. reassess remaining public surface

3. Risk per step
- step 1: low
- step 2: medium
- step 3: medium
- step 4: medium
- step 5: low

4. Required tests
- golden-path billing scenarios
- discount edge cases
- notification trigger regression tests
- persistence mapping regression tests

5. Stop conditions
- stop after each extraction if complexity drops and behavior stays stable
- do not continue into API redesign without explicit approval

6. Expected metric improvements
- fan-out reduction
- lower method responsibility count
- improved test isolation
- lower boundary mixing
```

---

## 4. Patch Mode — Minimal Safe Improvement

Input:
“Give me the smallest worthwhile clean-code patch.”

Output:

```text
Decision: PATCH

Why:
- [OBSERVED] Validation and execution logic are interleaved in one method.
- [OBSERVED] A guard-clause extraction reduces nesting without changing flow.

Minimal change target:
- one method
- no public API changes
- no new abstraction layer

Risk:
- low

Required tests:
- invalid input returns unchanged
- valid path still reaches repository call
- side effects remain unchanged

Expected metric improvement:
- nesting 4 -> 2
- lower cognitive load

Patch guidance:
- extract early invalid-state checks to top of method
- keep orchestration order unchanged
- do not split file or introduce new class
```

---

## 5. CI Mode — Fail

Input:
“Run clean-code-master in CI mode.”

Output:

```text
Decision: Fail

Findings:
- [OBSERVED] BillingModule exceeds fan-out budget.
- [OBSERVED] PaymentHandler contains critical nesting and multi-boundary orchestration.
- [OBSERVED] No tests provided for identified hotspot.

Budget violations:
- BillingModule fan-out > 15
- PaymentHandler nesting > 4

JSON:
{
  "score": 61,
  "band": "Warning",
  "critical_findings": 1,
  "budget_violations": ["BillingModule", "PaymentHandler"],
  "delta_from_baseline": -9,
  "decision": "Fail"
}

—END-CLEAN-CODE-MASTER—
```

---

## 6. Blocker

Input:
“Refactor this whole monorepo for clean code.”
(only one partial diff provided)

Output:

```text
BLOCKER:
Requested refactor scope exceeds safe analysis capacity and lacks required architectural context.

REQUIRED INPUT:
Top 3 hotspot files or a bounded module scope with tests and dependency context.

NEXT QUESTION:
Which module should be analyzed first?
```