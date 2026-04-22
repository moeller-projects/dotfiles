# Monorepo Navigator v2

Production-ready monorepo navigator skill package for coding agents.

## Purpose

Produce architectural analysis of module graphs, ownership boundaries, and drift across a monorepo.

This skill is for:
- module inventory
- dependency cycle analysis
- bounded context inference
- blast-radius reporting

This skill is not for:
- single-package review only
- inventing module boundaries
- full-repo scanning without limits
- ignoring manifest truth

## Core Promise

Monorepo Navigator v2 is not a generic advice blob.

It is a reusable skill package for producing monorepo structural report with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "analyze this monorepo"
- "find dependency cycles"
- "map module ownership"
- "report architectural drift"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- prefer manifests over guesses
- respect scan limits
- separate observed from inferred structure
- keep outputs CI-friendly

## Related Skills

- `refactor-engine`
- `clean-code-master`

## Existing Skill Focus

Use when analyzing architecture, ownership boundaries, or dependency cycles across a monorepo. Invoke for module graph generation, blast-radius estimation, bounded context detection, or architectural drift reports. Not for single-package analysis.
