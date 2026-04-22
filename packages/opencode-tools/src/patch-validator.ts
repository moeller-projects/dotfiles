import { tool } from "@opencode-ai/plugin";
import { z } from "zod";

type Severity = "error" | "warning";
type FileStatus = "added" | "deleted" | "modified" | "renamed" | "unknown";

type Violation = {
  type: string;
  severity: Severity;
  file?: string;
  status?: FileStatus;
  percent_changed?: number;
  message?: string;
};

type FileReport = {
  file: string;
  status: FileStatus;
  added: number;
  removed: number;
  unchanged: number;
  percent_changed: number;
  violations: Violation[];
};

type ParsedFilePatch = {
  raw: string;
  file: string;
  status: FileStatus;
  added: number;
  removed: number;
  unchanged: number;
  addedLines: string[];
  removedLines: string[];
  violations: Violation[];
};

function normalizeLine(line: string): string {
  return line.trim().replace(/\s+/g, " ");
}

function isImport(line: string): boolean {
  return /^(\s*)(import\s+.*(?:from\s+["'][^"']+["']|["'][^"']+["'])\s*;?|\s*using\s+.+;?\s*$)/.test(line);
}

function isGitDiffPatch(patch: string): boolean {
  return /^diff --git /m.test(patch);
}

function isDiffMetadataLine(line: string): boolean {
  return (
    line.startsWith("diff --git ") ||
    line.startsWith("index ") ||
    line.startsWith("--- ") ||
    line.startsWith("+++ ") ||
    line.startsWith("@@") ||
    line.startsWith("new file mode ") ||
    line.startsWith("deleted file mode ") ||
    line.startsWith("similarity index ") ||
    line.startsWith("rename from ") ||
    line.startsWith("rename to ")
  );
}

function multisetEquals(a: string[], b: string[]): boolean {
  if (a.length !== b.length) return false;

  const counts = new Map<string, number>();
  for (const item of a) {
    counts.set(item, (counts.get(item) ?? 0) + 1);
  }

  for (const item of b) {
    const current = counts.get(item);
    if (!current) return false;
    if (current === 1) counts.delete(item);
    else counts.set(item, current - 1);
  }

  return counts.size === 0;
}

function parseGitDiffFiles(patch: string): string[] {
  return patch
    .split(/^diff --git /m)
    .filter(Boolean)
    .map((part) => `diff --git ${part}`);
}

function parsePlainUnifiedDiffFiles(patch: string): string[] {
  const lines = patch.split("\n");
  const files: string[] = [];
  let current: string[] = [];

  for (const line of lines) {
    if (line.startsWith("--- ") && current.length > 0) {
      files.push(current.join("\n"));
      current = [line];
      continue;
    }

    current.push(line);
  }

  if (current.length > 0) {
    files.push(current.join("\n"));
  }

  return files.filter((file) => /^--- /m.test(file) && /^\+\+\+ /m.test(file));
}

function inferFileStatus(filePatch: string): FileStatus {
  if (/^rename from /m.test(filePatch) || /^rename to /m.test(filePatch)) return "renamed";
  if (/^new file mode /m.test(filePatch)) return "added";
  if (/^deleted file mode /m.test(filePatch)) return "deleted";

  const oldFile = filePatch.match(/^--- (.+)$/m)?.[1];
  const newFile = filePatch.match(/^\+\+\+ (.+)$/m)?.[1];

  if (oldFile === "/dev/null") return "added";
  if (newFile === "/dev/null") return "deleted";
  if (oldFile && newFile) return "modified";

  return "unknown";
}

function inferFileName(filePatch: string): string {
  const renameTo = filePatch.match(/^rename to (.+)$/m)?.[1];
  if (renameTo) return renameTo.replace(/^b\//, "");

  const newFile = filePatch.match(/^\+\+\+ (.+)$/m)?.[1];
  if (newFile && newFile !== "/dev/null") return newFile.replace(/^b\//, "");

  const oldFile = filePatch.match(/^--- (.+)$/m)?.[1];
  if (oldFile && oldFile !== "/dev/null") return oldFile.replace(/^a\//, "");

  return "unknown";
}

function computePercentChanged(added: number, removed: number, unchanged: number, status: FileStatus): number {
  const totalOriginal = removed + unchanged;

  if (status === "added") {
    return added > 0 ? 100 : 0;
  }

  if (status === "deleted") {
    return totalOriginal > 0 ? 100 : 0;
  }

  if (totalOriginal === 0) {
    return added + removed > 0 ? 100 : 0;
  }

  return ((added + removed) / totalOriginal) * 100;
}

function parseFilePatch(filePatch: string): ParsedFilePatch {
  const lines = filePatch.split("\n");
  const addedLines: string[] = [];
  const removedLines: string[] = [];

  let added = 0;
  let removed = 0;
  let unchanged = 0;

  for (const line of lines) {
    if (line.startsWith("+") && !line.startsWith("+++")) {
      added++;
      addedLines.push(line.slice(1));
      continue;
    }

    if (line.startsWith("-") && !line.startsWith("---")) {
      removed++;
      removedLines.push(line.slice(1));
      continue;
    }

    if (line.startsWith(" ")) {
      unchanged++;
      continue;
    }

    if (isDiffMetadataLine(line)) {
      continue;
    }
  }

  return {
    raw: filePatch,
    file: inferFileName(filePatch),
    status: inferFileStatus(filePatch),
    added,
    removed,
    unchanged,
    addedLines,
    removedLines,
    violations: [],
  };
}

export default tool({
  description: "Validates unified diff against strict mutation contract",
  args: {
    patch: z.string().describe("Unified diff patch to validate"),
    max_change_percent: z.number().positive().optional(),
    strict: z.boolean().optional(),
    allow_new_files: z.boolean().optional(),
    allow_deleted_files: z.boolean().optional(),
  },

  async execute(args) {
    const patch = args.patch;
    const maxChange = args.max_change_percent ?? 30;
    const strict = args.strict ?? true;
    const allowNewFiles = args.allow_new_files ?? false;
    const allowDeletedFiles = args.allow_deleted_files ?? false;

    if (!patch.includes("--- ") || !patch.includes("+++ ") || !patch.includes("@@")) {
      return {
        valid: false,
        percent_changed: 0,
        files: [] as FileReport[],
        violations: [
          {
            type: "invalid-format",
            severity: "error",
            message: "Not unified diff",
          },
        ] satisfies Violation[],
      };
    }

    const rawFiles = isGitDiffPatch(patch) ? parseGitDiffFiles(patch) : parsePlainUnifiedDiffFiles(patch);
    const parsedFiles = rawFiles.map(parseFilePatch);

    const allViolations: Violation[] = [];
    const fileReports: FileReport[] = [];

    let totalAdded = 0;
    let totalRemoved = 0;
    let totalUnchanged = 0;

    for (const parsed of parsedFiles) {
      const percentChanged = computePercentChanged(parsed.added, parsed.removed, parsed.unchanged, parsed.status);

      totalAdded += parsed.added;
      totalRemoved += parsed.removed;
      totalUnchanged += parsed.unchanged;

      const fileViolations: Violation[] = [];

      if (parsed.status === "added" && !allowNewFiles) {
        fileViolations.push({
          type: "new-file",
          severity: strict ? "error" : "warning",
          file: parsed.file,
          status: parsed.status,
          percent_changed: percentChanged,
          message: "Patch adds a new file",
        });
      }

      if (parsed.status === "deleted" && !allowDeletedFiles) {
        fileViolations.push({
          type: "deleted-file",
          severity: strict ? "error" : "warning",
          file: parsed.file,
          status: parsed.status,
          percent_changed: percentChanged,
          message: "Patch deletes a file",
        });
      }

      if (parsed.status === "modified" && percentChanged > maxChange) {
        fileViolations.push({
          type: "excessive-change",
          severity: "error",
          file: parsed.file,
          status: parsed.status,
          percent_changed: percentChanged,
          message: `Change exceeds ${maxChange}% threshold`,
        });
      }

      const hasNoContext = parsed.unchanged === 0 && parsed.added > 0 && parsed.removed > 0;
      const highRewriteRatio = percentChanged >= Math.max(90, maxChange);

      if (parsed.status === "modified" && hasNoContext && highRewriteRatio) {
        fileViolations.push({
          type: "full-rewrite-likely",
          severity: "error",
          file: parsed.file,
          status: parsed.status,
          percent_changed: percentChanged,
          message: "Patch likely rewrites the full file or nearly all of it",
        });
      }

      const normAdded = parsed.addedLines.map(normalizeLine);
      const normRemoved = parsed.removedLines.map(normalizeLine);

      if (parsed.addedLines.length > 0 && parsed.addedLines.length === parsed.removedLines.length && multisetEquals(normAdded, normRemoved)) {
        fileViolations.push({
          type: "whitespace-only",
          severity: strict ? "error" : "warning",
          file: parsed.file,
          status: parsed.status,
          percent_changed: percentChanged,
          message: "Patch appears whitespace-only",
        });
      }

      const removedImports = parsed.removedLines.filter(isImport).map(normalizeLine).sort();
      const addedImports = parsed.addedLines.filter(isImport).map(normalizeLine).sort();

      if (removedImports.length > 0 && removedImports.length === addedImports.length && multisetEquals(removedImports, addedImports)) {
        fileViolations.push({
          type: "import-reorder",
          severity: strict ? "error" : "warning",
          file: parsed.file,
          status: parsed.status,
          percent_changed: percentChanged,
          message: "Patch appears to only reorder imports",
        });
      }

      allViolations.push(...fileViolations);

      fileReports.push({
        file: parsed.file,
        status: parsed.status,
        added: parsed.added,
        removed: parsed.removed,
        unchanged: parsed.unchanged,
        percent_changed: percentChanged,
        violations: fileViolations,
      });
    }

    const globalPercentChanged = computePercentChanged(totalAdded, totalRemoved, totalUnchanged, "modified");

    const blockingViolations = allViolations.filter((violation) => violation.severity === "error");

    return {
      valid: blockingViolations.length === 0,
      percent_changed: globalPercentChanged,
      totals: {
        files: fileReports.length,
        added: totalAdded,
        removed: totalRemoved,
        unchanged: totalUnchanged,
      },
      files: fileReports,
      violations: allViolations,
    };
  },
});
