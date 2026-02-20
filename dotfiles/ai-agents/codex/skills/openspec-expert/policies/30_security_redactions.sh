#!/usr/bin/env bash
set -euo pipefail

file="${1:?spec file required}"

# Goal: block likely-real secrets, not normal documentation.
# Heuristics:
#  - High-entropy long tokens
#  - Common provider key patterns
#  - "password/token/api_key/secret" assignments with non-placeholder values
#
# Allowed placeholders (case-insensitive):
#   <REDACTED>, <TOKEN>, <PASSWORD>, <API_KEY>, <SECRET>, REDACTED, PLACEHOLDER, XXXX...

is_placeholder() {
  grep -qiE '(<redacted>|<token>|<password>|<api[_-]?key>|<secret>|redacted|placeholder|xxxx+|\*\*\*+|tbd)' <<<"$1"
}

# 1) Provider patterns (best-effort)
if grep -qE '\bAKIA[0-9A-Z]{16}\b' "$file"; then
  echo "Policy fail: Possible AWS access key detected (AKIA...). Use placeholders like <REDACTED>." >&2
  exit 1
fi

# 2) Generic long token-like strings (base64/hex-ish, 32+ chars)
# Exclude markdown headings/code fences detection is complex; keep deterministic and simple.
if grep -qE '[A-Za-z0-9+/_=-]{48,}' "$file"; then
  echo "Policy fail: Possible high-entropy secret/token detected (48+ chars). Use placeholders like <REDACTED>." >&2
  exit 1
fi

# 3) Suspicious assignments: key/value with non-placeholder
# Examples caught:
#   token: eyJ...
#   api_key = abcdef...
#   password = hunter2
while IFS= read -r line; do
  if grep -qiE '\b(password|token|api[_-]?key|secret)\b' <<<"$line" \
     && grep -qE '[:=]' <<<"$line"; then
    # Extract RHS best-effort
    rhs="$(sed -E 's/.*[:=][[:space:]]*//' <<<"$line")"
    # Ignore empty
    if [[ -n "${rhs// /}" ]]; then
      if ! is_placeholder "$rhs"; then
        echo "Policy fail: Possible secret assignment detected. Use placeholders like <REDACTED>." >&2
        echo "Line: $line" >&2
        exit 1
      fi
    fi
  fi
done < <(grep -nE '\b(password|token|api[_-]?key|secret)\b.*[:=]' "$file" | cut -d: -f2- || true)

exit 0