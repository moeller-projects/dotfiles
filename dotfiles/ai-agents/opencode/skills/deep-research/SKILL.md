---
name: deep-research
description: Multi-agent deep research orchestration workflow for parallel data collection, analysis, and report synthesis.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "1.0.0"
  domain: research
  triggers: deep research, evidence gathering, requirements extraction, multi-agent research, research synthesis
  role: expert
  scope: analysis
  output-format: document
  related-skills: openspec
---

# Deep Research

## Role Definition

You orchestrate parallel evidence collection, synthesize findings, and extract structured requirements. Your output is designed to feed downstream spec generation reliably.

## When to Use This Skill

- Need high-confidence requirements from mixed sources
- Multi-threaded research and synthesis is required
- Preparing structured inputs for the `openspec` skill

## Core Workflow

1. Define the research goal and success criteria.
2. Run the research entrypoint and gather sources.
3. Synthesize notes and constraints into structured requirements.
4. Validate output contract artifacts.
5. Hand off `requirements.json` to `openspec`.


### Fast Path (Small Tasks)

1. Identify the smallest viable change.
2. Implement with minimal risk and scope.
3. Validate and document impact.

## Reference Guide

Load detailed guidance based on context:

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Overview | `references/index.md` | Quick map of all references |
| Workflow | `references/workflow.md` | Running end-to-end research |
| Checklist | `references/checklist.md` | Quality and safety checks |
| Pitfalls | `references/pitfalls.md` | Avoiding common research failures |
| Examples | `references/examples.md` | Example research outputs |
| Templates | `references/templates.md` | Reusable research templates |
| Evaluation | `references/evaluation.md` | Validating output quality |
| Tools | `references/tools.md` | Safe tool usage patterns |

## Constraints

### MUST DO
- Produce artifacts under `.research/<run-id>/`.
- Generate all outputs in the output contract.
- Keep sources and rationale in `sources.md`.
- Capture findings and constraints in `notes.md`.
- Produce machine-readable requirements in `requirements.json`.

### MUST NOT DO
- Do NOT call the openspec CLI directly.
- Do NOT generate final specifications.

## Output Templates

Output contract (must produce):
1. `.research/<run-id>/sources.md` — links + relevance
2. `.research/<run-id>/notes.md` — findings + constraints
3. `.research/<run-id>/requirements.json` — structured requirements

Primary entrypoint:
`scripts/run_research.sh "<goal>"`

Handoff to OpenSpec:
`.opencode/skills/openspec/scripts/spec_from_input.sh .research/<run-id>/requirements.json`

## Knowledge Reference

Research methodologies, source validation, evidence synthesis, requirements extraction, and structured documentation.
