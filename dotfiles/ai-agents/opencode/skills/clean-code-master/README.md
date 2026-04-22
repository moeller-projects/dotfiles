# 

Production-ready clean code master skill package for coding agents.

## Purpose

Produce measurable maintainability analysis and behavior-safe refactoring guidance.

This skill is for:
- complexity reviews
- technical debt classification
- safe refactor planning
- CI-oriented maintainability gates

This skill is not for:
- formatting-only edits
- taste-based churn
- invented architecture rules
- broad rewrites without evidence

## Core Promise

 is not a generic advice blob.

It is a reusable skill package for producing maintainability review or refactor patch with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "clean code review"
- "maintainability audit"
- "technical debt review"
- "safe refactor plan"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- measure before recommending
- prefer minimal high-value change
- preserve behavior
- tag what is observed versus inferred

## Related Skills

- `refactor-engine`
- `the-fool`
- `test-forge`
- `doc-forge`
- `openspec-expert`
- `threat-modeler`

## Existing Skill Focus

Use when auditing code quality, measuring complexity, or planning technical debt reduction. Invoke for SOLID violations, naming convention enforcement, code smell detection, or maintainability budget reviews. Not for one-off formatting fixes.
