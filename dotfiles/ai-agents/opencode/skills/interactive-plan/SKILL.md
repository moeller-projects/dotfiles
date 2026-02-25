---
name: interactive-plan
description: Interactive production planning with decision questions, task list, clean code, and test strategy.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "1.0.0"
  domain: planning
  triggers: implementation plan, planning, decision questions, task list, test strategy
  role: expert
  scope: planning
  output-format: document
  related-skills: test-master, architecture-designer
---

# Interactive Plan

## Role Definition

You create production-ready implementation plans using structured decision questions, explicit assumptions, and test-driven validation.

## When to Use This Skill

- Planning a feature with ambiguous requirements or tradeoffs
- Building a task checklist with risk and confidence
- Defining test strategy and quality expectations

## Core Workflow

1. Scan repository context (docs, tests, CI).
2. Identify missing decisions and ask structured questions.
3. Resolve decisions or record safe assumptions.
4. Produce a complete implementation plan and task checklist.
5. Define test strategy, risks, and mitigations.


### Fast Path (Small Tasks)

1. Identify the smallest viable change.
2. Implement with minimal risk and scope.
3. Validate and document impact.

## Reference Guide

Load detailed guidance based on context:

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Overview | `references/index.md` | Quick map of all references |
| Workflow | `references/workflow.md` | End-to-end planning flow |
| Checklist | `references/checklist.md` | Plan quality checks |
| Pitfalls | `references/pitfalls.md` | Avoiding weak plans |
| Examples | `references/examples.md` | Sample planning outputs |
| Templates | `references/templates.md` | Reusable plan templates |
| Evaluation | `references/evaluation.md` | Plan acceptance criteria |
| Tools | `references/tools.md` | Tool-aware planning |

## Constraints

### MUST DO
- Ask structured decision questions when uncertainty exists.
- Capture assumptions explicitly when unanswered.
- Provide a task checklist with risk and confidence.
- Include test strategy and failure scenarios.

### MUST NOT DO
- Skip repository context when available.
- Produce plans without explicit scope boundaries.

## Output Templates

Implementation plan template:

```markdown
# Implementation Plan

## Approach
<1–3 sentences describing approach>

## Scope
### In Scope
*

### Out of Scope
*

## Decisions
| Decision   | Choice            | Reason |
| ---------- | ----------------- | ------ |
| <Decision> | <Selected Option> | <Why>  |

## Action Items
[ ] Discovery / validation
[ ] Implementation step
[ ] Tests added
[ ] Risk validation
[ ] Rollout strategy

## Task Checklist (Detailed)
| Task                     | Risk                | Confidence          |
| ------------------------ | ------------------- | ------------------- |
| <Verb-based atomic task> | Low / Medium / High | Low / Medium / High |

## Test Strategy
Unit:
Integration:
Edge cases:
Failure scenarios:

## Risks
Risk:
Mitigation:

## Assumptions
*
```

## Knowledge Reference

Planning frameworks, decision analysis, risk assessment, test strategy design, and project scoping.

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
