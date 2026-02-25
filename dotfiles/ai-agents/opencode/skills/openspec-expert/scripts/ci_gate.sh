#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

spec="${1:?spec name required}"
base_ref="${2:-HEAD~1}"

# 1) Validate (openspec + policies)
"$DIR/validate_spec.sh" "$spec"

# 2) Score threshold
score_json="$("$DIR/score_spec.sh" "$spec")"
score="$(jq -r '.total_score' <<<"$score_json")"
if (( score < 80 )); then
  echo "CI FAIL: quality score $score < 80" >&2
  echo "$score_json" >&2
  exit 1
fi

# 3) Version governance
"$DIR/enforce_version.sh" "$spec" "$base_ref"

# 4) Diff must be available in CI contexts (best-effort: only fail if git is present & repo)
# diff_spec already handles non-git environments gracefully.
diff_json="$("$DIR/diff_spec.sh" "$spec" "$base_ref")"
diff_available="$(jq -r '.diff_available' <<<"$diff_json")"
if [[ "$diff_available" != "true" ]]; then
  echo "CI WARN: diff unavailable (non-git environment). Continuing." >&2
fi

# 5) Emit artifact (optional but useful in CI)
"$DIR/emit_artifact.sh" "$spec" "$base_ref" >/dev/null

echo "CI PASS: $spec (score=$score)"