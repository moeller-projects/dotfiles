# Legacy Modernizer

Production-ready legacy modernizer skill package for coding agents.

## Purpose

Produce incremental modernization plans and patches for legacy systems with compatibility and rollout awareness.

This skill is for:
- migration sequencing
- strangler strategies
- legacy risk assessment
- debt reduction with compatibility

This skill is not for:
- big bang rewrites
- discarding compatibility constraints
- speculative platform migrations
- ignoring rollback

## Core Promise

Legacy Modernizer is not a generic advice blob.

It is a reusable skill package for producing modernization roadmap with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "modernize this legacy system"
- "incremental migration plan"
- "reduce technical debt safely"
- "legacy assessment"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- prefer incremental migration over replacement
- respect legacy invariants
- define coexistence periods explicitly
- validate each modernization step

## Related Skills

- `test-forge`
- `devops-engineer`
- `spec-miner`

## Existing Skill Focus

Use when modernizing legacy systems, implementing incremental migration strategies, or reducing technical debt. Invoke for strangler fig pattern, monolith decomposition, framework upgrades.
