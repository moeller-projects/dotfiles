#!/usr/bin/env bash
# bootstrap/opencode/doctor.sh
#
# Health/verification check for the OpenCode AI agent platform.
#
# Usage:
#   bash bootstrap/opencode/doctor.sh [--json]
#
# Options:
#   --json   Emit a JSON diagnostics report to stdout (suitable for CI)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/opencode/lib/paths.sh
source "${SCRIPT_DIR}/lib/paths.sh"
# shellcheck source=bootstrap/opencode/lib/checks.sh
source "${SCRIPT_DIR}/lib/checks.sh"

JSON_MODE=false
if [[ "${1:-}" == "--json" ]]; then
  JSON_MODE=true
  # In JSON mode, redirect human-readable output to stderr
  exec 3>&1 1>&2
fi

CHECKS_PASSED=0
CHECKS_WARNED=0
CHECKS_FAILED=0
declare -a JSON_RESULTS=()

# record <name> <status:ok|warn|fail> <message> [detail]
record() {
  local name="$1" status="$2" message="$3" detail="${4:-}"
  case "$status" in
    ok)   CHECKS_PASSED=$(( CHECKS_PASSED + 1 )); _pass "${name}: ${message}" ;;
    warn) CHECKS_WARNED=$(( CHECKS_WARNED + 1 )); _warn "${name}: ${message}" ;;
    fail) CHECKS_FAILED=$(( CHECKS_FAILED + 1 )); _fail "${name}: ${message}" ;;
  esac
  if [[ "$JSON_MODE" == "true" ]]; then
    local escaped_detail
    escaped_detail="$(echo -n "$detail" | sed 's/"/\\"/g')"
    JSON_RESULTS+=("{\"name\":\"${name}\",\"status\":\"${status}\",\"message\":\"${message}\",\"detail\":\"${escaped_detail}\"}")
  fi
}

########################################################################
# CONFIG CHECKS
########################################################################
echo ""
echo "── Config ──"

if [[ -f "${OPENCODE_CONFIG_FILE}" ]]; then
  record "config-file" "ok" "opencode.jsonc exists"
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
    var fs=require('fs');
    var raw=fs.readFileSync('${OPENCODE_CONFIG_FILE}','utf8');
    parseJsonc(raw); process.exit(0);
  " 2>/dev/null; then
    record "config-parse" "ok" "opencode.jsonc parses successfully"
  else
    record "config-parse" "fail" "opencode.jsonc has JSON parse errors" \
           "Run: node -e \"require('fs').readFileSync('${OPENCODE_CONFIG_FILE}','utf8')\""
  fi
else
  record "config-file" "warn" "opencode.jsonc not found at ${OPENCODE_CONFIG_FILE}" \
         "Run install.sh after dotfiles are linked"
  record "config-parse" "warn" "skipped (config not found)"
fi

########################################################################
# TOOLS CHECKS
########################################################################
echo ""
echo "── Tools ──"

TOOLS_PKG="${REPO_ROOT}/packages/opencode-tools"
TOOLS_SRC="${OPENCODE_TOOLS_SRC}"
DIST="${TOOLS_PKG}/dist"

if [[ -d "${TOOLS_SRC}" ]]; then
  record "tools-src-dir" "ok" "packages/opencode-tools/src exists"
else
  record "tools-src-dir" "fail" "packages/opencode-tools/src not found" \
         "Expected: ${TOOLS_SRC}"
fi

for tool_name in patch-validator analysis-cache; do
  src_file="${TOOLS_SRC}/${tool_name}.ts"
  if [[ -f "$src_file" ]]; then
    record "tool-src-${tool_name}" "ok" "${tool_name}.ts present in package src"
  else
    record "tool-src-${tool_name}" "fail" "${tool_name}.ts missing from package src" \
           "Expected: ${src_file}"
  fi

  dotfiles_file="${DOTFILES_TOOLS_DIR}/${tool_name}.ts"
  if [[ -f "$dotfiles_file" ]]; then
    record "tool-dotfiles-${tool_name}" "ok" "${tool_name}.ts present in dotfiles/tools"
  else
    record "tool-dotfiles-${tool_name}" "warn" "${tool_name}.ts not in dotfiles/tools (run install.sh)" \
           "Expected: ${dotfiles_file}"
  fi

  dist_file="${DIST}/${tool_name}.js"
  if [[ -f "$dist_file" ]]; then
    record "tool-dist-${tool_name}" "ok" "${tool_name}.js compiled"
  else
    record "tool-dist-${tool_name}" "warn" "${tool_name}.js not built (run: npm run build)" \
           "Expected: ${dist_file}"
  fi
done

# Load test
if [[ -f "${DIST}/patch-validator.js" ]]; then
  if node --input-type=module \
       -e "import('file://${DIST}/patch-validator.js').then(()=>process.exit(0)).catch(()=>process.exit(1))" \
       2>/dev/null; then
    record "tool-load-patch-validator" "ok" "patch-validator loads successfully"
  else
    record "tool-load-patch-validator" "fail" "patch-validator failed to load from dist" \
           "Run: npm run build in packages/opencode-tools"
  fi
else
  record "tool-load-patch-validator" "warn" "load test skipped (dist not built)"
fi

########################################################################
# SKILLS CHECKS
########################################################################
echo ""
echo "── Skills ──"

SKILLS_DIR="${DOTFILES_OPENCODE_DIR}/skills"
if [[ -d "${SKILLS_DIR}" ]]; then
  skill_count=0
  skill_errors=0
  while IFS= read -r -d '' skill_file; do
    skill_count=$(( skill_count + 1 ))
    first_line="$(head -1 "$skill_file" 2>/dev/null || echo "")"
    if [[ "$first_line" != "---" ]]; then
      skill_errors=$(( skill_errors + 1 ))
    fi
  done < <(find "${SKILLS_DIR}" -name "SKILL.md" -print0 2>/dev/null)
  if (( skill_errors == 0 )); then
    record "skills-frontmatter" "ok" "${skill_count} SKILL.md files have valid frontmatter start"
  else
    record "skills-frontmatter" "fail" "${skill_errors}/${skill_count} SKILL.md files missing '---' frontmatter"
  fi
else
  record "skills-dir" "fail" "skills directory not found: ${SKILLS_DIR}"
fi

########################################################################
# AGENTS CHECKS
########################################################################
echo ""
echo "── Agents ──"

AGENTS_DIR="${DOTFILES_OPENCODE_DIR}/agents"
if [[ -d "${AGENTS_DIR}" ]]; then
  agent_count="$(find "${AGENTS_DIR}" -name "*.md" 2>/dev/null | wc -l)"
  record "agents-dir" "ok" "${agent_count} agent definition(s) found"
else
  record "agents-dir" "warn" "agents directory not found: ${AGENTS_DIR}"
fi

AGENTS_MD="${DOTFILES_OPENCODE_DIR}/AGENTS.md"
if [[ -f "${AGENTS_MD}" ]]; then
  record "agents-md" "ok" "AGENTS.md exists"
else
  record "agents-md" "warn" "AGENTS.md not found"
fi

########################################################################
# RUNTIME COMMANDS (node, npm)
########################################################################
echo ""
echo "── Runtime ──"

if command -v node &>/dev/null; then
  node_ver="$(node --version)"
  node_major="$(echo "$node_ver" | sed 's/v//' | cut -d. -f1)"
  if (( node_major >= 20 )); then
    record "runtime-node" "ok" "node ${node_ver}"
  else
    record "runtime-node" "warn" "node ${node_ver} (recommend >=20)"
  fi
else
  record "runtime-node" "fail" "node not found"
fi

if command -v npm &>/dev/null; then
  record "runtime-npm" "ok" "npm $(npm --version)"
else
  record "runtime-npm" "warn" "npm not found"
fi

########################################################################
# SUMMARY / JSON OUTPUT
########################################################################
echo ""
echo "── Summary ──"

OVERALL="ok"
if (( CHECKS_FAILED > 0 )); then OVERALL="fail"
elif (( CHECKS_WARNED > 0 )); then OVERALL="warn"
fi

if [[ "$JSON_MODE" == "true" ]]; then
  joined="$(IFS=,; echo "${JSON_RESULTS[*]}")"
  # Write JSON to original stdout (fd 3)
  echo "{\"tool\":\"opencode-doctor\",\"version\":\"1.0.0\",\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"overall\":\"${OVERALL}\",\"passed\":${CHECKS_PASSED},\"warned\":${CHECKS_WARNED},\"failed\":${CHECKS_FAILED},\"checks\":[${joined}]}" | \
    node -e "process.stdout.write(JSON.stringify(JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')),null,2)+'\n')" >&3
fi

echo "  passed:  ${CHECKS_PASSED}"
echo "  warned:  ${CHECKS_WARNED}"
echo "  failed:  ${CHECKS_FAILED}"
echo "  overall: ${OVERALL}"
echo ""

if [[ "$OVERALL" == "fail" ]]; then
  exit 1
fi
