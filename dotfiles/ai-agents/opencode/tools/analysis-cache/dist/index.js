#!/usr/bin/env node
import fsp from "node:fs/promises";
import path from "node:path";
import crypto from "node:crypto";
const DEFAULT_CACHE_DIR = ".codex/cache/analysis-cache";
const DEFAULT_MAX_BYTES = 256 * 1024; // 256 KiB
const DEFAULT_TTL_SEC = 0;
function nowIso() {
    return new Date().toISOString();
}
function sha256(data) {
    return crypto.createHash("sha256").update(data).digest("hex");
}
function stableStringify(value) {
    // Stable stringify for objects (deterministic hashing)
    if (value === null || value === undefined)
        return String(value);
    if (typeof value !== "object")
        return JSON.stringify(value);
    if (Array.isArray(value)) {
        return `[${value.map(stableStringify).join(",")}]`;
    }
    const obj = value;
    const keys = Object.keys(obj).sort();
    const items = keys.map((k) => `${JSON.stringify(k)}:${stableStringify(obj[k])}`);
    return `{${items.join(",")}}`;
}
function sanitizeSegment(seg) {
    // Allow only safe filename-ish chars
    const cleaned = seg.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 80);
    return cleaned.length ? cleaned : "default";
}
function getCacheRoot() {
    // Allow override via env
    const env = process.env.OPENCODE_ANALYSIS_CACHE_DIR?.trim();
    return env && env.length ? env : DEFAULT_CACHE_DIR;
}
function entryPath(namespace, cacheId) {
    const root = getCacheRoot();
    const ns = sanitizeSegment(namespace);
    // shard by first 2 bytes to avoid huge dirs
    const shard = cacheId.slice(0, 2);
    return path.join(root, ns, shard, `${cacheId}.json`);
}
async function ensureDir(dir) {
    await fsp.mkdir(dir, { recursive: true });
}
async function readStdin() {
    return await new Promise((resolve) => {
        let data = "";
        process.stdin.setEncoding("utf8");
        process.stdin.on("data", (c) => (data += c));
        process.stdin.on("end", () => resolve(data));
    });
}
function ok(payload) {
    process.stdout.write(JSON.stringify({ ok: true, ...payload }, null, 2));
}
function fail(message, details, code = 1) {
    process.stdout.write(JSON.stringify({ ok: false, error: message, details }, null, 2));
    process.exit(code);
}
function computeKeyHash(namespace, key, keyExtra) {
    const composite = `${namespace}\n${key}\n${stableStringify(keyExtra)}`;
    return sha256(composite);
}
function computeExpiresAt(ttlSec) {
    if (!ttlSec || ttlSec <= 0)
        return null;
    const ms = ttlSec * 1000;
    return new Date(Date.now() + ms).toISOString();
}
function isExpired(entry) {
    if (!entry.expires_at)
        return false;
    return Date.now() > new Date(entry.expires_at).getTime();
}
async function atomicWriteJson(filePath, data) {
    const dir = path.dirname(filePath);
    await ensureDir(dir);
    const tmp = path.join(dir, `.tmp-${process.pid}-${crypto.randomBytes(6).toString("hex")}.json`);
    const body = JSON.stringify(data, null, 2);
    await fsp.writeFile(tmp, body, { encoding: "utf8", mode: 0o600 });
    await fsp.rename(tmp, filePath);
}
async function safeReadJson(filePath) {
    try {
        const text = await fsp.readFile(filePath, "utf8");
        return JSON.parse(text);
    }
    catch (e) {
        if (e?.code === "ENOENT")
            return null;
        throw e;
    }
}
async function listFilesRecursive(dir) {
    const out = [];
    async function walk(d) {
        let items;
        try {
            items = await fsp.readdir(d, { withFileTypes: true });
        }
        catch (e) {
            if (e?.code === "ENOENT")
                return;
            throw e;
        }
        for (const it of items) {
            const p = path.join(d, it.name);
            if (it.isDirectory())
                await walk(p);
            else if (it.isFile() && it.name.endsWith(".json"))
                out.push(p);
        }
    }
    await walk(dir);
    return out;
}
async function main() {
    const raw = (await readStdin()).trim();
    if (!raw)
        fail("Empty input");
    let parsed;
    try {
        parsed = JSON.parse(raw);
    }
    catch {
        fail("Invalid JSON input");
    }
    const input = parsed;
    const action = input.action;
    if (!action)
        fail("Missing action");
    const namespace = sanitizeSegment(input.namespace ?? "default");
    const maxBytes = Number.isFinite(input.max_bytes) ? input.max_bytes : DEFAULT_MAX_BYTES;
    const ttlSec = Number.isFinite(input.ttl_sec) ? input.ttl_sec : DEFAULT_TTL_SEC;
    if (action === "stats") {
        const root = getCacheRoot();
        const nsDir = path.join(root, namespace);
        const files = await listFilesRecursive(nsDir);
        let totalBytes = 0;
        let count = 0;
        let expired = 0;
        for (const f of files) {
            const st = await fsp.stat(f);
            totalBytes += st.size;
            count++;
            const entry = await safeReadJson(f);
            if (entry && entry.expires_at && Date.now() > new Date(entry.expires_at).getTime())
                expired++;
        }
        return ok({
            namespace,
            root,
            entries: count,
            total_bytes: totalBytes,
            expired_entries: expired,
        });
    }
    if (action === "invalidate") {
        const root = getCacheRoot();
        const nsDir = path.join(root, namespace);
        const prefix = input.invalidate_prefix ? String(input.invalidate_prefix) : "";
        const files = await listFilesRecursive(nsDir);
        let deleted = 0;
        for (const f of files) {
            const entry = await safeReadJson(f);
            if (!entry)
                continue;
            const cacheId = String(entry.cache_id ?? "");
            if (!prefix || cacheId.startsWith(prefix)) {
                try {
                    await fsp.unlink(f);
                    deleted++;
                }
                catch (e) {
                    if (e?.code !== "ENOENT")
                        throw e;
                }
            }
        }
        return ok({ namespace, deleted });
    }
    // lookup/store require key
    if (typeof input.key !== "string" || input.key.length === 0) {
        fail("Missing key");
        return;
    }
    const key = input.key;
    const keyExtra = input.key_extra ?? null;
    const keyHash = computeKeyHash(namespace, key, keyExtra);
    const cacheId = keyHash; // you can separate if you want; using keyHash as cacheId is fine
    const p = entryPath(namespace, cacheId);
    if (action === "lookup") {
        const entry = (await safeReadJson(p));
        if (!entry)
            return ok({ cache_hit: false });
        if (isExpired(entry)) {
            // best-effort cleanup
            try {
                await fsp.unlink(p);
            }
            catch { }
            return ok({ cache_hit: false, expired: true });
        }
        return ok({
            cache_hit: true,
            entry,
        });
    }
    if (action === "store") {
        if (typeof input.artifact !== "string") {
            fail("Missing artifact (string)");
            return;
        }
        const artifact = input.artifact;
        const bytes = Buffer.byteLength(artifact, "utf8");
        if (bytes > maxBytes) {
            fail("Artifact exceeds max_bytes", { bytes, maxBytes });
        }
        const createdAt = nowIso();
        const expiresAt = computeExpiresAt(ttlSec);
        const entry = {
            namespace,
            cache_id: cacheId,
            key_hash: keyHash,
            key_preview: key.slice(0, 200),
            created_at: createdAt,
            expires_at: expiresAt,
            artifact,
            metadata: input.metadata,
        };
        await atomicWriteJson(p, entry);
        return ok({
            stored: true,
            namespace,
            cache_id: cacheId,
            path: p,
            bytes,
            expires_at: expiresAt,
        });
    }
    fail(`Unknown action: ${action}`);
}
main().catch((e) => {
    fail("Unhandled error", { message: String(e?.message ?? e), stack: e?.stack });
});
