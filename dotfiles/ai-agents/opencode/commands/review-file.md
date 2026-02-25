---
description: Enterprise deterministic single-file review
agent: review
---

# ENTERPRISE FILE REVIEW

Mode: Deterministic  
Scope: Single file only  
Mutation: Forbidden  

---

## STEP 1 — SCOPE VALIDATION

Input MUST specify:

- file path (repo-relative)

If file not found → STOP.

Do not expand scope beyond this file.

---

## STEP 2 — CACHE (OPTIONAL)

If file-level structural artifact exists:

- namespace: review-file
- key components:
  - file path
  - file hash
  - governance version
  - skill_version

Call `analysis-cache` lookup.
Reuse if hit.
Store if miss.

---

## STEP 3 — REVIEW DIMENSIONS

Evaluate:

### Correctness
- Logic errors
- Null handling
- Edge cases
- Incorrect assumptions

### Security
- Injection vectors
- Unsafe parsing
- Missing validation
- Exposure of sensitive data

### Architecture
- Layer violations
- Tight coupling
- Dependency misuse

### Maintainability
- Complexity hotspots
- Large functions
- Hidden side effects

### Tests
- Missing tests?
- Untested branches?

---

## OUTPUT FORMAT

### File
<path>

### Summary
≤6 technical lines.

### Findings
For each issue:

- Severity:
- Category:
- Evidence:
- Risk:
- Recommended Fix:

If none:
"No critical or high severity issues detected."

### Risk Score
Low | Moderate | Elevated | High

---

No patches.
No refactors.
No unrelated suggestions.