---
name: eco-mode
description: Reduce token usage and cost by enforcing context trimming, caching-friendly prompts, output caps, and iteration limits. Use when users ask to be resource-efficient, lower OpenAI spend, create cost-saving policies/templates, or tune agent behavior for minimal tokens.
---

# Eco Mode

## Overview
Apply a strict, low-token operating mode that trims context, stabilizes cached prefixes, and caps output while preserving task success.

## Trigger Phrases
Use this skill when the user asks for any of the following:
- Reduce token usage or cost.
- Create “eco mode”, “low token mode”, or “budget mode”.
- Trim prompts, stabilize caching, or cap verbosity.
- Design policies/templates for efficient agent usage.

## Operating Rules
- Enforce “minimal repro first”: request only the smallest relevant snippet, diff, or log section needed to proceed.
- Prefer `git diff` or function snippets over full files.
- Cap log excerpts to 200–400 lines unless the user justifies more.
- Define and state a context budget (default target: 1,500–3,000 input tokens). Ask for approval to exceed.
- Enforce hard caps unless explicitly overridden:
  - Max output tokens: 800.
  - Max tool calls: 4.
  - Max attempts: 2 before asking a focused question.
- Stabilize prompt prefixes for caching: keep the first sections byte-identical across runs; move variable content to the end; avoid dates, build numbers, run IDs, or reordered bullet lists in the prefix.
- Prefer retrieval or file-path pointers over copy-paste; include only short retrieved snippets.
- Cap output: default to patch + 3–5 bullets (risks/tests). Avoid long explanations unless asked.
- Limit iteration: max 3–5 tool calls or attempts; if no new info after 2 tries, stop and ask a focused question.
- Use phased model routing: small model for triage and trimming, large model for patch generation, small model for review or formatting.
- Make cost visible: track input tokens, output tokens, and iteration counts per task category.
- Use a context trim checklist before asking for more input: request file path, function name, and a 20–60 line snippet or `git diff`.
- If token budget would be exceeded, return only 3 bullets: blockers, required inputs, next question.
- Apply budget tiering by default: small 1k/400, medium 2k/800, large 3k/1k (input/output).

## Default Prompt Template
Use or adapt this when the user needs a reusable template. A copy lives at `.codex/prompts/eco-mode.md`.

```text
Goal (1 sentence):
Context (max 5 bullets):
Relevant code (snippet or diff only):
Expected output format: Patch + 3 bullets (risks/tests)
Constraints (runtime, frameworks, no new deps, etc.):
Token budget: input <= 3,000, output <= 1,000
```

## Response Format
When responding in eco mode, default to:
1. The patch or direct change (if applicable).
2. 3–5 bullets: risks, tests, or assumptions.
3. One focused question if required to continue.

## Escalation Rules
- If the task cannot be completed within the token budget, say so and request a smaller snippet or clearer scope.
- If the user insists on large context, require justification and confirm budget increase.
