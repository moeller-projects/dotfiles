---
description: Enterprise PR governance (multi-dimensional deterministic evaluation)
agent: review
---

# ENTERPRISE PR GOVERNANCE

Mode: Deterministic  
Mutation: Forbidden  
Caching: Mandatory  
Scope: Diff required  

This command performs structured multi-dimensional PR evaluation.

No code modification.
No patch generation.

---

## STEP 1 — REQUIRE DIFF

If not provided:

- Derive git diff (base → head).
- Normalize to diff:<hash>.

If no diff → STOP.

---

## STEP 2 — GLOBAL CACHE LOOKUP

Namespace: pr-govern

Key components:

- governance_version
- diff_hash
- repo_id
- policy_version

Call `analysis-cache` lookup.

If HIT:
  reuse artifact
If MISS:
  perform full evaluation
  store structured artifact

Never cache raw narrative.

---

## STEP 3 — EVALUATION DIMENSIONS

### 1. Code Correctness
Logical integrity.
Edge cases.
Invariant adherence.

### 2. Scope Discipline
Unrelated changes?
Formatting drift?
Threshold violation risk?

### 3. Mutation Contract
Excessive file changes?
Import reordering?
Cosmetic rewrite?

### 4. Security Review
Injection risks.
Auth boundary violations.
Sensitive exposure.

### 5. Regression Risk
Behavioral changes.
Contract modifications.
Backward compatibility risks.

### 6. Performance Risk
Blocking IO.
N+1 patterns.
Unbounded allocations.
Concurrency hazards.

### 7. Architectural Integrity
Layering violations.
Dependency direction drift.
Boundary leakage.

### 8. Test Coverage Delta
Changed logic without updated tests?
Missing branch coverage?

---

## STEP 4 — RISK SCORING

Assign:

- Correctness Risk
- Security Risk
- Regression Risk
- Performance Risk
- Architectural Risk

Each:
Low | Moderate | Elevated | High

Compute Overall PR Risk:
Low | Moderate | Elevated | High | Critical

---

## STEP 5 — OUTPUT FORMAT (MANDATORY)

### PR Summary
≤6 technical lines.

---

### Dimension Findings

For each issue:

- Severity:
- Category:
- File:
- Evidence:
- Risk:
- Required Action:

---

### Governance Verdict

- Approved
- Approved with Conditions
- Changes Required
- Blocked

---

### Risk Matrix

| Dimension | Risk |
|------------|------|
| Correctness | |
| Security | |
| Regression | |
| Performance | |
| Architecture | |

---

### Mutation Contract Verdict

- Compliant
- Violates Contract

If violation:
Specify file and reason.

---

## STRICT RULES

You MUST NOT:

- Generate patch
- Refactor code
- Expand scope
- Suggest stylistic cleanup

You MUST:

- Be concise
- Be structured
- Avoid narrative tone
- Avoid redundant explanation

---

## STOP CONDITIONS

STOP if:

- Diff missing
- Scope unclear
- Required files unavailable

Request clarification.

---

END COMMAND