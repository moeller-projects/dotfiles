# Tool Runtime Inventory

**Version:** 1.0.0
**Date:** 2026-04-04

---

## patch-validator

**Source:** `packages/opencode-tools/src/patch-validator.ts`
**Deployed:** `dotfiles/ai-agents/opencode/tools/patch-validator.ts`
**Live:** `~/.config/opencode/tools/patch-validator.ts`

### Dependencies

| Package | Version | Source | Notes |
|---------|---------|--------|-------|
| `@opencode-ai/plugin` | peer | OpenCode host | Provides `tool()` factory |
| `zod` | ^3.x | npm | Schema validation |

### Execution Contract

```typescript
// Input
{
  patch: string;              // Unified diff (required)
  max_change_percent?: number; // Default: 30
  strict?: boolean;            // Default: true
  allow_new_files?: boolean;   // Default: false
  allow_deleted_files?: boolean; // Default: false
}

// Output
{
  valid: boolean;
  percent_changed: number;
  totals?: { files, added, removed, unchanged };
  files: FileReport[];
  violations: Violation[];
}
```

### Violation Types

| Type | Severity | Description |
|------|----------|-------------|
| `invalid-format` | error | Input is not a valid unified diff |
| `new-file` | error/warn | Patch adds a new file (blocked unless `allow_new_files=true`) |
| `deleted-file` | error/warn | Patch deletes a file (blocked unless `allow_deleted_files=true`) |
| `excessive-change` | error | File change exceeds `max_change_percent` threshold |
| `full-rewrite-likely` | error | Patch appears to rewrite entire file |
| `whitespace-only` | error/warn | Only whitespace differences detected |
| `import-reorder` | error/warn | Only import ordering changes detected |

---

## analysis-cache

**Source:** `packages/opencode-tools/src/analysis-cache.ts`
**Deployed:** `dotfiles/ai-agents/opencode/tools/analysis-cache.ts`
**Live:** `~/.config/opencode/tools/analysis-cache.ts`

### Dependencies

| Package | Version | Source | Notes |
|---------|---------|--------|-------|
| `@opencode-ai/plugin` | peer | OpenCode host | Provides `tool()` factory |
| `zod` | ^3.x | npm | Schema validation |
| `node:fs` | built-in | Node.js/Bun | File system |
| `node:fs/promises` | built-in | Node.js/Bun | Async file system |
| `node:path` | built-in | Node.js/Bun | Path utilities |
| `node:crypto` | built-in | Node.js/Bun | SHA-256 hashing |

### Execution Contract

```typescript
// Actions
type CacheAction = "lookup" | "store" | "invalidate" | "stats" | "prune";

// Input
{
  action: CacheAction;       // Required
  namespace?: string;        // Default: "default"
  key?: string;              // Required for lookup/store
  key_extra?: unknown;       // Additional key data for hashing
  ttl_sec?: number;          // TTL in seconds (0 = no expiry)
  max_bytes?: number;        // Max artifact size (default: 262144)
  artifact?: string;         // JSON string to store (required for store)
  metadata?: unknown;        // Arbitrary metadata to attach
  key_prefix?: string;       // For invalidate: prefix filter
  metadata_match?: Record<string, unknown>; // For invalidate: metadata filter
  prune_expired?: boolean;   // For stats: also prune expired entries
}
```

### Storage Layout

```
.opencode/cache/analysis-cache/
  <namespace__hash>/
    <shard>/
      <cache_id>.json
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENCODE_ANALYSIS_CACHE_DIR` | `.opencode/cache/analysis-cache` | Override cache directory |

### Schema Version

Current schema version: **2**. Changing the entry schema requires bumping `SCHEMA_VERSION`.
