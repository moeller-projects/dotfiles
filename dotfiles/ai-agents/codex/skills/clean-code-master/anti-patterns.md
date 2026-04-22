# Skill Anti-Patterns

These are failures in how Clean Code Master behaves.

They are not code smells in the target system.
They are execution anti-patterns for the skill itself.

## 1. Aesthetic Churn

Bad:
- “Rename this, move that, split this class”
- no measurable benefit
- no real complexity reduction

Good:
- Recommend change only when at least one metric improves:
  - complexity
  - duplication
  - fan-out
  - boundary count
  - testability

---

## 2. Fabricated Metrics

Bad:
- “Cyclomatic complexity is 14”
- exact number without calculation evidence

Good:
- `[INFERRED] Cyclomatic complexity is ~10–12 based on visible branching.`
- use exact values only when actually measurable

---

## 3. Rewrite Reflex

Bad:
- whole-file rewrite for one nested conditional
- abstraction explosion for local duplication

Good:
- start with guard clauses
- extract method
- preserve structure when possible
- keep patch minimal unless user asks for broader change

---

## 4. Missing Evidence Tags

Bad:
- “This architecture is wrong.”
- “This definitely violates DDD.”

Good:
- `[OBSERVED] Domain service directly references infrastructure client.`
- `[INFERRED] This likely violates dependency direction.`
- `[ASSUMPTION] Full layer map is not available.`

---

## 5. No-Risk Refactor Advice

Bad:
- “Split the class”
- no blast radius warning
- no verification guidance

Good:
- `Risk: medium`
- `Verification: add characterization tests before split`

---

## 6. Advice Without Verification

Bad:
- “Extract abstraction”
- no test recommendation
- no safety plan

Good:
- every meaningful refactor includes:
  - risk
  - verification
  - expected improvement

---

## 7. Forcing Change When Code Is Fine

Bad:
- always finding something
- recommending refactor for “cleanliness”

Good:
- use `NO CHANGE` when thresholds are acceptable and no material issue exists

---

## 8. Architecture Guessing

Bad:
- inventing service boundaries
- assuming framework conventions
- assuming dependency rules not shown

Good:
- stay grounded in visible code and explicit context only

---

## 9. Severity Inflation

Bad:
- everything marked high or critical

Good:
- severity reflects:
  - blast radius
  - correctness risk
  - maintainability damage
  - boundary impact

---

## 10. Patch Mode Drift

Bad:
- user asked for minimal patch
- output becomes full redesign plan

Good:
- patch mode stays local and behavior-preserving
- broader redesign belongs in plan mode