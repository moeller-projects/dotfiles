---
description: Enterprise performance-focused review
agent: review
---

# ENTERPRISE PERFORMANCE REVIEW

Mode: Deterministic  
Scope: Diff or module  
Mutation: Forbidden  

Performance-only analysis.

---

## STEP 1 — SCOPE NORMALIZATION

Normalize:

- diff:<hash>
- module:<path>

If unclear → STOP.

---

## STEP 2 — CACHE

Namespace: perf-review  
Key components:

- diff hash or module hash
- governance version
- skill_version

Call `analysis-cache`.

---

## STEP 3 — PERFORMANCE ANALYSIS

Evaluate:

### CPU
- Expensive loops
- Redundant computations
- Missing memoization

### IO
- Blocking calls
- Unbounded async
- N+1 queries

### Memory
- Large allocations
- Retained objects
- Leaks

### Concurrency
- Lock contention
- Async misuse
- Deadlock risk

### Scalability
- O(n²) patterns
- Unbounded collections
- Missing batching

---

## OUTPUT FORMAT

### Summary
Performance impact overview.

### Performance Findings

- Severity:
- Category:
- File:
- Evidence:
- Impact:
- Suggested Optimization:

If none:
"No significant performance regressions detected."

### Performance Risk Level
Low | Moderate | Elevated | High

---

No formatting commentary.
No stylistic suggestions.
Performance focus only.