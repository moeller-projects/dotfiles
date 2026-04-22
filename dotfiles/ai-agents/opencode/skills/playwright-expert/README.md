# Playwright Expert

Production-ready playwright expert skill package for coding agents.

## Purpose

Produce Playwright-focused end-to-end test design, infrastructure setup, and flaky test debugging.

This skill is for:
- writing E2E tests
- debugging flakes
- selectors and locators
- test environment configuration

This skill is not for:
- non-browser testing
- driver-agnostic speculation
- brittle selectors by default
- ignoring deterministic waits

## Core Promise

Playwright Expert is not a generic advice blob.

It is a reusable skill package for producing Playwright test or debug plan with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "write a Playwright test"
- "debug flaky browser tests"
- "review Playwright setup"
- "improve locators"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- prefer user-visible locators
- keep tests deterministic
- stabilize environment before blaming assertions
- treat flake triage as evidence-driven

## Related Skills

- `test-forge`
- `devops-engineer`

## Existing Skill Focus

Use when writing E2E tests with Playwright, setting up test infrastructure, or debugging flaky browser tests. Invoke for browser automation, E2E tests, Page Object Model, test flakiness, visual testing.
