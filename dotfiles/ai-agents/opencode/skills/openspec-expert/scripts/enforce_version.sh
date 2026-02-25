#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"
source "$HELPERS/ensure_cmd.sh"

"$DIR/ensure_env.sh"
ensure_cmd grep
ensure_cmd sed
ensure_cmd awk

spec="${1:?spec name required}"
base_ref="${2:-HEAD~1}"

spec_file="openspec/specs/$spec/spec.md"
if [[ ! -f "$spec_file" ]]; then
  found="$(find openspec/specs -type f -name 'spec.md' 2>/dev/null | grep -iE "/${spec}/spec\.md$" || true)"
  if [[ -n "$found" ]]; then spec_file="$found"; else err "Cannot find spec file for '$spec'"; exit 1; fi
fi

# We require two explicit metadata lines near the top of the file (first 40 lines):
#   Version: x.y.z
#   Risk Tier: Low|Medium|High|Critical
extract_meta() {
  local key="$1"
  awk -v k="$key" 'NR<=40 { if ($0 ~ "^"k"[[:space:]]*:[[:space:]]*") {sub("^"k"[[:space:]]*:[[:space:]]*",""); print; exit} }' "$spec_file"
}
version_now="$(extract_meta "Version")"
tier_now="$(extract_meta "Risk Tier")"

if [[ -z "$version_now" ]]; then
  echo "Policy fail: Missing 'Version: x.y.z' within first 40 lines of $spec_file" >&2
  exit 1
fi
if ! grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' <<<"$version_now"; then
  echo "Policy fail: Version must be semantic x.y.z, got '$version_now' in $spec_file" >&2
  exit 1
fi
if [[ -z "$tier_now" ]]; then
  echo "Policy fail: Missing 'Risk Tier: Low|Medium|High|Critical' within first 40 lines of $spec_file" >&2
  exit 1
fi
if ! grep -qiE '^(Low|Medium|High|Critical)$' <<<"$tier_now"; then
  echo "Policy fail: Risk Tier must be one of Low/Medium/High/Critical, got '$tier_now' in $spec_file" >&2
  exit 1
fi

# If git is available, enforce version bump when requirements changed.
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Get previous version from base ref (best-effort)
  prev="$(git show "$base_ref":"$spec_file" 2>/dev/null | awk 'NR<=40 { if ($0 ~ "^Version[[:space:]]*:") {sub("^Version[[:space:]]*:[[:space:]]*",""); print; exit} }' || true)"

  # If base ref doesn’t contain version line, skip bump enforcement (but keep metadata required now)
  if [[ -n "$prev" && "$prev" != "$version_now" ]]; then
    log "Version bump detected: $prev -> $version_now"
  fi

  # Determine if FR/AC changed (simple signal)
  diff_sig="$(git diff --unified=0 "$base_ref"...HEAD -- "$spec_file" | grep -E '^[+-].*\b(FR-[0-9]+|AC-[0-9]+)\b' || true)"
  if [[ -n "$diff_sig" ]]; then
    if [[ -n "$prev" && "$prev" == "$version_now" ]]; then
      echo "Policy fail: Requirements/AC changed but Version did not bump (still $version_now). Base was $prev." >&2
      exit 1
    fi
    if [[ -z "$prev" ]]; then
      warn "Cannot read prior Version from git base ref; skipping bump enforcement."
    fi
  fi
fi

log "Version governance PASS: $spec (Version=$version_now, Risk Tier=$tier_now)"