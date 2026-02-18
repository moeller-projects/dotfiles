—
name: budget-guard
description: Deterministic cost-control guardrail for Codex CLI and agentic workflows. Enforces strict token/tool/attempt budgets, cost-optimized routing, state memory discipline, hash-based rescan prevention, search storm protection, CI-safe termination, and explicit build/test confirmation.
—

# Budget Guard v2.1

## Intent
Minimize cost and token usage while preserving deterministic success.

Acts as:
1) Execution Mode (hard budgets, fail-fast, scope freeze)
2) Routing Modifier (prefer cheaper tiers; objective escalation only)

Designed for:
- Codex CLI
- Multi-agent orchestration
- CI runs
- Spec-driven development
- Autonomous loops

—

# 1. Operating Contract (Hard Rules)
- No full-file dumps unless explicitly justified.
- No repo hallucinations (never assume structure, runtime, tests, framework).
- Scope freeze: no unrelated refactors or enhancements.
- Fail fast if required inputs missing.
- Deterministic termination when budgets hit.
- No speculative improvements.

—

# 2. Budgets

Default Tier: Medium (if user does not specify)

## Tier Table
| Tier  | Input | Output | Tools | Attempts |
|———|———|———|———|-———|
| Small  | ≤1000 | ≤400   | ≤2     | ≤1 |
| Medium | ≤2000 | ≤800   | ≤4     | ≤2 |
| Large  | ≤3000 | ≤1000  | ≤6     | ≤3 |

Global hard caps (never exceed):
- Output ≤1200 tokens
- Tools ≤8
- Attempts ≤3

## Escalation Approval Boundaries (Deterministic)
- Escalation **within the selected tier** is allowed (e.g., LOW → MEDIUM while staying in Medium tier).
- Escalation **beyond the selected tier** requires explicit user approval.
- If tier is unspecified, assume Medium and treat MEDIUM → HIGH as “beyond tier” (approval required).

—

# 3. Routing Modifier

## Default Routing Ladder
1) LOW tier → triage, discovery, small edits  
2) MEDIUM tier → multi-file changes, test generation, non-trivial debugging  
3) HIGH tier → deep architecture/critique only if essential

## Objective Escalation Signals
Escalate LOW → MEDIUM if any:
- >2 files change
- Cross-module reasoning
- Test generation required
- Spec synthesis required
- First patch attempt fails with valid new signal

Escalate MEDIUM → HIGH if any (and approval boundary permits):
- Competing architectures must be evaluated
- Security/threat modeling
- Ambiguous spec reconciliation after 2 attempts

## Downgrade Rule
After patch generation on MEDIUM/HIGH:
- Use LOW for formatting, compression, final shaping.

## Multi-Agent Authority Boundary (No Silent Upgrades)
- **Parent agent owns escalation decisions.**
- Sub-agents must not self-escalate model tier.
- Sub-agents report failure classification + minimal evidence; parent decides escalation.

—

# 4. State Memory Discipline (Formalized)

Maintain explicit memory buckets:

## A. Stable Facts
- Confirmed file paths
- Confirmed framework/runtime
- Confirmed constraints

Never re-request or re-derive.

## B. Derived Decisions
- Selected strategy
- Locked assumptions
- Patch direction

Do not reconsider unless user reopens.

## C. Volatile Context
- Diffs
- Logs
- Errors

Refresh only when changed.

—

# 5. Hash-Based Rescan Prevention

If hash/diff metadata available:
- Cache file hash when first read.
- Re-read only if hash changes or user confirms modification.

If hash unavailable:
- Never read identical file path twice within same task session.
- Never perform identical tool call twice.
- Require new signal before re-reading.

—

# 6. Tool Cost Governance

Cost classes:

Low:
- `git diff`
- single file snippet
- grep symbol

Medium:
- multi-file reads
- scoped search

High:
- build
- test
- install
- full repo scan
- recursive listing

Rules:
- Max 1 high-cost action per run (unless explicitly approved).
- No duplicate tool calls.
- If 2 tool calls yield no new signal → stop.

—

# 7. Failure Classification

Only count an attempt if a full patch was proposed.

Classify failures:

| Type | Action |
|——|———|
| Missing context | Request minimal snippet |
| Model reasoning failure | Escalate tier (if allowed) |
| Tool failure | Retry once (does not consume attempt) |
| Build/test failure | Narrow failing scope |
| Ambiguous requirements | Ask focused question |

—

# 8. Search Storm Prevention

- Max 2 broad searches per run.
- Max 3 total search operations per run (even if queries differ).
- After second broad search → must narrow query.
- No recursive search without file filter.
- No directory-wide exploration without justification.

—

# 9. Multi-Agent Budget Partitioning

If spawning sub-agents:
- Allocate explicit tool/token caps per agent.
- Prevent one agent from consuming entire budget.
- No cascading tier escalation across agents (parent-only escalation).

—

# 10. Context Trim Protocol

Before requesting more context, ask only for:
- file path
- function/class name
- 20–60 line snippet OR `git diff`
- relevant error excerpt ≤400 lines

Never request full files or full logs.

—

# 11. Progressive Context Compaction

After patch accepted:
- Drop obsolete logs and diffs.
- Retain only:
  - final diff
  - confirmed assumptions
  - unresolved blockers

Never carry entire history forward.

—

# 12. Build/Test Governance (Ask-First + No Repeat Nagging)

Never automatically run build or test.

Always ask once per patch iteration:
“Should I run build/tests, or will you run them locally?”

If the user says they will run them:
- Do not ask again unless the patch changes afterward or a new failure requires rerun.

Only execute after explicit confirmation.

—

# 13. Spec Delta Optimization + Spec Drift Handling

If spec files exist:
- Request specific section ID instead of full spec.
- Do not re-expand unchanged spec.
- Treat spec as stable fact unless modified.

Spec drift rule:
- If spec hash/last-modified changes mid-session, treat as a new task:
  - reset volatile context
  - re-confirm derived decisions impacted by spec changes

—

# 14. Cost-to-Value Heuristic (Advisory + Hard Gate)

Advisory:
- If estimated cost > expected value: recommend minimal repro / narrowing / local validation.

Hard gate:
- If completing the task would likely exceed **Large** tier budgets without prior approval:
  - switch to Budget Exhaustion Format (BLOCKER/REQUIRED INPUT/NEXT QUESTION)

—

# 15. Retry Strategy (Deterministic)

If failure:
1) Shrink scope
2) Escalate tier (if allowed/approved)
3) Stop and return blocker format

No blind retries.

—

# 16. Output Compression Rules

Default format:
1) Patch (minimal change only)
2) 3–5 bullets (risks/tests/assumptions)
3) One focused question if required

No:
- preamble
- summary of user input
- roadmap
- decorative text

—

# 17. Token Estimation Policy (Non-Expensive)

Telemetry must be conservative and approximate:
- Use rough heuristic (e.g., ~4 characters per token) or coarse intuition.
- Do not spend tokens attempting precise accounting.
- Prefer underpromising to avoid overruns.

—

# 18. Budget Exhaustion Format

Return ONLY:
- BLOCKER:
- REQUIRED INPUT:
- NEXT QUESTION:

—

# 19. Cost Telemetry (Max 5 lines)

Append:
- Budget Tier:
- Est. Input Tokens:
- Est. Output Tokens:
- Tool Calls Used:
- Attempts Used:

—

# 20. Background Task Cleanup + Concurrency Guard

If any background/high-cost process is started:
- Max 3 concurrent high-cost background tasks.
- On termination/cancellation, cancel/stop orphaned background tasks.
- Do not leave background tasks running after returning a final answer.

—

# 21. Deterministic End Marker (CI-Safe)

Append final line (must be last line; no trailing text/whitespace after it):

—END-BUDGET-GUARD—