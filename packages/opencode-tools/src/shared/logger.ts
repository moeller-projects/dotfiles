/**
 * Structured logger for opencode-tools.
 *
 * Emits compact, machine-readable log lines to stderr.
 * Format: [LEVEL] tool=<name> <message> [key=value ...]
 */

export type LogLevel = "debug" | "info" | "warn" | "error";

export interface LogFields {
  [key: string]: string | number | boolean | null | undefined;
}

function formatFields(fields: LogFields): string {
  return Object.entries(fields)
    .filter(([, v]) => v !== undefined && v !== null)
    .map(([k, v]) => `${k}=${JSON.stringify(v)}`)
    .join(" ");
}

function emit(level: LogLevel, tool: string, message: string, fields: LogFields = {}): void {
  const parts: string[] = [`[${level.toUpperCase()}]`, `tool=${tool}`, message];
  const extra = formatFields(fields);
  if (extra) parts.push(extra);
  process.stderr.write(parts.join(" ") + "\n");
}

export function createLogger(toolName: string) {
  return {
    debug: (message: string, fields?: LogFields) => emit("debug", toolName, message, fields),
    info: (message: string, fields?: LogFields) => emit("info", toolName, message, fields),
    warn: (message: string, fields?: LogFields) => emit("warn", toolName, message, fields),
    error: (message: string, fields?: LogFields) => emit("error", toolName, message, fields),
  };
}

export type Logger = ReturnType<typeof createLogger>;
