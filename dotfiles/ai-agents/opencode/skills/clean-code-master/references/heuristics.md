# Heuristics Guide

This document defines deterministic decision heuristics used by clean-code-master
when precise metrics are unavailable or partial code context exists.

Heuristics are NOT guesses.
They are structured, explainable approximations.

Always tag:
- [OBSERVED]
- [INFERRED]
- [ASSUMPTION]

—

# 1. Hotspot Detection Heuristics

When full repo analytics are unavailable, prioritize review in this order:

1. Entry points (controllers, handlers, CLI commands)
2. Files with:
   - longest methods
   - deepest nesting
   - most conditionals
3. Modules that:
   - access multiple boundaries (db + network + filesystem)
   - perform orchestration
4. Classes with:
   - many public methods
   - many injected dependencies
5. Code containing:
   - complex switch/if chains
   - error swallowing
   - boolean flag parameters

If git history is available, prioritize:
- Most changed files
- Files frequently touched in bugfix commits
- Files with high churn + high complexity

—

# 2. Risk Estimation Heuristics

Estimate refactor risk based on blast radius.

Low Risk:
- Extract method
- Rename variable
- Reduce nesting via guard clauses
- Introduce local pure function

Medium Risk:
- Split class
- Move method across files
- Introduce interface abstraction
- Remove duplication across module

High Risk:
- Change public API
- Modify dependency direction
- Introduce new abstraction layer
- Change persistence boundaries

Critical Risk:
- Cross-service contract changes
- Schema changes
- Concurrency model changes

—

# 3. Boundary Mixing Detection

Flag potential boundary mixing if a method:

- Performs domain logic AND
- Calls:
  - database
  - HTTP client
  - message bus
  - filesystem
  - cache

Heuristic Rule:
If more than one external boundary is invoked in a method,
mark as:
- [INFERRED] boundary mixing risk

—

# 4. Duplication Detection (Without Full AST)

If:
- 3+ methods share similar conditional structures
- Copy-pasted validation logic
- Repeated mapping logic across files

Then:
Mark as duplication candidate.

Avoid:
Premature abstraction for only 2 minor repetitions.

—

# 5. Naming Clarity Heuristic

Suspicious names:

- Manager
- Helper
- Util
- Processor
- Handler (without context)
- Data
- Info
- Service (generic)

If method name:
- contains “process”, “handle”, “execute” without domain noun
- uses boolean flags to alter behavior

Flag for naming clarity review.

—

# 6. Overengineering Detection

Do NOT recommend refactor if:

- Cyclomatic ≤ 5
- Nesting ≤ 2
- No duplication
- Clear naming
- Stable boundary separation

Heuristic Rule:
Refactor must reduce complexity by at least one measurable unit.

Avoid refactoring purely for aesthetic preference.

—

# 7. Testability Heuristic

Code is likely hard to test if:

- Uses static/global state
- Instantiates dependencies internally
- Uses system time directly
- Uses randomness directly
- Calls external boundaries in core logic

Mark as:
Testability Debt.

—

# 8. Cognitive Load Estimation

Approximate cognitive load as:

Cognitive Load ≈
- nesting depth
- number of branches
- number of responsibilities
- number of external dependencies

If:
- >3 responsibilities in same function
- nested conditionals inside loops
- long parameter list (>5)

Mark as high cognitive load.

—

# 9. Refactor Priority Heuristic

Priority = Complexity × Churn × Boundary Exposure

If churn unknown:
Use:
Complexity × Boundary Count

High complexity + multi-boundary exposure
→ Highest refactor priority.

—

# 10. Assumption Handling

If required context is missing:

- Do not fabricate metrics.
- Use "~" for approximate.
- Mark as [ASSUMPTION].
- Request required input if critical.

Return BLOCKER only if:
- Architectural impact cannot be assessed safely.