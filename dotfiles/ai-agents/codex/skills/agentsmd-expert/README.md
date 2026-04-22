# AGENTS.md Expert

Production-ready agentsmd expert skill package for coding agents.

## Purpose

Produce repository-specific AGENTS.md instructions that help coding agents operate safely and consistently.

This skill is for:
- creating a new AGENTS.md
- standardizing repository instructions
- documenting exact build, test, and dev commands
- capturing agent constraints and local skills

This skill is not for:
- general README authoring
- architecture documentation
- inventing repo commands
- copying boilerplate that ignores the repo

## Core Promise

AGENTS.md Expert is not a generic advice blob.

It is a reusable skill package for producing AGENTS.md guidance with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "create AGENTS.md"
- "update AGENTS.md"
- "standardize agent instructions"
- "document repo workflows for agents"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- keep instructions actionable and repo-specific
- prefer exact commands over vague prose
- separate hard constraints from helpful guidance
- flag missing repository facts instead of inventing them

## Related Skills

- `doc-forge`
- `prompt-engineer`
- `readme-expert`

## Existing Skill Focus

Use when creating or updating AGENTS.md files for Codex agents. Invoke for standardizing repository guidelines, clarifying tooling commands, or documenting local skills and constraints. Not for general README or project documentation (use readme-expert instead).
