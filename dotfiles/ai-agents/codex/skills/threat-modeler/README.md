# Threat Modeler v2

Production-ready threat modeler skill package for coding agents.

## Purpose

Produce structured security posture analysis with trust boundaries, threat inventory, and prioritized mitigations.

This skill is for:
- threat modeling
- attack surface review
- trust boundary mapping
- security mitigation prioritization

This skill is not for:
- general code review
- exploit instructions
- invented controls
- compliance claims without evidence

## Core Promise

Threat Modeler v2 is not a generic advice blob.

It is a reusable skill package for producing threat model and mitigations with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "threat model this system"
- "map trust boundaries"
- "review attack surface"
- "prioritize security risks"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- start from assets and boundaries
- score risk explicitly
- prefer high-impact mitigations
- never invent unseen controls

## Related Skills

- `refactor-engine`
- `openspec-expert`

## Existing Skill Focus

Use when assessing security posture, mapping trust boundaries, or producing risk-scored mitigations for a system. Invoke for threat modeling sessions, compliance mapping, lateral movement analysis, or attack surface inventory. Not for general code review.
