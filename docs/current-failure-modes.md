# Current Failure Modes

**Version:** 1.0.0
**Date:** 2026-04-04
**Status:** Baseline issue list

---

## F-001: Tool not discovered by OpenCode

**Symptom:** OpenCode session does not show `patch-validator` or `analysis-cache` in available tools.

**Root cause:** Tools require `~/.config/opencode/tools/` to contain the `.ts` source files. If the dotfiles installer has not been run, the directory is not linked.

**Detection:** `bash bootstrap/opencode/doctor.sh` — check `tool-dotfiles-*` results.

**Remediation:**
1. Run `bash install.sh` to link dotfiles to `~/.config/opencode/tools/`
2. Verify with `bash bootstrap/opencode/doctor.sh`

---

## F-002: Tool discovered but not executable

**Symptom:** Tool appears in OpenCode but fails to run with an import error.

**Root cause:** `@opencode-ai/plugin` or `zod` is not available in the OpenCode runtime environment.

**Detection:** `bash scripts/smoke-opencode-tools.sh` after build; or check OpenCode session logs.

**Remediation:**
- These packages are expected to be bundled with OpenCode itself.
- If using a custom OpenCode build, ensure `@opencode-ai/plugin` is in the runtime.
- `zod` can be installed separately: `npm install -g zod` as a fallback.

---

## F-003: Config drift

**Symptom:** `opencode.jsonc` has stale values (wrong model, outdated MCP commands, etc.)

**Root cause:** Config was manually edited at `~/.config/opencode/opencode.jsonc` without updating the repo source.

**Detection:** `bash scripts/validate-opencode-config.sh` — fails if JSON is invalid.

**Remediation:**
1. Compare `~/.config/opencode/opencode.jsonc` with `dotfiles/ai-agents/opencode/config.jsonc`
2. Merge intentional local changes back into `dotfiles/ai-agents/opencode/config.jsonc`
3. Re-run `bash install.sh`

---

## F-004: Broken paths in dotfiles map

**Symptom:** `install.sh --check` reports missing or foreign items.

**Root cause:** A key in `dotfiles.map.json` points to a path that does not exist under `dotfiles/`.

**Detection:** `bash install.sh --check`

**Remediation:**
1. Run `bash install.sh --check` and inspect the foreign/missing items.
2. Either add the missing file or remove the stale map entry.

---

## F-005: Missing runtime dependency (node, npm, jq)

**Symptom:** Bootstrap fails at preflight stage.

**Root cause:** Required tools not installed on the target machine.

**Detection:** `bash bootstrap/opencode/install.sh` — fails at Stage 1 preflight.

**Remediation:**
- **node >=20:** Install via [nodejs.org](https://nodejs.org) or `mise use node@lts`
- **npm:** Bundled with Node.js
- **jq:** `sudo apt install jq` (Linux) or `brew install jq` (macOS)

---

## F-006: Unsupported platform assumption

**Symptom:** Scripts fail on macOS with path errors (e.g., `~/.config/opencode` vs `~/Library/...`)

**Root cause:** OpenCode uses `~/.config/opencode` on both Linux and macOS. The bootstrap scripts detect `uname -s` to set paths. The dotfiles map currently only has `linux` platform entries for OpenCode.

**Detection:** Doctor script path checks fail on macOS.

**Remediation:**
- Add `macos` platform entries to `dotfiles.map.json` for `ai-agents/opencode/*`
- The install scripts already handle macOS via `uname -s` detection.

---

## F-007: SKILL.md missing or invalid frontmatter

**Symptom:** OpenCode cannot auto-discover skills; `check-skills.yml` CI job fails.

**Root cause:** A new skill was added without the required YAML frontmatter block.

**Detection:** `bash scripts/validate-skills.sh` or `.github/workflows/check-skills.yml`

**Remediation:**
1. Run `bash scripts/validate-skills.sh` to identify the offending file.
2. Add or fix the YAML frontmatter in the SKILL.md file.
3. Required fields: `name` (kebab-case) and `description` (>=20 chars, trigger-oriented).

---

## F-008: Build artifacts committed to repo

**Symptom:** `packages/opencode-tools/dist/` or `node_modules/` appear in git status.

**Root cause:** `.gitignore` not set up to exclude build output.

**Detection:** `git status` shows dist or node_modules files.

**Remediation:**
- The root `.gitignore` excludes `**/node_modules/` and `packages/*/dist`.
- If accidentally committed, run: `git rm -r --cached packages/opencode-tools/dist packages/opencode-tools/node_modules`
