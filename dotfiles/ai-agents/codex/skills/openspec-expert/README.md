# OpenSpec Expert v2.1

Production-ready openspec expert skill package for coding agents.

## Purpose

Produce creation, validation, and governance of functional requirement specs in OpenSpec format.

This skill is for:
- writing specs
- reviewing spec quality
- diffing spec changes
- enforcing OpenSpec structure

This skill is not for:
- free-form product writing
- inventing requirements without source inputs
- implementation without specification scope
- ignoring schema or quality rules

## Core Promise

OpenSpec Expert v2.1 is not a generic advice blob.

It is a reusable skill package for producing OpenSpec document or review with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "write an OpenSpec"
- "review this spec"
- "validate spec quality"
- "diff these spec changes"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- treat requirements as testable contracts
- keep behavior and rationale distinct
- preserve change history explicitly
- flag unsupported requirements

## Related Skills

- `deep-research`
- `refactor-engine`
- `threat-modeler`
- `test-forge`
- `perf-analyst`

## Existing Skill Focus

Use when creating, validating, or governing functional requirement specifications in OpenSpec format. Invoke for spec generation from inputs, risk-tier classification, quality scoring, version enforcement, diff analysis, or CI gate execution. Not for inline code documentation (use doc-forge instead).
