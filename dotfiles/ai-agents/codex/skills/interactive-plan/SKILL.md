---
name: interactive-plan
description: Interactive production planning with decision questions, task list, clean code, and test strategy.
---

# Interactive Planning Skill

## Goal
Create a production implementation plan using **interactive decision steps**.

This skill:
- Detects missing decisions
- Asks structured questions
- Accepts multiple choice or free-text answers
- Builds a final implementation plan
- Generates a task checklist
- Enforces quality and testing expectations

---

# Execution Mode

Default:
- Deterministic
- Risk-aware
- Minimal hallucination
- Repo-aware if context exists
- Tool-aware if scripts/tests/CI exist

---

# Workflow

---

## Phase 1 — Context Scan

If repository context exists, quickly inspect:

- README / docs
- Architecture files
- Test setup
- CI / CD commands

Detect if possible:

- Language / framework
- Test framework
- Deployment model
- Risk areas

If tests exist:
- Prefer extending existing tests over inventing new structure.

---

## Phase 2 — Decision Question Mode

If planning uncertainty exists, ask up to **3 questions**.

### Question Format (MANDATORY)

```

## Decision Needed

### Q<n> — <Decision Topic>

Why this matters: <Short explanation>

Choose one:
A) Option A
B) Option B
C) Option C
D) Other: _______

```

---

## Answer Handling

User may respond with:

- Single letter (A / B / C)
- Free text
- Mixed answers

If user does not answer:
- Choose safest production default
- Record as assumption

---

## Phase 3 — Plan Generation

After decisions are resolved (or safely assumed), generate final plan.

---

# Quality Requirements

---

## Clean Code Principles

Plan must encourage:

- Small functions
- Clear naming
- Single responsibility
- Testability by design
- No hidden side effects
- Explicit error handling

---

## Testing Requirements

Must consider:

### Unit Tests
Business logic validation

### Integration Tests
System boundary behavior

### Failure Tests
Timeouts  
Retries  
Invalid input  
Dependency failures  

### Regression Tests
If modifying existing behavior

---

## Observability (if backend or infrastructure)

Consider:

- Structured logging
- Metrics
- Alert triggers
- Health checks

---

# Output Template

```

# Implementation Plan

## Approach

<1–3 sentences describing approach>

---

## Scope

### In Scope

*

### Out of Scope

*

---

## Decisions

| Decision   | Choice            | Reason |
| ---------- | ----------------- | ------ |
| <Decision> | <Selected Option> | <Why>  |

---

## Action Items

[ ] Discovery / validation
[ ] Implementation step
[ ] Tests added
[ ] Risk validation
[ ] Rollout strategy

---

## Task Checklist (Detailed)

| Task                     | Risk                | Confidence          |
| ------------------------ | ------------------- | ------------------- |
| <Verb-based atomic task> | Low / Medium / High | Low / Medium / High |

---

## Test Strategy

Unit:
Integration:
Edge cases:
Failure scenarios:

---

## Risks

Risk:
Mitigation:

---

## Assumptions

*

---

## Open Questions (if any)

*

```

---

# Planning Rules

Prefer:

- Vertical slices
- Safe incremental rollout
- Feature flags for risky changes
- Backward compatibility
- Observable deployments

Avoid:

- Big bang rewrites
- Hidden coupling
- Untestable designs
- Large speculative refactors

---

# Failure Rules

If context missing → Ask  
If decision unclear → Choose safest default and record assumption  
If risk high → Highlight explicitly  
If estimate uncertain → Mark clearly  

---

# Non Goals

Do NOT:

- Write full production code
- Generate full specifications unless explicitly requested
- Redesign full architecture unless explicitly requested
