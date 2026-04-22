#!/usr/bin/env bash
# bootstrap/opencode/lib/checks.sh
# Preflight and validation check functions for the OpenCode bootstrap.

set -euo pipefail

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
  RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; RESET='\033[0m'
else
  RED=''; YELLOW=''; GREEN=''; RESET=''
fi

_pass() { echo -e "${GREEN}  ✓${RESET} $*"; }
_warn() { echo -e "${YELLOW}  ⚠${RESET} $*"; }
_fail() { echo -e "${RED}  ✗${RESET} $*"; }

# check_command <name> [optional]
# Verifies that a command is available.
check_command() {
  local name="$1"
  local optional="${2:-false}"
  if command -v "$name" &>/dev/null; then
    _pass "command available: ${name}"
    return 0
  fi
  if [[ "$optional" == "true" ]]; then
    _warn "optional command not found: ${name}"
    return 0
  fi
  _fail "required command not found: ${name}"
  return 1
}

# check_dir_writable <path>
# Verifies that a directory exists and is writable, or can be created.
check_dir_writable() {
  local dir="$1"
  if [[ -d "$dir" ]] && [[ -w "$dir" ]]; then
    _pass "directory writable: ${dir}"
    return 0
  fi
  if [[ ! -e "$dir" ]]; then
    if mkdir -p "$dir" 2>/dev/null; then
      _pass "directory created: ${dir}"
      return 0
    fi
  fi
  _fail "directory not writable: ${dir}"
  return 1
}

# check_file_exists <path> [label]
check_file_exists() {
  local path="$1"
  local label="${2:-${path}}"
  if [[ -f "$path" ]]; then
    _pass "file exists: ${label}"
    return 0
  fi
  _fail "file missing: ${label}"
  return 1
}

# check_dir_exists <path> [label]
check_dir_exists() {
  local path="$1"
  local label="${2:-${path}}"
  if [[ -d "$path" ]]; then
    _pass "directory exists: ${label}"
    return 0
  fi
  _fail "directory missing: ${label}"
  return 1
}

# check_node_version <min_major>
check_node_version() {
  local min="$1"
  if ! command -v node &>/dev/null; then
    _fail "node not found (required: >=${min})"
    return 1
  fi
  local version
  version="$(node --version | sed 's/v//' | cut -d. -f1)"
  if (( version >= min )); then
    _pass "node version ok: $(node --version)"
    return 0
  fi
  _fail "node version too old: $(node --version) (required: >=${min})"
  return 1
}

# check_json_parse <path>
# Verifies a JSON/JSONC file parses without errors.
check_json_parse() {
  local path="$1"
  local label="${2:-${path}}"
  if [[ ! -f "$path" ]]; then
    _fail "file missing for JSON check: ${label}"
    return 1
  fi
  # String-aware JSONC comment and trailing-comma stripper
  if node -e "
    function parseJsonc(text) {
      var result = ''; var inString = false; var i = 0;
      while (i < text.length) {
        var ch = text[i];
        if (inString) {
          if (ch === '\\\\') { result += ch + (text[i+1]||''); i += 2; continue; }
          if (ch === '\"') inString = false;
          result += ch; i++;
        } else {
          if (ch === '\"') { inString = true; result += ch; i++; }
          else if (ch === '/' && text[i+1] === '/') { while (i < text.length && text[i] !== '\n') i++; }
          else if (ch === '/' && text[i+1] === '*') { i+=2; while (i < text.length && !(text[i]==='*' && text[i+1]==='/')) i++; i+=2; }
          else { result += ch; i++; }
        }
      }
      return JSON.parse(result.replace(/,(\s*[}\]])/g, '\$1'));
    }
    var fs = require('fs');
    var raw = fs.readFileSync('${path}', 'utf8');
    parseJsonc(raw);
  " 2>/dev/null; then
    _pass "JSON parses: ${label}"
    return 0
  fi
  _fail "JSON parse error: ${label}"
  return 1
}
