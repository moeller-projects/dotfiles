---
name: refactor-engine
description: Enterprise-grade architectural evolution and safe refactoring skill. Performs deterministic behavioral-invariant modeling, API surface protection, dependency graph validation, blast-radius estimation, semantic diff analysis, migration sequencing, and cross-skill safety orchestration. Designed for large monorepos and modular SaaS systems.
---

# Refactor Engine v2

## Intent

Engineer safe, reversible architectural evolution.

This skill does not simply “move code.”  
It preserves behavioral invariants, protects public contracts, prevents architectural drift, and orchestrates incremental refactoring with measurable blast radius control.

Supports:

- Behavioral invariant modeling
- Public API surface protection
- Dependency graph validation
- Architectural boundary enforcement
- Circular dependency prevention
- Blast radius estimation
- Migration strategy modeling
- Semantic diff validation
- Transaction & concurrency safety modeling
- Data migration planning
- Incremental commit sequencing
- Rollback & rollout strategies
- Cross-skill coordination hooks

Designed for:

- Large monorepos
- Modular SaaS systems
- Microservices
- DDD architectures
- Spec-driven workflows
- CI/CD pipelines

---

# 1. Hard Rules (Safety & Determinism)

- No broad rewrites without explicit scope.
- No public API changes without impact report.
- Preserve behavior unless explicitly approved to change.
- All conclusions must be tagged:
  - [OBSERVED]
  - [INFERRED]
  - [ASSUMPTION]
- All refactors must be reversible.
- Respect scope tier limits.
- If insufficient context → Blocker Format.

---

# 2. Required Inputs (Minimal)

At least one:

- Target module/class/file
- Desired refactor goal
- Architectural constraint (if any)
- Relevant code snippet or diff
- Optional dependency graph

If goal ambiguous:

Return:

- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

---

# 3. Scope Tiering

Default: Medium

Small:
- Single file/class
- ≤4 files modified
- No public surface changes
- Single-step plan

Medium:
- Single module
- ≤12 files modified
- API changes allowed with compatibility path
- ≤4 commit steps

Large:
- Cross-module refactor
- ≤30 files
- Migration plan mandatory
- ≤7 commit steps

Enterprise:
- Architectural restructuring
- ≤60 files (approval required)
- Versioning strategy required
- Multi-phase migration plan

If exceeded → Blocker Format.

---

# 4. Behavioral Invariant Modeling (Mandatory)

Before any structural change, extract invariants:

| Invariant | Source | Must Preserve | Evidence |
|-----------|--------|---------------|----------|

Examples:

- Validation rules
- Exception behavior
- Event emission timing
- Transaction boundary
- Idempotency guarantees
- Ordering guarantees
- Side effects
- Logging/audit requirements

If invariant unclear → [ASSUMPTION].

No refactor proceeds without invariant table.

---

# 5. Public API Surface Protection (Mandatory for Medium+)

Identify:

| API Surface | Type | Consumers | Compatibility Risk | Evidence |
|-------------|------|----------|--------------------|----------|

Types:

- HTTP endpoint
- Public method
- Event schema
- Shared DTO
- Interface contract

If unknown consumers → [ASSUMPTION].

---

# 6. Dependency & Architectural Validation

Using dependency graph:

- Detect new edges introduced.
- Detect potential cycles.
- Detect layer violations.
- Validate bounded context boundaries.
- Prevent domain → infra inversion.

If violation risk → propose inversion via interface/adapter.

---

# 7. Blast Radius Estimation

Compute transitive impact:

| Module | Distance | Impact Level |

Distance:

- 1 = direct
- 2 = indirect
- ≥3 = systemic

Systemic impact requires migration staging.

---

# 8. Refactor Category Classification

Classify refactor type:

| Category | Risk Level |
|----------|------------|
| Rename | Low |
| Extract method | Low |
| Move class | Medium |
| Interface change | High |
| Async introduction | High |
| Data model change | Critical |
| Module split/merge | High |

Adjust migration & testing requirements accordingly.

---

# 9. Semantic Diff Validation (Pre-Execution)

Before final patch:

Check:

- Did exception types change?
- Did nullability change?
- Did ordering change?
- Did side effects reorder?
- Did transaction scope move?
- Did concurrency behavior change?

List findings.

No semantic drift allowed unless approved.

---

# 10. Transaction & Concurrency Safety Modeling

If refactor touches:

- async code
- locking
- transaction boundaries
- parallel logic

Verify:

- lock scope unchanged
- no new race condition introduced
- transaction boundary preserved
- idempotency preserved

Mark unknown areas as [ASSUMPTION].

---

# 11. Data Migration Modeling (If Applicable)

If data model changes:

Provide:

- Read path impact
- Write path impact
- Backward compatibility window
- Dual-read / dual-write strategy
- Idempotent migration script outline
- Migration verification plan
- Rollback strategy

No schema deletion without staging plan.

---

# 12. Migration Strategy (If API Changes)

For public changes:

- Old contract
- New contract
- Deprecation approach
- Versioning strategy
- Adapter/compatibility layer
- Removal timeline (optional)

No removal without compatibility window.

---

# 13. Incremental Commit Plan

Ordered reversible steps:

Step 1: Introduce abstraction (no behavior change)  
Step 2: Migrate internal usage  
Step 3: Add compatibility layer  
Step 4: Update consumers  
Step 5: Deprecate old surface  
Step 6: Optional cleanup (gated)

Each step must be independently buildable.

---

# 14. Risk Table

For each major change:

| Change | Risk Type | Severity | Mitigation |

Risk types:

- Functional regression
- API breakage
- Race condition
- Deadlock
- Persistence corruption
- Cross-module breakage

---

# 15. Cross-Skill Coordination Hooks

Optionally trigger:

- monorepo-navigator → validate new graph edges
- test-forge → generate guard tests
- threat-modeler → validate boundary changes
- perf-analyst → verify hot path stability

No automatic invocation; provide structured recommendation.

---

# 16. Refactor ROI Evaluation

Before heavy refactor:

| Benefit | Structural Impact | Effort | Risk | Justified? |

Prevents unnecessary architectural churn.

---

# 17. Rollback Strategy

Define:

- How to revert commit
- Feature flag option (if applicable)
- Compatibility path restoration
- Data/schema rollback (if needed)
- Monitoring signals for rollback trigger

---

# 18. Output Structure

1. Goal Clarification
2. Behavioral Invariants Table
3. API Surface Summary
4. Dependency & Blast Radius
5. Refactor Category & Risk
6. Impact Matrix
7. Migration Strategy
8. Incremental Commit Plan
9. Semantic Validation Checklist
10. Rollback Plan
11. Patch (if executing)
12. One focused question (if required)

Prefer structured tables.

---

# 19. Blocker Format

Return ONLY:

- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

---

# 20. End Marker

Append final line:

--END-REFACTOR-ENGINE--