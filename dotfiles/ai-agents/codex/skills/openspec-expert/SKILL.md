---
name: openspec-expert
description: Expert spec-driven development with the OpenSpec CLI, including ADO work item ingestion, deterministic spec generation, CI and policy validation, spec diffing and versioning review, formal sign-off, and quality scoring. Use when handling OpenSpec specs, requirements-to-spec workflows, spec validation gates, review workflows, or quality scoring.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "1.0.0"
  domain: specification
  triggers: openspec, OpenSpec CLI, spec-driven development, requirements, ADO work item, spec validation, CI gate, spec diff, spec review, quality scoring
  role: expert
  scope: planning
  output-format: document
  related-skills: deep-research, api-designer, devops-engineer, sre-engineer
---

# OpenSpec Expert

## Role Definition

Generate, validate, and govern OpenSpec specifications using a deterministic, CI-safe workflow with review and quality gates.

## When to Use This Skill

- Converting requirements into OpenSpec specifications
- Generating specs from ADO work items or structured inputs
- Validating specs under CI and policy constraints
- Reviewing spec diffs and version changes
- Enforcing sign-off and quality scoring thresholds

## Core Workflow

1. Select input type (task text, ADO work item, or requirements JSON).
2. Generate the spec with the appropriate script under `scripts/`.
3. Validate with `scripts/validate_spec.sh` and record results.
4. Produce and review spec diff and version notes.
5. Run review and sign-off (Tech lead + QA).
6. Apply quality scoring; require a score of at least 80/100 or remediate.
7. Report the output contract.

### Fast Path (Small Tasks)

1. Identify the smallest viable change.
2. Generate and validate the spec.
3. Summarize diff, review status, and quality score.

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
| Diffing | `references/diffing.md` | Diffing and version review |
| Review | `references/review.md` | Sign-off workflow |
| Quality | `references/quality-scoring.md` | Scoring rubric and thresholds |

## Constraints

### MUST DO
- Use the provided scripts under `scripts/`.
- Validate with `scripts/validate_spec.sh`.
- Apply CI/policy gates as part of validation.
- Require Tech lead + QA sign-off before marking complete.
- Enforce quality score >= 80/100 or remediate.

### MUST NOT DO
- Hand-write full specs when CLI + scripts can generate them.
- Skip validation or review gates for convenience.

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
4. Diff summary and version notes
5. Review status (Tech lead + QA)
6. Quality score (>= 80/100) and remediation notes if below

## Knowledge Reference

Spec-driven development, deterministic CLI workflows, validation pipelines, review governance, and quality scoring.
