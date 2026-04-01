import { tool } from "@opencode-ai/plugin";
import fs from "node:fs";
import fsp from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";
import { z } from "zod";

type CacheAction = "lookup" | "store" | "invalidate" | "stats" | "prune";

type CacheEntry = {
  schema_version: 2;
  namespace: string;
  namespace_original: string;
  cache_id: string;
  key_hash: string;
  key_preview: string;
  created_at: string;
  expires_at: string | null;
  artifact: string;
  metadata?: unknown;
};

type CacheMetadataRecord = Record<string, unknown>;

const SCHEMA_VERSION = 2;
const DEFAULT_CACHE_DIR = ".opencode/cache/analysis-cache";
const DEFAULT_MAX_BYTES = 256 * 1024;
const DEFAULT_TTL_SEC = 0;

function nowIso(): string {
  return new Date().toISOString();
}

function sha256(data: string): string {
  return crypto.createHash("sha256").update(data).digest("hex");
}

function stableStringify(value: unknown, seen = new WeakSet<object>()): string {
  if (value === null) return "null";
  if (value === undefined) return "undefined";

  const valueType = typeof value;

  if (valueType === "string") return JSON.stringify(value);
  if (valueType === "number") {
    if (Number.isNaN(value)) return '"[NaN]"';
    if (value === Infinity) return '"[Infinity]"';
    if (value === -Infinity) return '"[-Infinity]"';
    return JSON.stringify(value);
  }
  if (valueType === "boolean") return JSON.stringify(value);
  if (valueType === "bigint") return `{"$bigint":"${String(value)}"}`;
  if (valueType === "symbol") return `{"$symbol":${JSON.stringify(String(value))}}`;
  if (valueType === "function") {
    throw new Error("Cannot serialize function in stableStringify");
  }

  if (value instanceof Date) {
    return `{"$date":${JSON.stringify(value.toISOString())}}`;
  }

  if (Buffer.isBuffer(value)) {
    return `{"$buffer":${JSON.stringify(value.toString("base64"))}}`;
  }

  if (Array.isArray(value)) {
    return `[${value.map((item) => stableStringify(item, seen)).join(",")}]`;
  }

  if (valueType === "object") {
    const obj = value as Record<string, unknown>;

    if (seen.has(obj)) {
      throw new Error("Cannot serialize cyclic structure");
    }

    seen.add(obj);
    try {
      const keys = Object.keys(obj).sort();
      const items = keys.map((key) => `${JSON.stringify(key)}:${stableStringify(obj[key], seen)}`);
      return `{${items.join(",")}}`;
    } finally {
      seen.delete(obj);
    }
  }

  return JSON.stringify(value);
}

function sanitizeSegment(seg: string): string {
  const cleaned = seg.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 80);
  return cleaned.length ? cleaned : "default";
}

function namespaceDirName(namespace: string): string {
  const sanitized = sanitizeSegment(namespace);
  const suffix = sha256(namespace).slice(0, 10);
  return `${sanitized}__${suffix}`;
}

function resolveBaseDir(worktree?: string, directory?: string): string {
  return worktree ?? directory ?? process.cwd();
}

function getCacheRoot(worktree?: string, directory?: string): string {
  const baseDir = resolveBaseDir(worktree, directory);
  const env = process.env.OPENCODE_ANALYSIS_CACHE_DIR?.trim();

  if (env) {
    return path.isAbsolute(env) ? env : path.resolve(baseDir, env);
  }

  return path.resolve(baseDir, DEFAULT_CACHE_DIR);
}

function entryPath(worktree: string | undefined, directory: string | undefined, namespace: string, cacheId: string): string {
  const root = getCacheRoot(worktree, directory);
  const ns = namespaceDirName(namespace);
  const shard = cacheId.slice(0, 2);
  return path.join(root, ns, shard, `${cacheId}.json`);
}

function toRootRelativePath(filePath: string, worktree?: string, directory?: string): string {
  const root = getCacheRoot(worktree, directory);
  return path.relative(root, filePath);
}

async function ensureDir(dir: string): Promise<void> {
  await fsp.mkdir(dir, { recursive: true });
}

function computeKeyHash(namespace: string, key: string, keyExtra: unknown): string {
  const composite = `${namespace}\n${key}\n${stableStringify(keyExtra)}`;
  return sha256(composite);
}

function computeExpiresAt(ttlSec: number): string | null {
  if (!ttlSec || ttlSec <= 0) return null;
  return new Date(Date.now() + ttlSec * 1000).toISOString();
}

function isExpired(entry: CacheEntry): boolean {
  if (!entry.expires_at) return false;
  return Date.now() > new Date(entry.expires_at).getTime();
}

function metadataMatches(entryMetadata: unknown, requested: Record<string, unknown> | undefined): boolean {
  if (!requested || Object.keys(requested).length === 0) return true;
  if (!entryMetadata || typeof entryMetadata !== "object" || Array.isArray(entryMetadata)) return false;

  const record = entryMetadata as CacheMetadataRecord;
  return Object.entries(requested).every(([key, value]) => {
    return stableStringify(record[key]) === stableStringify(value);
  });
}

async function atomicWriteJson(filePath: string, data: unknown): Promise<void> {
  const dir = path.dirname(filePath);
  await ensureDir(dir);

  const tmp = path.join(dir, `.tmp-${process.pid}-${crypto.randomBytes(6).toString("hex")}.json`);

  await fsp.writeFile(tmp, JSON.stringify(data, null, 2), {
    encoding: "utf8",
    mode: 0o600,
  });

  await fsp.rename(tmp, filePath);
}

async function safeReadJson<T>(filePath: string): Promise<T | null> {
  try {
    const text = await fsp.readFile(filePath, "utf8");
    return JSON.parse(text) as T;
  } catch (e: unknown) {
    if (typeof e === "object" && e !== null && "code" in e && (e as { code?: string }).code === "ENOENT") {
      return null;
    }
    throw e;
  }
}

async function safeStat(filePath: string): Promise<fs.Stats | null> {
  try {
    return await fsp.stat(filePath);
  } catch (e: unknown) {
    if (typeof e === "object" && e !== null && "code" in e && (e as { code?: string }).code === "ENOENT") {
      return null;
    }
    throw e;
  }
}

async function safeUnlink(filePath: string): Promise<boolean> {
  try {
    await fsp.unlink(filePath);
    return true;
  } catch (e: unknown) {
    if (typeof e === "object" && e !== null && "code" in e && (e as { code?: string }).code === "ENOENT") {
      return false;
    }
    throw e;
  }
}

async function listFilesRecursive(dir: string): Promise<string[]> {
  const out: string[] = [];

  async function walk(currentDir: string): Promise<void> {
    let items: fs.Dirent[];

    try {
      items = await fsp.readdir(currentDir, { withFileTypes: true });
    } catch (e: unknown) {
      if (typeof e === "object" && e !== null && "code" in e && (e as { code?: string }).code === "ENOENT") {
        return;
      }
      throw e;
    }

    for (const item of items) {
      const fullPath = path.join(currentDir, item.name);
      if (item.isDirectory()) {
        await walk(fullPath);
      } else if (item.isFile() && item.name.endsWith(".json")) {
        out.push(fullPath);
      }
    }
  }

  await walk(dir);
  return out;
}

async function collectNamespaceFiles(worktree: string | undefined, directory: string | undefined, namespace: string): Promise<string[]> {
  const root = getCacheRoot(worktree, directory);
  const nsDir = path.join(root, namespaceDirName(namespace));
  return listFilesRecursive(nsDir);
}

export default tool({
  description: "Deterministic structural artifact cache",
  args: {
    action: z.enum(["lookup", "store", "invalidate", "stats", "prune"] satisfies [CacheAction, ...CacheAction[]]),
    namespace: z.string().optional(),
    key: z.string().optional(),
    key_extra: z.unknown().optional(),
    ttl_sec: z.number().int().nonnegative().optional(),
    max_bytes: z.number().int().positive().optional(),
    artifact: z.string().optional(),
    metadata: z.unknown().optional(),
    key_prefix: z.string().optional(),
    metadata_match: z.record(z.string(), z.unknown()).optional(),
    prune_expired: z.boolean().optional(),
  },

  async execute(args, context) {
    const namespaceOriginal = args.namespace ?? "default";
    const namespace = namespaceOriginal;
    const maxBytes = args.max_bytes ?? DEFAULT_MAX_BYTES;
    const ttlSec = args.ttl_sec ?? DEFAULT_TTL_SEC;
    const worktree = context.worktree;
    const directory = context.directory;

    if (args.action === "stats") {
      const files = await collectNamespaceFiles(worktree, directory, namespace);

      let totalBytes = 0;
      let count = 0;
      let expired = 0;
      let pruned = 0;

      for (const filePath of files) {
        const stat = await safeStat(filePath);
        if (!stat) continue;

        const entry = await safeReadJson<CacheEntry>(filePath);
        if (!entry) continue;

        totalBytes += stat.size;
        count++;

        if (isExpired(entry)) {
          expired++;
          if (args.prune_expired) {
            if (await safeUnlink(filePath)) {
              pruned++;
              totalBytes -= stat.size;
              count--;
            }
          }
        }
      }

      return {
        ok: true,
        namespace,
        root: getCacheRoot(worktree, directory),
        entries: count,
        total_bytes: totalBytes,
        expired_entries: expired,
        pruned_entries: pruned,
      };
    }

    if (args.action === "prune") {
      const files = await collectNamespaceFiles(worktree, directory, namespace);
      let pruned = 0;

      for (const filePath of files) {
        const entry = await safeReadJson<CacheEntry>(filePath);
        if (!entry) continue;

        if (isExpired(entry)) {
          if (await safeUnlink(filePath)) {
            pruned++;
          }
        }
      }

      return {
        ok: true,
        namespace,
        pruned_entries: pruned,
      };
    }

    if (args.action === "invalidate") {
      const files = await collectNamespaceFiles(worktree, directory, namespace);
      const keyPrefix = args.key_prefix ?? "";
      const metadataMatch = args.metadata_match;

      let deleted = 0;

      for (const filePath of files) {
        const entry = await safeReadJson<CacheEntry>(filePath);
        if (!entry) continue;

        const keyMatches = !keyPrefix || entry.key_preview.startsWith(keyPrefix);
        const metadataOk = metadataMatches(entry.metadata, metadataMatch);

        if (keyMatches && metadataOk) {
          if (await safeUnlink(filePath)) {
            deleted++;
          }
        }
      }

      return {
        ok: true,
        namespace,
        deleted,
        criteria: {
          key_prefix: keyPrefix || undefined,
          metadata_match: metadataMatch,
        },
      };
    }

    if (!args.key) {
      throw new Error("Missing key");
    }

    const keyHash = computeKeyHash(namespace, args.key, args.key_extra ?? null);
    const cacheId = keyHash;
    const filePath = entryPath(worktree, directory, namespace, cacheId);

    if (args.action === "lookup") {
      const entry = await safeReadJson<CacheEntry>(filePath);

      if (!entry) {
        return {
          ok: true,
          cache_hit: false,
        };
      }

      if (isExpired(entry)) {
        await safeUnlink(filePath);
        return {
          ok: true,
          cache_hit: false,
          expired: true,
        };
      }

      return {
        ok: true,
        cache_hit: true,
        entry,
      };
    }

    if (args.action === "store") {
      if (typeof args.artifact !== "string") {
        throw new Error("Missing artifact (string)");
      }

      const bytes = Buffer.byteLength(args.artifact, "utf8");
      if (bytes > maxBytes) {
        throw new Error(`Artifact exceeds max_bytes: ${bytes} > ${maxBytes}`);
      }

      const entry: CacheEntry = {
        schema_version: SCHEMA_VERSION,
        namespace: namespaceDirName(namespace),
        namespace_original: namespace,
        cache_id: cacheId,
        key_hash: keyHash,
        key_preview: args.key.slice(0, 200),
        created_at: nowIso(),
        expires_at: computeExpiresAt(ttlSec),
        artifact: args.artifact,
        metadata: args.metadata,
      };

      await atomicWriteJson(filePath, entry);

      return {
        ok: true,
        stored: true,
        namespace,
        cache_id: cacheId,
        relative_path: toRootRelativePath(filePath, worktree, directory),
        bytes,
        expires_at: entry.expires_at,
      };
    }

    throw new Error(`Unknown action: ${args.action satisfies never}`);
  },
});
