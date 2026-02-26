import fs from "node:fs";
import fsp from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";

type Action = "lookup" | "store" | "invalidate" | "stats";

export type AnalysisCacheInputBase = {
  namespace?: string;
};

export type AnalysisCacheLookupInput = AnalysisCacheInputBase & {
  key?: string;
  key_extra?: unknown;
};

export type AnalysisCacheStoreInput = AnalysisCacheInputBase & {
  key?: string;
  key_extra?: unknown;
  ttl_sec?: number;
  max_bytes?: number;
  artifact?: string;
  metadata?: unknown;
};

export type AnalysisCacheInvalidateInput = AnalysisCacheInputBase & {
  invalidate_prefix?: string;
};

export type AnalysisCacheStatsInput = AnalysisCacheInputBase;

type CacheEntry = {
  namespace: string;
  cache_id: string;
  key_hash: string;
  key_preview: string;
  created_at: string;
  expires_at: string | null;
  artifact: string;
  metadata?: unknown;
};

type ExecContext = {
  worktree: string;
  directory: string;
};

const DEFAULT_CACHE_DIR = ".codex/cache/analysis-cache";
const DEFAULT_MAX_BYTES = 256 * 1024; // 256 KiB
const DEFAULT_TTL_SEC = 0;

function nowIso() {
  return new Date().toISOString();
}

function sha256(data: string) {
  return crypto.createHash("sha256").update(data).digest("hex");
}

function stableStringify(value: unknown): string {
  if (value === null || value === undefined) return String(value);
  if (typeof value !== "object") return JSON.stringify(value);

  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }

  const obj = value as Record<string, unknown>;
  const keys = Object.keys(obj).sort();
  const items = keys.map((k) => `${JSON.stringify(k)}:${stableStringify(obj[k])}`);
  return `{${items.join(",")}}`;
}

function sanitizeSegment(seg: string) {
  const cleaned = seg.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 80);
  return cleaned.length ? cleaned : "default";
}

function resolveCacheRoot(ctx: ExecContext): string {
  // Optional override: absolute OR relative-to-worktree
  const env = process.env.OPENCODE_ANALYSIS_CACHE_DIR?.trim();
  const base = env && env.length ? env : DEFAULT_CACHE_DIR;

  const root = path.isAbsolute(base) ? base : path.resolve(ctx.worktree, base);

  // Security: prevent escaping worktree when relative is used
  if (!path.isAbsolute(base)) {
    const wt = path.resolve(ctx.worktree);
    if (!root.startsWith(wt + path.sep) && root !== wt) {
      throw new Error("Invalid cache root (escapes worktree)");
    }
  }

  return root;
}

function entryPath(ctx: ExecContext, namespace: string, cacheId: string) {
  const root = resolveCacheRoot(ctx);
  const ns = sanitizeSegment(namespace);
  const shard = cacheId.slice(0, 2);
  return path.join(root, ns, shard, `${cacheId}.json`);
}

async function ensureDir(dir: string) {
  await fsp.mkdir(dir, { recursive: true });
}

function computeKeyHash(namespace: string, key: string, keyExtra: unknown) {
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

async function atomicWriteJson(filePath: string, data: any) {
  const dir = path.dirname(filePath);
  await ensureDir(dir);
  const tmp = path.join(dir, `.tmp-${process.pid}-${crypto.randomBytes(6).toString("hex")}.json`);
  const body = JSON.stringify(data, null, 2);
  await fsp.writeFile(tmp, body, { encoding: "utf8", mode: 0o600 });
  await fsp.rename(tmp, filePath);
}

async function safeReadJson<T>(filePath: string): Promise<T | null> {
  try {
    const text = await fsp.readFile(filePath, "utf8");
    return JSON.parse(text) as T;
  } catch (e: any) {
    if (e?.code === "ENOENT") return null;
    throw e;
  }
}

async function listFilesRecursive(dir: string): Promise<string[]> {
  const out: string[] = [];
  async function walk(d: string) {
    let items: fs.Dirent[];
    try {
      items = await fsp.readdir(d, { withFileTypes: true });
    } catch (e: any) {
      if (e?.code === "ENOENT") return;
      throw e;
    }
    for (const it of items) {
      const p = path.join(d, it.name);
      if (it.isDirectory()) await walk(p);
      else if (it.isFile() && it.name.endsWith(".json")) out.push(p);
    }
  }
  await walk(dir);
  return out;
}

function requireKey(key: unknown): string {
  if (typeof key !== "string" || key.length === 0) {
    throw new Error("Missing key");
  }
  return key;
}

export async function analysisCacheLookup(input: AnalysisCacheLookupInput, ctx: ExecContext) {
  const namespace = sanitizeSegment(input.namespace ?? "default");
  const key = requireKey(input.key);
  const keyExtra = input.key_extra ?? null;

  const keyHash = computeKeyHash(namespace, key, keyExtra);
  const cacheId = keyHash;

  const p = entryPath(ctx, namespace, cacheId);
  const entry = await safeReadJson<CacheEntry>(p);

  if (!entry) return { ok: true, cache_hit: false };

  if (isExpired(entry)) {
    try {
      await fsp.unlink(p);
    } catch {}
    return { ok: true, cache_hit: false, expired: true };
  }

  return { ok: true, cache_hit: true, entry };
}

export async function analysisCacheStore(input: AnalysisCacheStoreInput, ctx: ExecContext) {
  const namespace = sanitizeSegment(input.namespace ?? "default");
  const key = requireKey(input.key);
  const keyExtra = input.key_extra ?? null;

  if (typeof input.artifact !== "string") {
    throw new Error("Missing artifact (string)");
  }
  const artifact = input.artifact;

  const maxBytes = Number.isFinite(input.max_bytes) ? (input.max_bytes as number) : DEFAULT_MAX_BYTES;
  const ttlSec = Number.isFinite(input.ttl_sec) ? (input.ttl_sec as number) : DEFAULT_TTL_SEC;

  const bytes = Buffer.byteLength(artifact, "utf8");
  if (bytes > maxBytes) {
    return { ok: false, error: "Artifact exceeds max_bytes", details: { bytes, maxBytes } };
  }

  const keyHash = computeKeyHash(namespace, key, keyExtra);
  const cacheId = keyHash;

  const createdAt = nowIso();
  const expiresAt = computeExpiresAt(ttlSec);

  const entry: CacheEntry = {
    namespace,
    cache_id: cacheId,
    key_hash: keyHash,
    key_preview: key.slice(0, 200),
    created_at: createdAt,
    expires_at: expiresAt,
    artifact,
    metadata: input.metadata,
  };

  const p = entryPath(ctx, namespace, cacheId);
  await atomicWriteJson(p, entry);

  return {
    ok: true,
    stored: true,
    namespace,
    cache_id: cacheId,
    path: p,
    bytes,
    expires_at: expiresAt,
  };
}

export async function analysisCacheInvalidate(input: AnalysisCacheInvalidateInput, ctx: ExecContext) {
  const namespace = sanitizeSegment(input.namespace ?? "default");
  const root = resolveCacheRoot(ctx);
  const nsDir = path.join(root, namespace);

  const prefix = input.invalidate_prefix ? String(input.invalidate_prefix) : "";
  const files = await listFilesRecursive(nsDir);

  let deleted = 0;
  for (const f of files) {
    const entry = await safeReadJson<CacheEntry>(f);
    if (!entry) continue;

    const cacheId = String(entry.cache_id ?? "");
    if (!prefix || cacheId.startsWith(prefix)) {
      try {
        await fsp.unlink(f);
        deleted++;
      } catch (e: any) {
        if (e?.code !== "ENOENT") throw e;
      }
    }
  }

  return { ok: true, namespace, deleted };
}

export async function analysisCacheStats(input: AnalysisCacheStatsInput, ctx: ExecContext) {
  const namespace = sanitizeSegment(input.namespace ?? "default");
  const root = resolveCacheRoot(ctx);
  const nsDir = path.join(root, namespace);

  const files = await listFilesRecursive(nsDir);

  let totalBytes = 0;
  let count = 0;
  let expired = 0;

  for (const f of files) {
    const st = await fsp.stat(f);
    totalBytes += st.size;
    count++;

    const entry = await safeReadJson<CacheEntry>(f);
    if (entry && entry.expires_at && Date.now() > new Date(entry.expires_at).getTime()) {
      expired++;
    }
  }

  return {
    ok: true,
    namespace,
    root,
    entries: count,
    total_bytes: totalBytes,
    expired_entries: expired,
  };
}
