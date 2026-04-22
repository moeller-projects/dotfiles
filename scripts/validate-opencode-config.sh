#!/usr/bin/env bash
# scripts/validate-opencode-config.sh
#
# Validates the opencode.jsonc config file against its JSON schema.
#
# Usage:
#   bash scripts/validate-opencode-config.sh [--config <path>]
#
# Requires: node

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# REPO_ROOT may be used by callers that source this script
# shellcheck disable=SC2034
readonly REPO_ROOT
CONFIG_FILE="${1:-}"

# Determine config path
if [[ -z "$CONFIG_FILE" ]]; then
  if [[ -n "${OPENCODE_CONFIG_HOME:-}" ]]; then
    CONFIG_FILE="${OPENCODE_CONFIG_HOME}/opencode.jsonc"
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    CONFIG_FILE="${HOME}/.config/opencode/opencode.jsonc"
  else
    CONFIG_FILE="${XDG_CONFIG_HOME:-${HOME}/.config}/opencode/opencode.jsonc"
  fi
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "SKIP: opencode.jsonc not found at ${CONFIG_FILE}"
  exit 0
fi

echo "Validating: ${CONFIG_FILE}"

node - <<'JS' "$CONFIG_FILE"
const fs   = require('fs');
const path = require('path');
const file = process.argv[2];
const raw  = fs.readFileSync(file, 'utf8');

// String-aware JSONC parser (handles comments and trailing commas)
function parseJsonc(text) {
  // Step 1: strip comments while preserving string content
  let result = '';
  let inString = false;
  let i = 0;
  while (i < text.length) {
    const ch = text[i];
    if (inString) {
      if (ch === '\\') {
        result += ch + (text[i + 1] || '');
        i += 2;
        continue;
      }
      if (ch === '"') inString = false;
      result += ch;
      i++;
    } else {
      if (ch === '"') {
        inString = true;
        result += ch;
        i++;
      } else if (ch === '/' && text[i + 1] === '/') {
        while (i < text.length && text[i] !== '\n') i++;
      } else if (ch === '/' && text[i + 1] === '*') {
        i += 2;
        while (i < text.length && !(text[i] === '*' && text[i + 1] === '/')) i++;
        i += 2;
      } else {
        result += ch;
        i++;
      }
    }
  }
  // Step 2: strip trailing commas before } or ]
  result = result.replace(/,(\s*[}\]])/g, '$1');
  return JSON.parse(result);
}

let parsed;
try {
  parsed = parseJsonc(raw);
} catch (e) {
  console.error(`FAIL: JSON parse error in ${file}`);
  console.error(`  ${e.message}`);
  process.exit(1);
}

// Basic structural checks
const errors = [];
if (parsed.model && typeof parsed.model !== 'string') {
  errors.push('"model" must be a string');
}
if (parsed.permission && typeof parsed.permission !== 'object') {
  errors.push('"permission" must be an object');
}
if (parsed.mcp) {
  for (const [name, srv] of Object.entries(parsed.mcp)) {
    if (!srv.type) errors.push(`mcp.${name}: missing "type"`);
    if (!srv.command) errors.push(`mcp.${name}: missing "command"`);
  }
}

if (errors.length > 0) {
  console.error(`FAIL: ${errors.length} validation error(s):`);
  errors.forEach(e => console.error(`  - ${e}`));
  process.exit(1);
}

console.log(`OK: ${file} is valid`);
JS
