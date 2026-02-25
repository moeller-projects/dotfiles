---
description: Enterprise deterministic OpenSpec evaluation (spec compliance, delta-aware, cache-integrated)
agent: review
---

# ENTERPRISE OPENSPEC EVALUATION

Mode: Deterministic  
Mutation: Forbidden  
Caching: Mandatory  
Scope: Spec + optional diff  

This command evaluates an OpenSpec specification against repository state or diff.

It does NOT mutate code.
It does NOT generate patches.

---

## STEP 1 — SCOPE NORMALIZATION

Supported invocation modes:

1. Spec-only evaluation
2. Spec vs repository state
3. Spec vs git diff (delta mode)
4. Spec vs specific module

Normalize scope to:

- spec:<spec_name>
- diff:<hash>
- module:<path>

If spec not found → STOP.
If diff required but not present → STOP.

---

## STEP 2 — CACHE LOOKUP

Namespace: openspec-eval

Cache key components:

- policy_version
- governance_version
- skill_name = openspec-eval
- skill_version = 1.0.0
- spec_identifier (normalized)
- scope_id
- dependency_fingerprint
- diff_hash (if delta mode)

Call `analysis-cache`:

- action: lookup
- namespace: openspec-eval
- key: computed_key

If hit:
- reuse structured artifact
If miss:
- perform evaluation
- store structured artifact

Never cache raw narrative text.

---

## STEP 3 — EVALUATION DIMENSIONS

Evaluate specification against implementation across:

### 1. Structural Compliance
- Required modules exist?
- Expected boundaries respected?
- Layering preserved?

### 2. Contract Alignment
- DTOs match spec?
- Interfaces implemented as defined?
- Public surface consistent?

### 3. Invariant Compliance
- Domain rules enforced?
- Required validation paths present?
- Required guards implemented?

### 4. Delta Compliance (if diff mode)
- Diff violates spec constraints?
- New surface introduced?
- Removed required behavior?

### 5. Dependency Integrity
- Unexpected dependencies?
- Forbidden cross-boundary references?
- Architecture drift?

### 6. Missing Implementations
- Spec section not implemented?
- Placeholder logic?
- Incomplete workflows?

---

## STEP 4 — RISK ASSESSMENT

Classify deviations:

- Critical — violates mandatory spec constraint
- High — breaks contract but recoverable
- Medium — partial drift
- Low — minor alignment issue

---

## OUTPUT FORMAT (MANDATORY)

### Spec
<spec_name>

### Scope
<normalized_scope>

### Summary
Concise compliance overview (≤6 lines).

---

### Compliance Matrix

| Section | Status | Notes |
|----------|--------|-------|
| Architecture | Compliant / Drift | |
| Contracts | Compliant / Drift | |
| Invariants | Compliant / Drift | |
| Dependencies | Compliant / Drift | |
| Delta | Compliant / Drift | |

---

### Findings

For each issue:

- Severity:
- Spec Section:
- File:
- Evidence:
- Impact:
- Required Action:

---

### Compliance Verdict

- Fully Compliant
- Compliant with Minor Drift
- Non-Compliant
- Critically Non-Compliant

---

### Spec Risk Level

Low | Moderate | Elevated | High

---

## STRICT RULES

You MUST NOT:

- Propose refactors outside scope
- Generate patches
- Expand spec interpretation beyond written constraints
- Introduce new architecture ideas

You MUST:

- Stay literal to spec
- Use structured output
- Be concise
- Avoid narrative tone

---

## STOP CONDITIONS

STOP if:

- Spec ambiguous
- Required module missing
- Diff unavailable in delta mode
- Scope unclear

Request clarification.

---

END COMMAND