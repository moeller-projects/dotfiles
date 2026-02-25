#!/usr/bin/env node
import crypto from "crypto";

type Violation = {
  type: string;
  file?: string;
  percent_changed?: number;
  message?: string;
};

function readStdin(): Promise<string> {
  return new Promise((resolve) => {
    let data = "";
    process.stdin.on("data", (c) => (data += c));
    process.stdin.on("end", () => resolve(data));
  });
}

function normalizeLine(line: string) {
  return line.trim().replace(/\s+/g, " ");
}

function isImport(line: string) {
  return /^(\+|-)?\s*(import .* from|using )/.test(line);
}

async function main() {
  const raw = await readStdin();
  const input = JSON.parse(raw);

  const patch: string = input.patch;
  const maxChange = input.max_change_percent ?? 30;

  if (!patch.includes("--- ") || !patch.includes("+++ ") || !patch.includes("@@")) {
    return console.log(
      JSON.stringify({
        valid: false,
        violations: [{ type: "invalid-format", message: "Not unified diff" }],
      }),
    );
  }

  const files = patch.split(/^diff --git/m).filter(Boolean);
  const violations: Violation[] = [];
  const fileReports: any[] = [];

  for (const filePatch of files) {
    const lines = filePatch.split("\n");

    let added = 0;
    let removed = 0;
    let unchanged = 0;

    const addedLines: string[] = [];
    const removedLines: string[] = [];

    for (const line of lines) {
      if (line.startsWith("+") && !line.startsWith("+++")) {
        added++;
        addedLines.push(line.substring(1));
      } else if (line.startsWith("-") && !line.startsWith("---")) {
        removed++;
        removedLines.push(line.substring(1));
      } else if (!line.startsWith("@@")) {
        unchanged++;
      }
    }

    const totalOriginal = removed + unchanged;
    const percent = totalOriginal === 0 ? 100 : ((added + removed) / totalOriginal) * 100;

    const fileNameMatch = filePatch.match(/\+\+\+ b\/(.+)/);
    const fileName = fileNameMatch?.[1] ?? "unknown";

    const fileViolations: Violation[] = [];

    // Rule: excessive change
    if (percent > maxChange) {
      fileViolations.push({
        type: "excessive-change",
        file: fileName,
        percent_changed: percent,
      });
    }

    // Rule: full rewrite
    if (unchanged === 0 && added > 0 && removed > 0) {
      fileViolations.push({
        type: "full-rewrite",
        file: fileName,
      });
    }

    // Rule: whitespace-only
    const normAdded = addedLines.map(normalizeLine);
    const normRemoved = removedLines.map(normalizeLine);

    if (normAdded.length === normRemoved.length && normAdded.every((l, i) => l === normRemoved[i])) {
      fileViolations.push({
        type: "whitespace-only",
        file: fileName,
      });
    }

    // Rule: import reorder
    const removedImports = removedLines.filter(isImport).map(normalizeLine).sort();
    const addedImports = addedLines.filter(isImport).map(normalizeLine).sort();

    if (removedImports.length > 0 && JSON.stringify(removedImports) === JSON.stringify(addedImports)) {
      fileViolations.push({
        type: "import-reorder",
        file: fileName,
      });
    }

    if (fileViolations.length) {
      violations.push(...fileViolations);
    }

    fileReports.push({
      file: fileName,
      percent_changed: percent,
      violations: fileViolations,
    });
  }

  const valid = violations.length === 0;

  console.log(
    JSON.stringify(
      {
        valid,
        percent_changed: fileReports.reduce((a, f) => a + f.percent_changed, 0),
        files: fileReports,
        violations,
      },
      null,
      2,
    ),
  );
}

main();
