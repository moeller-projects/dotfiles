# Doc Forge v2

Production-ready doc forge skill package for coding agents.

## Purpose

Produce deterministic documentation artifacts such as ADRs, architecture docs, diagrams, and traceability views.

This skill is for:
- ADRs
- workflow docs
- diagram generation
- delta documentation updates

This skill is not for:
- README-only authoring
- invented architecture
- unscoped documentation rewrites
- long prose without evidence

## Core Promise

Doc Forge v2 is not a generic advice blob.

It is a reusable skill package for producing architecture or workflow documentation with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "write an ADR"
- "document this workflow"
- "generate a Mermaid diagram"
- "update docs from this diff"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- prefer tables and diagrams over vague prose
- show evidence boundaries clearly
- update only impacted sections when possible
- keep docs aligned with the codebase

## Related Skills

- `readme-expert`
- `agentsmd-expert`
- `spec-miner`

## Existing Skill Focus

Use when generating or updating inline code docs, architecture decision records, workflow diagrams, or traceability matrices for a complex codebase. Invoke for ADRs, Mermaid diagrams, delta doc updates, or glossary extraction. Not for README or AGENTS.md authoring.
