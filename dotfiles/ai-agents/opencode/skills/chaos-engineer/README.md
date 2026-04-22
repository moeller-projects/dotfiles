# Chaos Engineer

Production-ready chaos engineer skill package for coding agents.

## Purpose

Produce safe chaos experiments, failure injection plans, and game day guidance for distributed systems.

This skill is for:
- designing experiments
- choosing failure modes
- defining steady-state checks
- planning rollback and safety controls

This skill is not for:
- reckless production disruption
- security exploitation advice
- failure injection without guardrails
- experiments with no observable hypothesis

## Core Promise

Chaos Engineer is not a generic advice blob.

It is a reusable skill package for producing chaos experiment plan with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "design a chaos experiment"
- "plan a game day"
- "inject failures safely"
- "test resilience under outage"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- start from a falsifiable hypothesis
- define abort conditions before execution
- prefer minimal blast radius first
- tie every experiment to an observable steady state

## Related Skills

- `devops-engineer`
- `kubernetes-specialist`

## Existing Skill Focus

Use when designing chaos experiments, implementing failure injection frameworks, or conducting game day exercises. Invoke for chaos experiments, resilience testing, blast radius control, game days, antifragile systems.
