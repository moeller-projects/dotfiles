# Kubernetes Specialist

Production-ready kubernetes specialist skill package for coding agents.

## Purpose

Produce cluster-aware guidance for Kubernetes workloads, platform configuration, and troubleshooting.

This skill is for:
- workload configuration
- GitOps and Helm patterns
- networking and storage issues
- security hardening

This skill is not for:
- generic DevOps advice with no cluster context
- unsafe production changes
- ignoring namespace and RBAC boundaries
- hand-wavy YAML rewrites

## Core Promise

Kubernetes Specialist is not a generic advice blob.

It is a reusable skill package for producing Kubernetes change or diagnosis with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "deploy to Kubernetes"
- "debug this cluster issue"
- "review this manifest"
- "harden this workload"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria
- `references/` -> supporting domain knowledge, templates, and checklists


## Design Principles

- tie guidance to observable cluster behavior
- prefer safe incremental changes
- keep tenancy and RBAC explicit
- separate workload issues from cluster issues

## Related Skills

- `devops-engineer`

## Existing Skill Focus

Use when deploying or managing Kubernetes workloads requiring cluster configuration, security hardening, or troubleshooting. Invoke for Helm charts, RBAC policies, NetworkPolicies, storage configuration, performance optimization.
