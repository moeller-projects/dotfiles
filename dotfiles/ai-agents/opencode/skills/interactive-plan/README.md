# Interactive Plan

Production-ready interactive plan skill package for coding agents.

## Purpose

Produce structured planning with clarifying questions, scoped tasks, and explicit test strategy.

This skill is for:
- ambiguous feature planning
- decision capture
- task checklists
- test strategy design

This skill is not for:
- writing full production code
- pretending unclear requirements are settled
- architecture rewrites by default
- plans with no test strategy

## Core Promise

Interactive Plan is not a generic advice blob.

It is a reusable skill package for producing implementation plan with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "create a plan"
- "ask clarifying questions first"
- "build a task checklist"
- "plan before coding"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- ask only the questions that change the plan
- record safe assumptions explicitly
- prefer vertical slices
- pair every plan with validation

## Related Skills

- `test-forge`

## Existing Skill Focus

Use when a task requires upfront clarifying questions before work begins, or when an explicit task list with test strategy is needed. Invoke for ambiguous requirements, multi-step features, or planning sessions before coding starts.
