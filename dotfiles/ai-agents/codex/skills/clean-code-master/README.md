# Clean Code Master

Governance-grade clean code and maintainability skill for coding agents.

## Purpose

Enforce structural quality, measurable complexity reduction, and behavior-safe refactoring.

This skill is for:
- maintainability audits
- complexity reviews
- technical debt classification
- minimal safe refactor planning
- CI quality enforcement

This skill is not for:
- one-off formatting fixes
- style-only nitpicks
- speculative architecture rewrites
- framework-specific advice without evidence

## Core Promise

Clean Code Master is not a style prompt.

It is a deterministic engineering governance protocol.

It should:
- measure before recommending
- preserve behavior
- avoid aesthetic churn
- prefer minimal, high-impact change
- refuse to invent missing architecture

## Modes

- **Audit** → analyze maintainability and complexity
- **Plan** → produce incremental refactor roadmap
- **Patch** → propose minimal safe diff
- **CI** → return pass/warn/fail with machine-readable summary

## Key Concepts

- **Maintainability Score** → 0–100 deterministic score
- **Complexity Budget** → per-module thresholds
- **Debt Taxonomy** → structural, behavioral, architectural, testability, observability
- **Risk Radius** → low / medium / high / critical blast radius
- **Evidence Tags** → `[OBSERVED]`, `[INFERRED]`, `[ASSUMPTION]`

## When to Use

Use for:
- “review this code for clean code issues”
- “find maintainability problems”
- “plan a safe refactor”
- “check SOLID violations”
- “measure complexity”
- “reduce technical debt safely”
- “enforce maintainability in CI”

## When NOT to Use

Do not use for:
- pure formatting
- commit messages
- PR titles
- polished end-user writing
- broad rewrites without scope
- stack-specific advice without code evidence

## File Structure

- `SKILL.md` → runtime rules and output contract
- `examples.md` → example outputs by mode and scenario
- `evals.md` → validation prompts and pass criteria
- `anti-patterns.md` → skill behavior failures to avoid
- `references/` → metric definitions, heuristics, templates, and policy references

## Trigger Examples

Natural language:
- “use clean-code-master”
- “do a maintainability audit”
- “analyze technical debt”
- “review complexity”
- “plan a safe refactor”
- “CI enforce clean code”

## Design Philosophy

Measure first.  
Refactor second.  
Minimize blast radius.  
Never trade safety for elegance.

## Future Improvements

- repo-specific budget profiles
- machine-readable finding schema
- patch-size budget enforcement
- change-risk scoring by diff size + boundary count
- auto handoff format for refactor-engine / test-forge