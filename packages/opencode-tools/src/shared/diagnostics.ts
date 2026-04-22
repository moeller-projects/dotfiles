/**
 * Diagnostics helpers for opencode-tools.
 *
 * Provides structured result types used by the doctor/verification layer.
 */

export type CheckStatus = "ok" | "warn" | "fail";

export interface CheckResult {
  name: string;
  status: CheckStatus;
  message: string;
  detail?: string;
}

export interface DiagnosticsReport {
  tool: string;
  version: string;
  timestamp: string;
  overall: CheckStatus;
  checks: CheckResult[];
}

export function check(name: string, status: CheckStatus, message: string, detail?: string): CheckResult {
  return { name, status, message, detail };
}

export function buildReport(tool: string, version: string, checks: CheckResult[]): DiagnosticsReport {
  const overall: CheckStatus = checks.some((c) => c.status === "fail")
    ? "fail"
    : checks.some((c) => c.status === "warn")
      ? "warn"
      : "ok";

  return {
    tool,
    version,
    timestamp: new Date().toISOString(),
    overall,
    checks,
  };
}

export function printReport(report: DiagnosticsReport): void {
  const icon = report.overall === "ok" ? "✓" : report.overall === "warn" ? "⚠" : "✗";
  process.stdout.write(`\n${icon} ${report.tool} diagnostics: ${report.overall.toUpperCase()}\n\n`);

  for (const c of report.checks) {
    const mark = c.status === "ok" ? "  ✓" : c.status === "warn" ? "  ⚠" : "  ✗";
    process.stdout.write(`${mark} ${c.name}: ${c.message}\n`);
    if (c.detail) {
      process.stdout.write(`      ${c.detail}\n`);
    }
  }
  process.stdout.write("\n");
}
