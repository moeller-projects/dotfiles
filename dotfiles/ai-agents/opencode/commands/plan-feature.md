---
description: Enterprise deterministic feature planning (spec-aware, cache-integrated)
agent: planner
---

# ENTERPRISE FEATURE PLANNING

Mode: Deterministic  
Mutation: Forbidden  
Caching: Mandatory for structural analysis  

This command produces a structured, minimal implementation plan.

No code is generated.
No patch is produced.

---

## STEP 1 — SCOPE NORMALIZATION

Input must define:

- Feature objective
- Target module or surface
- Optional constraints (no integration tests, minimal change, etc.)

Normalize scope to:

- module:<path>
- surface:<api/controller/interface>
- workflow:<entrypoint>

If unclear → STOP.

---

## STEP 2 — STRUCTURAL CONTEXT (CACHE-AWARE)

If architectural reasoning required:

1. Compute deterministic key:
   - namespace: plan-feature
   - governance_version
   - skill_version
   - normalized scope
   - dependency_fingerprint

2. Call `analysis-cache` lookup.
3. Reuse artifact on hit.
4. Store artifact if generated.

Never cache raw narrative.

---

## STEP 3 — PLAN GENERATION

Produce:

### Objective
One sentence technical description.

### Constraints
Explicit list (from request).

### Affected Files
Minimal set only.

### Change Strategy
Step-by-step plan:
1.
2.
3.

No pseudocode unless strictly necessary.

### Dependency Impact
- Direct dependencies
- Build/config impact
- Event/schema impact

### Risk Assessment
- Technical risk
- Regression risk
- Security considerations

### Test Strategy
- Unit tests required?
- Integration tests?
- Edge cases?

### Mutation Size Estimate
Estimated % change per file.

If any file expected >30% change:
Flag explicitly:
"Requires explicit rewrite authorization."

---

## STRICT RULES

You MUST NOT:

- Propose refactors outside feature
- Suggest architectural redesign
- Expand scope
- Generate code
- Generate diff

You MUST:

- Be concise
- Be structured
- Avoid narrative tone

---

END COMMAND