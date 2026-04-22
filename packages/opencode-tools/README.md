# opencode-tools

Custom runtime tools for OpenCode agent sessions.

## Overview

This package is the **source of truth** for custom OpenCode tools. The TypeScript
sources here are compiled and deployed into the OpenCode tools directory as part of
the bootstrap process.

```
packages/opencode-tools/src/   ← author changes here
packages/opencode-tools/dist/  ← compiled output (generated, not committed)
dotfiles/ai-agents/opencode/tools/  ← deployed artifacts (synced by bootstrap)
~/.config/opencode/tools/      ← live runtime location (linked by install.sh)
```

## Tools

| Tool | Description |
|------|-------------|
| `patch-validator` | Validates unified diff patches against the minimal-mutation governance contract |
| `analysis-cache` | Deterministic structural artifact cache for expensive analysis reuse |

## Shared Utilities

| Module | Description |
|--------|-------------|
| `shared/logger` | Structured stderr logger |
| `shared/fs-utils` | Safe filesystem helpers (null-on-ENOENT) |
| `shared/diagnostics` | CheckResult/DiagnosticsReport types and printers |

## Development

```bash
# Install dependencies
npm install

# Type-check only (no output)
npm run lint

# Compile to dist/
npm run build

# Clean build artifacts
npm run clean
```

## Runtime Contract

Each tool exports a default `tool({...})` object compatible with the OpenCode plugin
API. At runtime, `@opencode-ai/plugin` is provided by the OpenCode host environment.
During local development and CI, a vendor type stub satisfies the TypeScript compiler.

## Deployment

The bootstrap installer (`bootstrap/opencode/install.sh`) copies the `.ts` source
files from `src/` to `dotfiles/ai-agents/opencode/tools/`, which the dotfiles
installer then links to `~/.config/opencode/tools/`.

Run the doctor to verify deployment:

```bash
bash bootstrap/opencode/doctor.sh
```
