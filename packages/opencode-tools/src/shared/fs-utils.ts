/**
 * Safe filesystem utilities for opencode-tools.
 *
 * All functions return null on ENOENT rather than throwing,
 * and handle errors explicitly rather than silently swallowing them.
 */

import fs from "node:fs";
import fsp from "node:fs/promises";
import path from "node:path";

export async function safeReadText(filePath: string): Promise<string | null> {
  try {
    return await fsp.readFile(filePath, "utf8");
  } catch (e: unknown) {
    if (isNotFound(e)) return null;
    throw e;
  }
}

export async function safeReadJson<T>(filePath: string): Promise<T | null> {
  const text = await safeReadText(filePath);
  if (text === null) return null;
  return JSON.parse(text) as T;
}

export async function safeStat(filePath: string): Promise<fs.Stats | null> {
  try {
    return await fsp.stat(filePath);
  } catch (e: unknown) {
    if (isNotFound(e)) return null;
    throw e;
  }
}

export async function safeUnlink(filePath: string): Promise<boolean> {
  try {
    await fsp.unlink(filePath);
    return true;
  } catch (e: unknown) {
    if (isNotFound(e)) return false;
    throw e;
  }
}

export async function ensureDir(dir: string): Promise<void> {
  await fsp.mkdir(dir, { recursive: true });
}

export async function atomicWriteJson(filePath: string, data: unknown): Promise<void> {
  const { randomBytes } = await import("node:crypto");
  const dir = path.dirname(filePath);
  await ensureDir(dir);
  const tmp = path.join(dir, `.tmp-${process.pid}-${randomBytes(6).toString("hex")}.json`);
  await fsp.writeFile(tmp, JSON.stringify(data, null, 2), { encoding: "utf8", mode: 0o600 });
  await fsp.rename(tmp, filePath);
}

export async function listFilesRecursive(dir: string): Promise<string[]> {
  const out: string[] = [];

  async function walk(currentDir: string): Promise<void> {
    let items: fs.Dirent[];
    try {
      items = await fsp.readdir(currentDir, { withFileTypes: true });
    } catch (e: unknown) {
      if (isNotFound(e)) return;
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

function isNotFound(e: unknown): boolean {
  return typeof e === "object" && e !== null && "code" in e && (e as { code?: string }).code === "ENOENT";
}
