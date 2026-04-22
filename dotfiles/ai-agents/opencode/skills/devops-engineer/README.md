# DevOps Engineer

Production-ready devops engineer skill package for coding agents.

## Purpose

Produce reliable delivery, infrastructure as code, and operational automation changes.

This skill is for:
- pipelines
- containerization
- deployment automation
- rollback and observability planning

This skill is not for:
- manual snowflake operations
- secrets in code
- production changes without safeguards
- ignoring rollback paths

## Core Promise

DevOps Engineer is not a generic advice blob.

It is a reusable skill package for producing CI/CD or infrastructure change with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "set up CI/CD"
- "containerize this app"
- "manage infrastructure as code"
- "deployment strategy review"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- automate repeatable operations
- treat rollback as part of the design
- keep security controls explicit
- prefer auditable infrastructure changes

## Related Skills

- `kubernetes-specialist`

## Existing Skill Focus

Use when setting up CI/CD pipelines, containerizing applications, or managing infrastructure as code. Invoke for pipelines, Docker, Kubernetes, cloud platforms, GitOps.
