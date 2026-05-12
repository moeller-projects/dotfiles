# Prompt Engineer

Production-ready prompt design and evaluation skill for coding agents.

## Purpose

Design, refine, evaluate, and migrate prompts with explicit success criteria, controlled scope, and reusable output structure.

This skill is for:
- designing new prompts for concrete tasks
- improving failing or inconsistent prompts
- choosing prompting patterns deliberately
- defining prompt evaluation plans and metrics
- migrating prompts between models or providers
- designing structured-output prompts and schemas

This skill is not for:
- generic brainstorming without a concrete task
- product policy decisions without provided policy
- shipping prompts without validation guidance
- code, architecture, or workflow reviews outside prompt behavior
- provider-specific claims without stated model constraints

## Core Promise

Prompt Engineer is not a prompt-writing blob.

It is an operational protocol for producing prompt artifacts that are:
- scoped
- testable
- versionable
- comparable to a baseline
- explicit about assumptions and limits

## Operating Modes

- **Design** -> create a new prompt package for a defined task
- **Optimize** -> improve an existing prompt based on failure evidence
- **Evaluate** -> define or assess test cases, metrics, and pass criteria
- **Migrate** -> adapt a prompt across models, providers, or output methods

Default mode: **Design**

## Activation Triggers

Natural language examples:
- "use prompt-engineer"
- "design a prompt for this task"
- "improve this system prompt"
- "optimize this prompt"
- "build prompt evals"
- "migrate this prompt to another model"
- "make this structured output prompt reliable"

## Deactivation Triggers

- "stop prompt-engineer"
- "normal mode"
- requests that are clearly about non-prompt implementation work

## File Structure

- `SKILL.md` -> runtime rules, modes, output contracts, decision rules
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples by mode
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting prompt-engineering knowledge and templates

## Design Principles

- baseline before optimization when evidence exists
- one meaningful change at a time when debugging prompt failures
- prefer the simplest prompt pattern that meets the task
- separate runtime protocol from reference material
- treat missing constraints as explicit assumptions, not hidden guesses
- prefer `NO CHANGE` over churn when current prompt already meets criteria

## Related Skills

- `test-forge` for implementation-oriented test creation
- `doc-forge` for packaging prompt documentation or guides
- `readme-expert` when the deliverable is end-user documentation, not prompt logic

## Future Improvements

- machine-readable prompt artifact schema
- reusable provider capability matrix
- benchmark templates for common prompt task families
