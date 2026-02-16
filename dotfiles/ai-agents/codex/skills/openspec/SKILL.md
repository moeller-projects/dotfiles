---
name: openspec
description: Spec-driven development workflow using OpenSpec CLI for specification, planning, and task generation.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "1.0.0"
  domain: specification
  triggers: openspec, specification, spec-driven development, requirements, planning
  role: expert
  scope: planning
  output-format: document
  related-skills: deep-research
---

# OpenSpec

## Role Definition

You generate and validate OpenSpec specifications using the OpenSpec CLI in a deterministic, CI-safe workflow.

## When to Use This Skill

- Creating or updating specifications using OpenSpec
- Converting requirements into validated specs
- Generating task plans from structured inputs

## Core Workflow

1. Select input type (task text, ADO work item, or requirements JSON).
2. Run the appropriate OpenSpec script under `scripts/`.
3. Validate specs using `scripts/validate_spec.sh`.
4. Report output contract details.


### Fast Path (Small Tasks)

1. Identify the smallest viable change.
2. Implement with minimal risk and scope.
3. Validate and document impact.

## Reference Guide

Load detailed guidance based on context:

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Overview | `references/index.md` | Quick map of all references |
| Workflow | `references/workflow.md` | Running OpenSpec end-to-end |
| Checklist | `references/checklist.md` | Validation and CI checks |
| Pitfalls | `references/pitfalls.md` | Avoiding spec failures |
| Examples | `references/examples.md` | Example OpenSpec runs |
| Templates | `references/templates.md` | Input templates |
| Evaluation | `references/evaluation.md` | Acceptance criteria |
| Tools | `references/tools.md` | CLI usage and safety |

## Constraints

### MUST DO
- Use the provided scripts under `scripts/`.
- Validate with `scripts/validate_spec.sh`.
- Apply policies (validation runs them).

### MUST NOT DO
- Hand-write full specs when CLI + scripts can generate them.

## Output Templates

Allowed inputs:
- Plain task text (feature/bug description)
- Azure DevOps work item id (preferred for team workflows)
- Requirements JSON (from `deep-research`)

Primary entrypoints:
- `scripts/spec_from_input.sh "<task text or path>"`
- `scripts/spec_from_ado.sh <workitem-id>`

Output contract:
1. Spec name
2. Paths touched (spec file)
3. Validation status (pass/fail)
4. If fail: exact failing step + log hint

## Knowledge Reference

Spec-driven development, deterministic CLI workflows, validation pipelines, and policy enforcement.
