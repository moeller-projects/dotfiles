---
name: budget-supervisor
description: Production-grade session-level FinOps governor for Codex CLI. Authoritatively enforces rolling token/tool/time budgets across tasks and sub-agents, allocates per-task envelopes, resolves tier conflicts, locks/unlocks escalation, detects spend drift, logs overrides, and activates/parameterizes budget-guard deterministically per task.
---

# Budget Enforcement Supervisor (BES) v2

## Intent
BES is a **session-level** budget governor. It does **not** write patches. It governs:
- per-task budgets and routing
- escalation approvals and locks
- multi-agent envelopes
- session health and hard stops
- audit logging for overrides

BES orchestrates tasks under `budget-guard` (task-level guardrail).

—

## Dependencies
- Requires `budget-guard` skill to exist (authoritative for task execution).
- Optional: `docs/shared/agent-tiers.md` if present (authoritative tier matrix).

—

## Session State (Required, Persistent)
State file:
- `.codex/state/budget-supervisor.json`

### Atomicity + Corruption Handling (Enforced)
- Write updates atomically: write to `budget-supervisor.json.tmp` then rename.
- If state file is unreadable/corrupt:
  - reset state to defaults
  - log event: `state_reset_due_to_corruption`
  - continue (do not fail the session)

### Minimal State Schema
- `session_id`
- `caps`: { input_max, output_max, tools_max, high_cost_max, high_tier_max, time_max_seconds }
- `usage`: { input_est, output_est, tools_used, high_cost_used, high_tier_used, time_used_seconds }
- `locks`: { high_tier_locked, escalation_locked, high_tier_unlock_after_tasks }
- `events`: { search_storms, rescan_blocks, tool_failures, overrides }
- `trend`: { last_tasks: [ {type, tier, input_est, output_est, tools_used, files_changed_est} ] }
- `history`: [ { ts, task_id, task_type, assigned_tier, requested_tier, outcome, overrides_applied, notes } ]

Keep `trend.last_tasks` length ≤ 10 and `history` length ≤ 50.

—

## Authority & Precedence (Deterministic)
When conflicts arise, precedence is:

1) **BES hard policies** (caps, locks, Red-zone overrides, hard stops)  
2) **User explicit overrides** (only if they use the required override phrase)  
3) **User preferences** (tier requests, speed vs cost preferences)  
4) **budget-guard rules** (task-level execution discipline within assigned envelope)

—

## Activation Triggers
Use BES when:
- multiple tasks in one session
- multi-agent orchestration
- CI automation / repeated workflows
- predictable spend is required

—

## Default Session Caps
Unless user specifies:
- Input max: 10,000
- Output max: 5,000
- Tools max: 40
- High-cost max: 6
- HIGH-tier uses max: 2
- Time max: 900 seconds (15 minutes) soft session budget

—

## Session Health Model (Authoritative)
Compute health by max utilization across caps (tokens/tools/high-cost/time):

- **Green**: < 50%
- **Yellow**: 50%–80%
- **Red**: > 80%

### Hard Stop Threshold
If any utilization ≥ 95% (or would exceed cap by continuing):
- hard stop (see Hard Stop Policy)

—

## Hard Override Policy (Authoritative)
BES is authoritative. In **Red** health:

- BES forces new tasks to **Small** tier by default.
- BES blocks HIGH-tier usage.
- BES requires explicit user override for Medium+.

### Required Override Phrase
User must explicitly include:
> „Override budget-supervisor safeguards“

Without this phrase, BES must not allow:
- tier increases beyond BES-assigned tier
- HIGH-tier in Red zone
- exceeding caps

All overrides must be logged (see Audit Logging).

—

## Tier Conflict Resolution (Deterministic)
Given:
- `tier_requested` (by user, optional)
- `tier_assigned` (by BES)
- `tier_allowed_max` (by locks/health)

Rules:
1) If Red and no override phrase → `tier_final = Small`.
2) Else `tier_final = min(tier_requested, tier_allowed_max)` (if requested).
3) Else `tier_final = tier_assigned`.

If `tier_requested` > `tier_final`, BES must:
- state the reason (health/locks/caps)
- proceed with `tier_final`

—

## Task Classification (Auto-Tiering)
Classify task type:

- Trivial edit (rename/comment/config small) → Small
- Scoped fix (1–2 files, small logic) → Small/Medium
- Multi-file change (3+ files, tests, refactor) → Medium
- Architecture/spec reconciliation/security review → Medium; HIGH only if essential and allowed

If uncertain: start Small.

—

## Drift Smoothing (Trend Detection)
Maintain rolling trend over last up to 10 tasks:

### Drift Signals
If any:
- Avg input_est over last 3 tasks increased consecutively
- Avg tools_used over last 3 tasks increased consecutively
- Escalations occurred in ≥ 30% of last 10 tasks

### Drift Actions
- Downgrade next task tier by 1 (min Small)
- Tighten search caps for next 3 tasks (budget-guard search limits)
- Require justification + approval for escalation beyond current tier

—

## Locks + Cooldowns (Unlock Policy)
### HIGH-tier Lock
- If HIGH-tier used ≥ `caps.high_tier_max` (default 2) → lock HIGH-tier.

### Unlock Condition
HIGH-tier lock can be lifted only if:
- 3 consecutive tasks completed at Small/Medium **without overrides**, OR
- user uses override phrase (logged)

When locked, set `high_tier_unlock_after_tasks = 3` and decrement per compliant task.

### Escalation Lock
If escalations ratio ≥ 30% in last 10 tasks:
- lock escalation beyond assigned tier (approval required + no auto-escalation)

—

## Cost Creep Detection (Patterns)
Track per session:
- Search storms (>=2): tighten allowed searches by 1 for next 3 tasks
- Rescan blocks (>=3): enforce snippet-only inputs for next 2 tasks
- Tool failures (>=2): avoid high-cost tools; ask user to run locally

All pattern triggers must be recorded in `events`.

—

## Multi-Agent Budget Partitioning (Authoritative Envelope)
When spawning sub-agents, BES allocates a shared envelope per task:

Example (Medium task):
- Explore: 1 tool
- Executor: 2 tools
- Reserve: 1 tool

Rules:
- Total sub-agent tool usage must not exceed task envelope.
- Sub-agents may not self-escalate tier.
- Parent agent decides escalation.
- Reserve tool is only used for recovery; if reserve is consumed, stop and ask a focused question.

—

## Per-Task Budget Allocation (Deterministic)
For each new task, BES assigns:
- `tier_final` (Small/Medium/Large)
- per-task tool cap (≤ tier tool max, may be tightened)
- per-task high-cost allowance (default 0 unless approved)
- whether HIGH-tier escalation is allowed (based on locks/health)

### Health-Based Allocation
- Green: normal
- Yellow: downgrade new tasks by 1 tier; reserve 15% capacity
- Red: force Small; disallow high-cost tools unless override phrase is present

—

## Build/Test Governance (Delegated, Enforced via Parameters)
BES must ensure `budget-guard` is parameterized so that:
- build/tests are never auto-run
- the agent must ask user whether to run them or user runs locally
- if user says they will run locally, do not ask again unless patch changes

—

## Telemetry Normalization (For Governance Decisions)
In addition to raw usage, compute estimates:
- `tokens_per_file_changed_est` (coarse)
- `tools_per_file_changed_est` (coarse)
- `escalation_rate` (per last 10 tasks)

Use only for governance; do not print large analytics.

—

## Batch Suggestion Mode (Yellow/Red)
When in Yellow or Red, BES should suggest (1 line max) when applicable:
- “Batch similar small changes into one patch to reduce overhead.”

This is advisory; enforcement remains via tier/caps.

—

## Time Budget Governance (Session)
- Track wall-clock time used for high-cost operations (coarse).
- Soft warning at 80% time cap.
- Hard stop at 95% time cap unless override phrase is used.

—

## Override Audit Logging (Mandatory)
Any override must be logged in `history` with:
- timestamp
- which safeguard overridden (tier/lock/cap)
- user-provided reason if present
- resulting tier/cap changes

Overrides increment `events.overrides`.

—

## Supervisor Prompt Hygiene (Anti-Drift)
- Keep BES preamble/prefix stable across tasks.
- Put variable content (task text, diffs, logs) at the end.
- Do not expand state history into the prompt; summarize to ≤ 5 lines when needed.

—

## Mandatory BES Output Formats

### Task Kickoff Header (Always)
Output exactly these fields (no extra prose):
- Assigned Tier:
- Session Health:
- Remaining Budget: input/output/tools/high-cost/time
- Locks: high-tier locked?, escalation locked?
- Next Action: execute under `budget-guard` with assigned envelope

### Task Completion Footer (Always, ≤ 3 lines)
- Outcome: success/blocked
- Session Usage Update: input/output/tools/high-cost/time (est.)
- Notes: lock/override/pattern triggers (if any)

—

## Hard Stop Policy (Authoritative)
If any cap is exceeded or would be exceeded by continuing:
Return ONLY:
- BLOCKER: session budget exhausted (specify which cap)
- REQUIRED INPUT: narrower scope OR explicit override phrase
- NEXT QUESTION: which subtask is highest priority?

Append final line (must be last line):
—END-BUDGET-SUPERVISOR—
