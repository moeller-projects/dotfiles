#!/usr/bin/env bash
# bootstrap/opencode/install.sh
#
# Bootstrap installer for the OpenCode AI agent platform.
#
# Usage:
#   bash bootstrap/opencode/install.sh [--dry-run]
#
# Stages:
#   1. preflight  — verify required tools and paths
#   2. sync       — copy tool sources to dotfiles tools dir
#   3. build      — compile TypeScript package
#   4. deploy     — link/copy artifacts to live OpenCode config
#   5. validate   — basic JSON config validation
#   6. smoke      — verify at least one tool is loadable
#   7. summary    — print results

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=bootstrap/opencode/lib/paths.sh
source "${SCRIPT_DIR}/lib/paths.sh"
# shellcheck source=bootstrap/opencode/lib/checks.sh
source "${SCRIPT_DIR}/lib/checks.sh"
# shellcheck source=bootstrap/opencode/lib/config.sh
source "${SCRIPT_DIR}/lib/config.sh"

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[dry-run] No changes will be made."
fi

STAGE_FAILED=false
STAGE_ERRORS=()

stage() {
  echo ""
  echo "── Stage $1: $2 ──"
}

fail_stage() {
  STAGE_FAILED=true
  STAGE_ERRORS+=("$1")
  echo ""
  echo "ERROR: Stage failed — $1"
  echo "       $2"
}

########################################################################
# STAGE 1 — PREFLIGHT
########################################################################
stage 1 "preflight"

check_node_version 20             || fail_stage "preflight" "Node.js >=20 required"
check_command npm                 || fail_stage "preflight" "npm required to build tools"
check_command jq      "true"      # optional — used by install.sh
check_dir_exists "${REPO_ROOT}/packages/opencode-tools" "packages/opencode-tools" \
                                  || fail_stage "preflight" "packages/opencode-tools not found"

if [[ "$STAGE_FAILED" == "true" ]]; then
  echo ""
  echo "Preflight failed. Resolve the issues above and re-run."
  exit 1
fi

########################################################################
# STAGE 2 — SYNC SOURCE TO DOTFILES TOOLS DIR
########################################################################
stage 2 "sync tool sources"

TOOLS_SRC="${OPENCODE_TOOLS_SRC}"
TOOLS_DEST="${DOTFILES_TOOLS_DIR}"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "  [dry-run] would sync: ${TOOLS_SRC}/*.ts → ${TOOLS_DEST}/"
else
  mkdir -p "${TOOLS_DEST}"
  for ts_file in "${TOOLS_SRC}"/*.ts; do
    [[ -f "$ts_file" ]] || continue
    dest="${TOOLS_DEST}/$(basename "$ts_file")"
    if [[ -f "$dest" ]]; then
      if cmp -s "$ts_file" "$dest"; then
        echo "  up-to-date: $(basename "$ts_file")"
        continue
      fi
      backup_file "$dest"
    fi
    cp "$ts_file" "$dest"
    echo "  synced: $(basename "$ts_file")"
  done
fi

########################################################################
# STAGE 3 — BUILD TYPESCRIPT PACKAGE
########################################################################
stage 3 "build tools package"

TOOLS_PKG="${REPO_ROOT}/packages/opencode-tools"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "  [dry-run] would run: npm install && npm run build (in ${TOOLS_PKG})"
else
  (
    cd "${TOOLS_PKG}"
    echo "  installing dependencies..."
    npm install --prefer-offline --silent 2>&1 | tail -3 || true
    echo "  compiling TypeScript..."
    npm run build
    echo "  build complete: dist/ generated"
  ) || fail_stage "build" "TypeScript compilation failed — run 'npm run lint' in packages/opencode-tools for details"
fi

########################################################################
# STAGE 4 — VALIDATE CONFIG
########################################################################
stage 4 "validate config"

if [[ -f "${OPENCODE_CONFIG_FILE}" ]]; then
  check_json_parse "${OPENCODE_CONFIG_FILE}" "opencode.jsonc" \
    || _warn "config parse failed — manual review recommended"
else
  _warn "opencode.jsonc not found at ${OPENCODE_CONFIG_FILE} (run install.sh after dotfiles install)"
fi

########################################################################
# STAGE 5 — SMOKE TEST (verify tools loadable)
########################################################################
stage 5 "smoke"

DIST="${TOOLS_PKG}/dist"

if [[ -d "$DIST" ]]; then
  if [[ -f "${DIST}/patch-validator.js" ]]; then
    if node --input-type=module \
         -e "import('file://${DIST}/patch-validator.js').then(() => process.exit(0)).catch(() => process.exit(1))" \
         2>/dev/null; then
      _pass "smoke: patch-validator loads"
    else
      _fail "smoke: patch-validator failed to load"
      STAGE_ERRORS+=("smoke: patch-validator")
    fi
  else
    _warn "smoke: dist/patch-validator.js not found (build may not have run)"
  fi
else
  _warn "smoke: dist/ not found — skipping load test"
fi

########################################################################
# STAGE 6 — SUMMARY
########################################################################
stage 6 "summary"
echo ""

if [[ ${#STAGE_ERRORS[@]} -gt 0 ]]; then
  echo "Install completed with errors:"
  for e in "${STAGE_ERRORS[@]}"; do
    echo "  ✗ $e"
  done
  echo ""
  echo "Run doctor to get a full health report:"
  echo "  bash bootstrap/opencode/doctor.sh"
  exit 1
fi

echo "  ✓ opencode-tools package built"
echo "  ✓ tool sources synced to dotfiles"
echo ""
echo "Next steps:"
echo "  1. Run install.sh to link dotfiles:  bash install.sh"
echo "  2. Run doctor to verify:             bash bootstrap/opencode/doctor.sh"
