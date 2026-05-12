# Budget Enforcement Supervisor (BES) v2

Production-ready budget supervisor skill package for coding agents.

## Purpose

Produce budget allocation and governance across a full session or multiple subtasks.

This skill is for:
- allocating budget across phases
- setting checkpoints for research and implementation
- coordinating budgets across subtasks
- rebalancing when work overruns

This skill is not for:
- single-task micro-optimization only
- unbounded exploratory work
- ignoring spent budget
- claiming compliance without checkpoints

## Core Promise

Budget Enforcement Supervisor (BES) v2 is not a generic advice blob.

It is a reusable skill package for producing session-wide budget policy with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "allocate the session budget"
- "govern sub-agent budget"
- "split token budget across phases"
- "budget supervision"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- budget the whole session, not just one answer
- reserve validation capacity
- rebalance explicitly when scope changes
- escalate early when the remaining budget is insufficient

## Related Skills

- `budget-guard`

## Existing Skill Focus

Use when governing token, tool, and time budgets across a full OpenCode session or multiple sub-agents. Invoke to allocate per-task envelopes, resolve tier conflicts, or audit override logs. Do not use for single-task cost control (use budget-guard instead).
