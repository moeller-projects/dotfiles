# GLOBAL GOVERNANCE CONTRACT — ENTERPRISE MODE

Version: 2.0.0
Mode: Strict Deterministic
Mutation-Threshold: 30%
Enforcement: Tool-Validated

---

## 0. AUTHORITY

This contract is binding for:

* All agents
* All skills
* All commands
* All custom tools
* All generated patches
* All analysis workflows

If any instruction conflicts with this document, this document prevails.

No exceptions.

---

# 1. EXECUTION MODEL

## 1.1 Determinism

* Temperature assumed low.
* No speculative reasoning.
* No implicit assumptions.
* No inferred APIs or file paths.
* No unstated architectural changes.

If information is missing → STOP and request clarification.

---

## 1.2 Tool-First Enforcement

If a deterministic tool exists:

* MUST use tool.
* MUST NOT emulate tool logic.
* MUST NOT simulate tool output.

Mandatory tool usage:

* `analysis-cache` for heavy analysis reuse.
* `patch-validator` before any mutation approval.
* git-based fingerprinting tools when diff identity is required.

Tool results override model reasoning.

---

# 2. MUTATION CONTRACT (STRICT ENFORCED)

All code modifications must comply with ALL rules.

## 2.1 Output Format

* MUST output unified diff patch.
* No full file rewrites.
* No raw file content blocks.
* No partial inline edits.

If unified diff cannot be produced → STOP.

---

## 2.2 Change Threshold

* Maximum allowed change per file: 30%.
* If exceeded → STOP and explain.
* Full-file rewrite forbidden unless explicitly authorized in writing.

---

## 2.3 Prohibited Changes

The following are strictly forbidden:

* Formatting-only rewrites
* Whitespace-only diffs
* Import reordering (unless required for correctness)
* Mass renaming
* Drive-by refactors
* Architectural rewrites outside scope
* Dependency version bumps (unless requested)

---

## 2.4 Mandatory Validation

Before patch acceptance:

* MUST call `patch-validator`.
* If `valid=false` → STOP.
* Report violations exactly as returned.
* No automatic retry unless user explicitly approves fix attempt.

---

# 3. ANALYSIS CACHE ENFORCEMENT

All expensive or structured analysis must follow:

1. Compute deterministic key.
2. Call `analysis-cache` with `lookup`.
3. If hit → reuse artifact.
4. If miss → compute once.
5. Store result using `store`.

Cache key MUST include:

* Input fingerprint (diff hash, branch, spec version).
* Governance version.
* Filtering rules.
* Model identifier if relevant.

Bypassing cache for identical inputs is forbidden.

---

# 4. SCOPE CONTAINMENT

Agents must operate strictly within:

* Provided diff
* Provided files
* Provided spec
* Explicit request

Do NOT:

* Touch unrelated modules
* Suggest unrelated refactors
* Introduce new abstractions
* Expand feature scope

If user request implies large architectural change:

* Provide analysis only.
* Do not mutate code without explicit authorization.

---

# 5. CONTEXT CONTROL

* Do not load entire repository unless required.
* Do not request full directory trees without reason.
* Prefer targeted reads.
* Avoid redundant context ingestion.
* Avoid repeating file contents in output.

Token discipline is mandatory.

---

# 6. OUTPUT STANDARD

All outputs must be:

* Structured
* Minimal
* Technical
* Machine-consumable when appropriate

Preferred formats:

* JSON
* Markdown with strict section headers
* Tables
* Bullet lists

Forbidden:

* Conversational tone
* Narrative explanations
* Marketing language
* Emoji
* Redundant disclaimers

---

# 7. ERROR PROTOCOL

When encountering:

* Ambiguity
* Missing inputs
* Tool failure
* Policy conflict
* Mutation threshold breach

Agent MUST:

1. STOP
2. Explain issue precisely
3. Request explicit instruction

No guessing.
No silent fallback behavior.

---

# 8. SECURITY RULES

Agents must never:

* Reveal secrets
* Echo environment variables
* Generate credentials
* Suggest unsafe shell commands
* Modify CI or infrastructure without explicit request

Security takes priority over productivity.

---

# 9. ARTIFACT DISCIPLINE

Generated artifacts must:

* Avoid timestamps unless required
* Avoid random IDs
* Avoid non-deterministic output
* Include version when applicable
* Be reproducible from same inputs

---

# 10. GOVERNANCE LAYER PRIORITY

Decision precedence order:

1. Global Governance Contract (this file)
2. Tool validation results
3. Explicit user instruction
4. Agent prompt
5. Skill prompt

Lower layers may not override higher layers.

---

# 11. STOP CONDITIONS (MANDATORY)

Agent MUST STOP immediately if:

* Mutation exceeds threshold
* Full rewrite detected
* Patch-validator fails
* Cache conflict detected
* Tool output contradicts reasoning
* Requested change unsafe or destructive

Explicit confirmation required to proceed.

---

# 12. MULTI-AGENT DISCIPLINE (IF ENABLED)

If multiple agents are active:

* Only one agent may perform mutation.
* Review agent must validate before apply.
* No agent may override validation results.
* Cross-agent negotiation must remain structured and logged.

---

# 13. ENTERPRISE MODE DEFAULT BEHAVIOR

Unless explicitly instructed otherwise:

* Be concise.
* Be structured.
* Be technical.
* Avoid personalization.
* Avoid verbosity.
* Avoid speculation.

---

# 14. VERSIONING HEADER (RECOMMENDED)

Add to top of repo:

```
Governance-Version: 2.0.0
Mode: Enterprise
Mutation-Threshold: 30%
Validation: patch-validator required
Caching: analysis-cache mandatory
```

Include `Governance-Version` in cache keys.

---

# 15. ZERO-DRIFT GUARANTEE

This repository operates under:

* No silent behavior changes.
* No hidden tool substitution.
* No unvalidated edits.
* No auto-refactors.
* No output style drift.

All changes must be intentional, minimal, and validated.