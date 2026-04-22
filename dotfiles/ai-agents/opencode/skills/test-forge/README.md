# Test Forge v2

Production-ready test forge skill package for coding agents.

## Purpose

Produce durable automated tests for changed behavior, complex flows, and compatibility boundaries.

This skill is for:
- unit and integration tests
- diff-driven updates
- contract guards
- failure injection and edge-case coverage

This skill is not for:
- browser E2E when Playwright is the right tool
- hallucinating APIs or frameworks
- implementation-detail assertions
- rewriting whole suites unnecessarily

## Core Promise

Test Forge v2 is not a generic advice blob.

It is a reusable skill package for producing test plan or test patch with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "write tests"
- "update tests for this diff"
- "improve coverage"
- "design test architecture"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- test behavior, not internals
- prefer deterministic tests
- update only what changed
- strengthen assertions against subtle regressions

## Related Skills

- `playwright-expert`
- `openspec-expert`

## Existing Skill Focus

Use when generating or updating tests for changed behavior, designing test architecture, or building coverage for complex flows. Invoke for unit, integration, contract, or property-based tests, diff-driven updates, or mutation-sensitive assertions. Not for E2E browser tests (use playwright-expert).
