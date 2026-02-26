type Violation = {
  type: string;
  file?: string;
  message?: string;
  percent_changed?: number;
};

type FileReport = {
  file: string;
  added: number;
  removed: number;
  context: number;
  percent_changed: number;
  violations: Violation[];
};

export type PatchValidationOptions = {
  maxChangePercent: number;
  strict: boolean;
};

export type PatchValidationResult = {
  valid: boolean;
  reason?: string;
  percent_changed: number;
  files: FileReport[];
  violations: Violation[];
};

function normalizeLine(line: string) {
  return line.trim().replace(/\s+/g, " ");
}

function isUnifiedDiff(patch: string) {
  return patch.includes("--- ") && patch.includes("+++ ") && patch.includes("@@");
}

function isImportLine(line: string) {
  // JS/TS: import ... from
  // C#: using ...
  const l = line.trim();
  return l.startsWith("import ") || l.startsWith("using ");
}

function extractFileName(filePatch: string): string {
  const m = filePatch.match(/^\+\+\+\s+b\/(.+)$/m);
  return m?.[1] ?? "unknown";
}

function splitIntoFilePatches(patch: string): string[] {
  // Works for git diff (diff --git ...) and simple unified diffs.
  const chunks = patch.split(/^diff --git /m);
  if (chunks.length > 1) return chunks.filter(Boolean).map((c) => "diff --git " + c);
  // fallback: treat whole patch as single file
  return [patch];
}

export function validatePatch(patch: string, options: PatchValidationOptions): PatchValidationResult {
  const maxChange = options.maxChangePercent ?? 30;
  const strict = options.strict ?? true;

  const violations: Violation[] = [];
  const files: FileReport[] = [];

  if (!isUnifiedDiff(patch)) {
    return {
      valid: false,
      reason: "Not unified diff",
      percent_changed: 0,
      files: [],
      violations: [{ type: "invalid-format", message: "Not unified diff" }],
    };
  }

  for (const filePatch of splitIntoFilePatches(patch)) {
    const file = extractFileName(filePatch);
    const lines = filePatch.split("\n");

    let added = 0;
    let removed = 0;
    let context = 0;

    const addedLines: string[] = [];
    const removedLines: string[] = [];

    for (const line of lines) {
      if (line.startsWith("+") && !line.startsWith("+++")) {
        added++;
        addedLines.push(line.substring(1));
      } else if (line.startsWith("-") && !line.startsWith("---")) {
        removed++;
        removedLines.push(line.substring(1));
      } else if (line.startsWith(" ") || line.startsWith("@@") || line.startsWith("\\ No newline at end of file")) {
        if (line.startsWith(" ")) context++;
      }
    }

    const totalOriginal = removed + context;
    const percent = totalOriginal === 0 ? 100 : ((added + removed) / totalOriginal) * 100;

    const fileViolations: Violation[] = [];

    // Threshold enforcement
    if (percent > maxChange) {
      fileViolations.push({
        type: "excessive-change",
        file,
        percent_changed: percent,
        message: `Change exceeds threshold (${percent.toFixed(1)}% > ${maxChange}%)`,
      });
    }

    // Full rewrite heuristic: no context lines, both add and remove present
    if (context === 0 && added > 0 && removed > 0) {
      fileViolations.push({
        type: "full-rewrite",
        file,
        message: "No context lines detected; likely full rewrite",
      });
    }

    // Whitespace-only diffs heuristic
    const normAdded = addedLines.map(normalizeLine);
    const normRemoved = removedLines.map(normalizeLine);
    if (normAdded.length === normRemoved.length && normAdded.length > 0 && normAdded.every((l, i) => l === normRemoved[i])) {
      fileViolations.push({
        type: "whitespace-only",
        file,
        message: "Diff appears to be whitespace-only",
      });
    }

    // Import reorder heuristic (order-only change)
    const removedImports = removedLines
      .filter((l) => isImportLine(l))
      .map(normalizeLine)
      .sort();
    const addedImports = addedLines
      .filter((l) => isImportLine(l))
      .map(normalizeLine)
      .sort();

    if (removedImports.length > 0 && removedImports.length === addedImports.length && JSON.stringify(removedImports) === JSON.stringify(addedImports)) {
      fileViolations.push({
        type: "import-reorder",
        file,
        message: "Import lines appear reordered without semantic change",
      });
    }

    // Optional stricter formatting-only heuristic
    if (strict) {
      const strip = (s: string) =>
        s
          .replace(/\/\/.*$/g, "") // line comments
          .replace(/\/\*[\s\S]*?\*\//g, "") // block comments
          .replace(/\s+/g, " ")
          .trim();

      const a = addedLines.map(strip).filter(Boolean);
      const r = removedLines.map(strip).filter(Boolean);

      // If after stripping comments/whitespace, the sets match line-by-line -> formatting drift
      if (a.length === r.length && a.length > 0 && a.every((l, i) => l === r[i])) {
        fileViolations.push({
          type: "formatting-only",
          file,
          message: "Diff appears formatting-only after normalization",
        });
      }
    }

    files.push({
      file,
      added,
      removed,
      context,
      percent_changed: percent,
      violations: fileViolations,
    });

    violations.push(...fileViolations);
  }

  const totalPercent = files.length === 0 ? 0 : files.reduce((acc, f) => acc + f.percent_changed, 0) / files.length;

  return {
    valid: violations.length === 0,
    percent_changed: totalPercent,
    files,
    violations,
    reason: violations.length ? "Mutation contract violations detected" : undefined,
  };
}
