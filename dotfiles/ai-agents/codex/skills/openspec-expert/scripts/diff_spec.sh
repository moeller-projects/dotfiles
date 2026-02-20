#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"
source "$HELPERS/log.sh"
source "$HELPERS/ensure_cmd.sh"

"$DIR/ensure_env.sh"

spec="${1:?spec name required}"
base_ref="${2:-HEAD~1}"

spec_file="openspec/specs/$spec/spec.md"
if [[ ! -f "$spec_file" ]]; then
  found="$(find openspec/specs -type f -name 'spec.md' 2>/dev/null | grep -iE "/${spec}/spec\.md$" || true)"
  if [[ -n "$found" ]]; then spec_file="$found"; else err "Cannot find spec file for '$spec'"; exit 1; fi
fi

empty_diff() {
  jq -n --arg spec "$spec" --arg file "$spec_file" --arg base "$base_ref" '
    {
      spec_name:$spec,
      spec_file:$file,
      base_ref:$base,
      diff_available:false,
      semantic_change_detected:false,
      added:{fr:[],ac:[]},
      removed:{fr:[],ac:[]},
      modified:{fr:[],ac:[]}
    }'
}

if ! command -v git >/dev/null 2>&1; then
  warn "git not found; emitting empty diff summary"
  empty_diff
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  warn "not a git repo; emitting empty diff summary"
  empty_diff
  exit 0
fi

# Get unified diff for spec file only (deterministic settings)
diff="$(git diff --unified=0 "$base_ref"...HEAD -- "$spec_file" || true)"

# Extract added/removed FR/AC IDs from diff lines
added_fr="$(printf '%s' "$diff" | grep -E '^\+.*\bFR-[0-9]+\b' | grep -Eo '\bFR-[0-9]+\b' | sort -u || true)"
removed_fr="$(printf '%s' "$diff" | grep -E '^-.*\bFR-[0-9]+\b' | grep -Eo '\bFR-[0-9]+\b' | sort -u || true)"
added_ac="$(printf '%s' "$diff" | grep -E '^\+.*\bAC-[0-9]+\b' | grep -Eo '\bAC-[0-9]+\b' | sort -u || true)"
removed_ac="$(printf '%s' "$diff" | grep -E '^-.*\bAC-[0-9]+\b' | grep -Eo '\bAC-[0-9]+\b' | sort -u || true)"

# "Modified" = appears in both added and removed sets (same ID)
modified_fr="$(comm -12 <(printf '%s\n' $added_fr | sort) <(printf '%s\n' $removed_fr | sort) || true)"
modified_ac="$(comm -12 <(printf '%s\n' $added_ac | sort) <(printf '%s\n' $removed_ac | sort) || true)"

# Remove modified IDs from added/removed lists
final_added_fr="$(comm -23 <(printf '%s\n' $added_fr | sort) <(printf '%s\n' $modified_fr | sort) || true)"
final_removed_fr="$(comm -23 <(printf '%s\n' $removed_fr | sort) <(printf '%s\n' $modified_fr | sort) || true)"
final_added_ac="$(comm -23 <(printf '%s\n' $added_ac | sort) <(printf '%s\n' $modified_ac | sort) || true)"
final_removed_ac="$(comm -23 <(printf '%s\n' $removed_ac | sort) <(printf '%s\n' $modified_ac | sort) || true)"

to_json_array() { printf '%s\n' "$1" | sed '/^\s*$/d' | jq -R . | jq -s .; }

# Semantic change signal (beyond ID add/remove):
# Any +/- line touching spec content that does NOT merely add/remove the same ID-only token.
semantic_change="false"
if grep -qE '^[+-](?!\+\+\+|---).*[A-Za-z0-9]' <<<"$diff"; then
  # If there are any changed lines besides headers, we consider semantic change possible.
  # This is intentionally conservative.
  semantic_change="true"
fi

jq -n \
  --arg spec "$spec" \
  --arg file "$spec_file" \
  --arg base "$base_ref" \
  --arg semantic "$semantic_change" \
  --argjson added_fr "$(to_json_array "$final_added_fr")" \
  --argjson removed_fr "$(to_json_array "$final_removed_fr")" \
  --argjson modified_fr "$(to_json_array "$modified_fr")" \
  --argjson added_ac "$(to_json_array "$final_added_ac")" \
  --argjson removed_ac "$(to_json_array "$final_removed_ac")" \
  --argjson modified_ac "$(to_json_array "$modified_ac")" \
'
{
  spec_name: $spec,
  spec_file: $file,
  base_ref: $base,
  diff_available: true,
  semantic_change_detected: ($semantic == "true"),
  added: { fr: $added_fr, ac: $added_ac },
  removed: { fr: $removed_fr, ac: $removed_ac },
  modified: { fr: $modified_fr, ac: $modified_ac }
}
'