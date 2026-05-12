# MVP Watcher v1.2

Production-ready mvp watcher skill package for coding agents.

## Purpose

Produce MVP discipline that removes scope creep, premature abstraction, and non-essential work.

This skill is for:
- reviewing feature scope
- cutting premature abstractions
- challenging non-essential work
- keeping delivery focused

This skill is not for:
- maximalist roadmaps
- gold-plating
- adding infrastructure with no current need
- confusing polish with value

## Core Promise

MVP Watcher v1.2 is not a generic advice blob.

It is a reusable skill package for producing scope review with keep/cut recommendations with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "is this still MVP"
- "cut scope creep"
- "review this plan for overengineering"
- "trim this feature"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- ship the smallest valuable slice
- cut complexity before cutting essentials
- make tradeoffs explicit
- treat future-proofing as optional unless proven necessary

## Related Skills

- `clean-code-master`
- `openspec-expert`
- `perf-analyst`

## Existing Skill Focus

Use when reviewing a plan, PR, or feature for scope creep, premature abstraction, or non-MVP complexity. Invoke before or during implementation to enforce value-to-complexity discipline and contain cost. Not for post-release retrospectives.
