# OpenCode Platform Baseline

**Version:** 1.0.0
**Date:** 2026-04-04
**Status:** Baseline capture

---

## 1. Asset Inventory

### 1.1 Static Configuration

| Path | Target | Platforms |
|------|--------|-----------|
| `dotfiles/ai-agents/opencode/config.jsonc` | `~/.config/opencode/opencode.jsonc` | linux |
| `dotfiles/ai-agents/opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` | linux |

### 1.2 Agents

| File | Purpose |
|------|---------|
| `dotfiles/ai-agents/opencode/agents/edit.prompt.md` | Code editing agent instructions |
| `dotfiles/ai-agents/opencode/agents/planner.prompt.md` | Planning/task decomposition agent |
| `dotfiles/ai-agents/opencode/agents/review.prompt.md` | Code review agent |

### 1.3 Commands

| Command | Description |
|---------|-------------|
| `code-review.md` | Full code review workflow |
| `openspec-eval.md` | OpenSpec evaluation workflow |
| `perf-review.md` | Performance review |
| `plan-feature.md` | Feature planning |
| `pr-govern.md` | PR governance / mutation validation |
| `regression-review.md` | Regression risk review |
| `review-file.md` | Single-file review |
| `security-review.md` | Security-focused review |

### 1.4 Skills (23 total)

| Skill | Domain |
|-------|--------|
| `agentsmd-expert` | documentation |
| `budget-guard` | governance |
| `budget-supervisor` | governance |
| `chaos-engineer` | engineering |
| `clean-code-master` | engineering |
| `deep-research` | research |
| `devops-engineer` | engineering |
| `doc-forge` | documentation |
| `interactive-plan` | planning |
| `kubernetes-specialist` | engineering |
| `legacy-modernizer` | engineering |
| `monorepo-navigator` | engineering |
| `mvp-watcher` | product |
| `openspec-expert` | specification |
| `perf-analyst` | engineering |
| `playwright-expert` | testing |
| `prompt-engineer` | ai |
| `readme-expert` | documentation |
| `refactor-engine` | engineering |
| `spec-miner` | specification |
| `test-forge` | testing |
| `the-fool` | reasoning |
| `threat-modeler` | security |

### 1.5 Policies

| Policy | Description |
|--------|-------------|
| `policies/analysis-cache.md` | Analysis artifact caching policy |

### 1.6 Custom Tools (runtime executables)

| Tool | Description | Import |
|------|-------------|--------|
| `tools/patch-validator.ts` | Validates unified diff patches against mutation contract | `@opencode-ai/plugin`, `zod` |
| `tools/analysis-cache.ts` | Deterministic analysis artifact cache | `@opencode-ai/plugin`, `zod`, `node:fs`, `node:path`, `node:crypto` |

---

## 2. Runtime Dependency Map

### patch-validator

- **Runtime:** OpenCode TypeScript host (Bun-based)
- **Imports:** `@opencode-ai/plugin` (provided by OpenCode), `zod`
- **Entrypoint:** `default export` of `tool({...})`
- **Contract:** Accepts a unified diff string, returns `{ valid, percent_changed, files, violations }`
- **Environment variables:** none required
- **Governance integration:** Called by `pr-govern.md` command before any mutation approval

### analysis-cache

- **Runtime:** OpenCode TypeScript host (Bun-based)
- **Imports:** `@opencode-ai/plugin`, `zod`, Node.js builtins (`fs`, `path`, `crypto`)
- **Entrypoint:** `default export` of `tool({...})`
- **Contract:** Accepts `action` (lookup/store/invalidate/stats/prune) + namespace/key/artifact
- **Environment variables:** `OPENCODE_ANALYSIS_CACHE_DIR` (optional; default: `.opencode/cache/analysis-cache`)
- **Storage:** `.opencode/cache/analysis-cache/` relative to worktree

---

## 3. Dotfiles Map Coverage

All OpenCode assets are mapped in `dotfiles.map.json` for linux. No windows/macos mappings exist for OpenCode config (OpenCode is primarily a Linux/macOS tool).

---

## 4. Governance

- Global governance contract: `dotfiles/ai-agents/opencode/AGENTS.md`
- Mutation threshold: 30% per file
- Validation: `patch-validator` required before any mutation
- Caching: `analysis-cache` mandatory for expensive analyses
- Governance version: 2.0.0
