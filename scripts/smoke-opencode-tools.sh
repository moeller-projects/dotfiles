#!/usr/bin/env bash
# scripts/smoke-opencode-tools.sh
#
# Smoke test: verify that the built opencode-tools can be loaded by Node.js.
#
# Usage:
#   bash scripts/smoke-opencode-tools.sh [--dist <path>]
#
# Requires: node >=20

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="${REPO_ROOT}/packages/opencode-tools/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dist) DIST="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ ! -d "$DIST" ]]; then
  echo "FAIL: dist directory not found: ${DIST}"
  echo "      Run: cd packages/opencode-tools && npm run build"
  exit 1
fi

echo "Smoke testing tools in: ${DIST}"
echo ""

PASS=0
FAIL=0

smoke_tool() {
  local name="$1"
  local file="${DIST}/${name}.js"

  if [[ ! -f "$file" ]]; then
    echo "  ✗ ${name}: file not found at ${file}"
    FAIL=$(( FAIL + 1 ))
    return
  fi

  if node --input-type=module \
       -e "import('file://${file}').then(m => {
         if (!m.default) { console.error('no default export'); process.exit(1); }
         process.exit(0);
       }).catch(e => { console.error(e.message); process.exit(1); })" \
       2>/dev/null; then
    echo "  ✓ ${name}: loads and exports default"
    PASS=$(( PASS + 1 ))
  else
    # Capture error for display
    local err
    err="$(node --input-type=module \
       -e "import('file://${file}').then(m => {
         if (!m.default) { console.error('no default export'); process.exit(1); }
         process.exit(0);
       }).catch(e => { console.error(e.message); process.exit(1); })" 2>&1 || true)"
    echo "  ✗ ${name}: load failed — ${err}"
    FAIL=$(( FAIL + 1 ))
  fi
}

smoke_tool "patch-validator"
smoke_tool "analysis-cache"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"

if (( FAIL > 0 )); then
  exit 1
fi
