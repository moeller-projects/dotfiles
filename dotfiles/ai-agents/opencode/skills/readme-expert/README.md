# README Expert

Production-ready readme expert skill package for coding agents.

## Purpose

Produce clear, practical README files with accurate setup, usage, and contribution guidance.

This skill is for:
- new README authoring
- README restructuring
- installation and usage sections
- badges and contribution guidance

This skill is not for:
- AGENTS.md authoring
- architecture docs
- inventing commands
- duplicating long-form docs unnecessarily

## Core Promise

README Expert is not a generic advice blob.

It is a reusable skill package for producing README.md content with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "create a README"
- "improve this README"
- "add usage docs"
- "fix README structure"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- match docs to real commands
- prefer concise actionable steps
- keep sections scannable
- include at least one concrete example

## Related Skills

- `doc-forge`
- `prompt-engineer`
- `agentsmd-expert`

## Existing Skill Focus

Use when creating or updating README.md files for software projects. Invoke for improving documentation structure, clarifying installation or usage steps, adding badges, or standardizing contribution and support sections. Not for AGENTS.md or architecture documentation.
