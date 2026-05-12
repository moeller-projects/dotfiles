# Budget Guard v2.1

Production-ready budget guard skill package for coding agents.

## Purpose

Produce hard budget enforcement for a single task so the agent stays within token, tool, and time limits.

This skill is for:
- setting strict search limits
- capping tool calls for a task
- choosing a minimal viable path
- blocking low-value exploration

This skill is not for:
- broad research without a budget
- session-wide orchestration across many agents
- unbounded brainstorming
- pretending a budget was respected when it was not

## Core Promise

Budget Guard v2.1 is not a generic advice blob.

It is a reusable skill package for producing budget-safe execution plan with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "stay under this budget"
- "strict token budget"
- "minimize tool calls"
- "budget-safe task execution"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- protect the hard cap first
- cut optional work before core work
- surface tradeoffs early
- return blocker or downgrade paths when the budget is impossible

## Related Skills

- `budget-supervisor`

## Existing Skill Focus

Use when a Codex task must run within strict cost or token limits. Invoke to enforce hard budgets, prevent search storms, or gate CI-safe termination. Do not use for session-level multi-task budget governance (use budget-supervisor instead).
