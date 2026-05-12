# Perf Analyst v2

Production-ready perf analyst skill package for coding agents.

## Purpose

Produce measurement-first performance analysis with bottleneck diagnosis, optimization options, and validation.

This skill is for:
- hotspot diagnosis
- capacity modeling
- optimization patches
- performance regression guards

This skill is not for:
- guessing bottlenecks
- micro-optimizing without data
- benchmark theater
- trading correctness for speed

## Core Promise

Perf Analyst v2 is not a generic advice blob.

It is a reusable skill package for producing performance diagnosis and optimization plan with explicit scope, visible assumptions, and concrete validation guidance.

## Activation Triggers

Natural language examples:
- "analyze performance"
- "find the bottleneck"
- "optimize this hot path"
- "capacity planning review"

## Package Structure

- `SKILL.md` -> runtime rules and domain protocol
- `anti-patterns.md` -> failures in how the skill itself behaves
- `examples.md` -> scenario-based examples of good execution
- `evals.md` -> regression prompts with pass/fail criteria


## Design Principles

- measure before changing
- separate symptom from root cause
- prefer high-leverage fixes
- pair each optimization with verification

## Related Skills

- `refactor-engine`
- `clean-code-master`

## Existing Skill Focus

Use when diagnosing performance bottlenecks, modeling capacity, or producing optimization patches with measurement plans. Invoke for tail-latency issues, backpressure analysis, scaling risk, or workload modeling. Not for general code quality review.
