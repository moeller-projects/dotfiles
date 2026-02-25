---
description: Enterprise deterministic code review (diff-aware, cache-integrated)
agent: review
---

# ENTERPRISE CODE REVIEW COMMAND

Mode: Deterministic  
Mutation: Forbidden  
Caching: Mandatory for structural analysis  

---

## INPUT MODES

This command supports the following invocation patterns:

1. Review current working tree diff
2. Review specific git diff (base → head)
3. Review provided unified diff
4. Review PR description + diff
5. Review single file

---

## STEP 1 — DETERMINE REVIEW SCOPE

If not explicitly provided:

- Default to current git diff against default branch.
- If no diff present → STOP and request scope clarification.

Normalize scope to one of:

- diff:<hash>
- file:<path>
- module:<path>
- repo:<root> (explicit only)

---

## STEP 2 — CACHE LOOKUP (STRUCTURAL ANALYSIS)

If review includes structural analysis (e.g., architecture, dependency graph, blast radius):

1. Compute deterministic cache key:
   - skill_name = review
   - skill_version = 1.0.0
   - governance_version
   - normalized scope
   - diff hash (if applicable)

2. Call `analysis-cache`:
   - action: lookup
   - namespace: code-review
   - key: computed_key

If cache_hit=true:
   - reuse artifact
If cache_hit=false:
   - perform structural analysis
   - store artifact

Never cache raw LLM text.

---

## STEP 3 — REVIEW EXECUTION

Perform structured evaluation across:

### 1. Correctness
- Logical errors
- Missing validations
- Edge cases
- Invariant violations

### 2. Security
- Injection risks
- Authorization flaws
- Unsafe assumptions
- Data exposure

### 3. Architecture
- Layer violations
- Dependency direction violations
- Tight coupling introduction
- Boundary leaks

### 4. Scope Discipline
- Unrelated changes?
- Refactors outside scope?
- Formatting-only drift?

### 5. Mutation Contract Compliance
- Excessive changes?
- Import reordering?
- Cosmetic edits?

### 6. Performance
- N+1 risk
- Blocking IO
- Expensive allocations
- Missing caching opportunities

### 7. Test Coverage
- Missing tests?
- Insufficient branch coverage?
- Regression risk areas?

---

## OUTPUT FORMAT (MANDATORY)

Return structured output only:

### Summary
Short technical overview (≤6 lines).

### Findings

For each issue:

- Severity: Critical | High | Medium | Low
- Category: Correctness | Security | Architecture | Scope | Performance | Tests
- File:
- Evidence:
- Risk:
- Recommended Fix:

If no issues:
State explicitly:
"No critical or high severity issues detected."

---

### Scope Verdict
- Within Scope
or
- Out of Scope (explain)

### Mutation Contract Verdict
- Compliant
or
- Violates Contract (explain)

### Risk Score
Low | Moderate | Elevated | High

---

## STRICT RULES

You MUST NOT:

- Generate patches
- Suggest stylistic refactors
- Recommend formatting changes
- Expand feature scope
- Rewrite code

You MUST:

- Be concise
- Be technical
- Avoid narrative tone
- Avoid conversational language
- Avoid emoji
- Avoid redundant explanation

---

## STOP CONDITIONS

STOP and request clarification if:

- Diff missing
- Scope unclear
- Repo context unavailable
- Required files unreadable

Do not guess.

---

END COMMAND