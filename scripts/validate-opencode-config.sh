#!/usr/bin/env bash
# scripts/validate-opencode-config.sh
#
# Validates the opencode.jsonc config file against its JSON schema.
#
# Usage:
#   bash scripts/validate-opencode-config.sh [--config <path>]
#
# Requires: python3, jsonschema

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

python3 - "$CONFIG_FILE" "$REPO_ROOT/schemas/opencode-config.schema.json" <<'PY'
import sys, json, re
from pathlib import Path

try:
    import jsonschema
except ImportError:
    print("ERROR: jsonschema not installed. Run: pip install jsonschema")
    sys.exit(1)

config_file = sys.argv[1]
schema_file = sys.argv[2]

def strip_jsonc(text):
    """Strip // and /* */ comments and trailing commas from JSONC text."""
    result = []
    in_string = False
    i = 0
    while i < len(text):
        ch = text[i]
        if in_string:
            if ch == '\\':
                result.append(ch)
                result.append(text[i + 1] if i + 1 < len(text) else '')
                i += 2
                continue
            if ch == '"':
                in_string = False
            result.append(ch)
            i += 1
        else:
            if ch == '"':
                in_string = True
                result.append(ch)
                i += 1
            elif ch == '/' and i + 1 < len(text) and text[i + 1] == '/':
                while i < len(text) and text[i] != '\n':
                    i += 1
            elif ch == '/' and i + 1 < len(text) and text[i + 1] == '*':
                i += 2
                while i < len(text) and not (text[i] == '*' and i + 1 < len(text) and text[i + 1] == '/'):
                    i += 1
                i += 2
            else:
                result.append(ch)
                i += 1
    stripped = ''.join(result)
    # Strip trailing commas before } or ]
    stripped = re.sub(r',(\s*[}\]])', r'\1', stripped)
    return stripped

schema = json.loads(Path(schema_file).read_text(encoding="utf-8"))
raw = Path(config_file).read_text(encoding="utf-8")

try:
    parsed = json.loads(strip_jsonc(raw))
except json.JSONDecodeError as e:
    print(f"FAIL: JSON parse error in {config_file}: {e}")
    sys.exit(1)

try:
    jsonschema.validate(parsed, schema)
except jsonschema.ValidationError as e:
    print(f"FAIL: {config_file} schema validation error: {e.message}")
    sys.exit(1)
except jsonschema.SchemaError as e:
    print(f"FAIL: Schema error: {e.message}")
    sys.exit(1)

print(f"OK: {config_file} is valid")
PY
