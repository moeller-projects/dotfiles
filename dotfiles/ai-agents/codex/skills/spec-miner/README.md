# Spec Miner

Production-ready spec miner skill package for coding agents.

## Purpose

Produce requirements and behavior extraction from legacy or undocumented systems.

This skill is for:
- legacy system understanding
- spec extraction from code
- behavior mapping
- documenting undocumented flows

This skill is not for:
- inventing requirements
- editing code instead of extracting behavior
- single-file trivia
- treating inference as fact

## Core Promise

Spec Miner is not a generic advice blob.

It is a reusable skill package for producing derived specification or system map with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "mine a spec from this code"
- "document the current behavior"
- "extract requirements from the repo"
- "understand this legacy system"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- extract before proposing change
- separate observed behavior from inferred intent
- keep ambiguity visible
- use examples to anchor the derived spec

## Related Skills

- `doc-forge`
- `the-fool`
- `legacy-modernizer`

## Existing Skill Focus

Use when understanding legacy or undocumented systems, creating documentation for existing code, or extracting specifications from implementations. Invoke for legacy analysis, code archaeology, undocumented features.
