# Refactor Engine v2

Production-ready refactor engine skill package for coding agents.

## Purpose

Produce behavior-preserving refactor guidance with blast-radius control and reversible sequencing.

This skill is for:
- large refactor planning
- API surface protection
- migration sequencing
- architectural boundary enforcement

This skill is not for:
- cosmetic cleanup
- unscoped rewrites
- changing behavior by accident
- patches without rollback thinking

## Core Promise

Refactor Engine v2 is not a generic advice blob.

It is a reusable skill package for producing refactor plan or patch with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "plan a refactor"
- "safe architectural evolution"
- "estimate blast radius"
- "preserve API contracts"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- preserve invariants first
- keep refactors reversible
- make blast radius visible
- stage risky changes incrementally

## Related Skills

- `monorepo-navigator`
- `test-forge`
- `threat-modeler`
- `perf-analyst`

## Existing Skill Focus

Use when planning or executing large-scale refactoring with behavioral-invariant preservation. Invoke for API surface protection, blast-radius estimation, migration sequencing, or architectural boundary enforcement in monorepos. Not for small cosmetic cleanups.
