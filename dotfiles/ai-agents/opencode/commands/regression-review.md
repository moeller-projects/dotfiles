---
description: Enterprise regression risk review (delta-focused)
agent: review
---

# ENTERPRISE REGRESSION REVIEW

Mode: Deterministic  
Scope: Diff required  
Mutation: Forbidden  

Focus exclusively on regression risk introduced by changes.

---

## STEP 1 — REQUIRE DIFF

If no diff provided → STOP.

Scope normalized to:

- diff:<hash>

---

## STEP 2 — CACHE

Namespace: regression-review  
Key components:

- diff hash
- governance version
- skill_version

Lookup → reuse if hit → store if miss.

---

## STEP 3 — REGRESSION ANALYSIS

Evaluate:

### Behavior Changes
- Changed return values
- Modified conditions
- Altered branching logic

### Invariant Violations
- Contract changes
- Assumption breaks
- Interface changes

### Hidden Side Effects
- State mutation
- Transaction boundary changes
- Async behavior changes

### Backward Compatibility
- API contract changes
- DTO modifications
- Schema changes

### Test Coverage Delta
- Modified code without test updates?
- Branch coverage risk?

---

## OUTPUT FORMAT

### Summary
Concise regression overview.

### High-Risk Changes
List only significant risk changes.

### Regression Risk Areas
- File:
- Behavior impacted:
- Failure mode:
- Recommended safeguard:

### Regression Risk Level
Low | Moderate | Elevated | High

---

No stylistic commentary.
No architecture expansion.
Regression focus only.