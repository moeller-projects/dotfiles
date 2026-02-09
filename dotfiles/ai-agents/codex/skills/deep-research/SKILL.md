---
name: deep-research
description: Multi-agent deep research orchestration workflow for parallel data collection, analysis, and report synthesis.
---

# Skill: deep-research (Lean)

## Purpose
Collect evidence + extract structured requirements as input for the openspec skill.

## Mandatory behavior
- Do NOT call openspec CLI.
- Do NOT generate final specs.
- Produce artifacts on disk under .research/<run-id>/.
- Output contract must be satisfied.

## Output contract (must produce)
- .research/<run-id>/sources.md           (links + why relevant)
- .research/<run-id>/notes.md             (findings + constraints)
- .research/<run-id>/requirements.json    (structured requirements)

## Primary entrypoint
- scripts/run_research.sh "<goal>"

## Handoff to OpenSpec
Use openspec skill:
- .codex/skills/openspec/scripts/spec_from_input.sh .research/<run-id>/requirements.json
