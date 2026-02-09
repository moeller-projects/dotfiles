#!/usr/bin/env bash
set -euo pipefail

file="${1:?spec file required}"

# Enforce requirement numbering like FR-1, FR-2...
if ! grep -qE '\bFR-[0-9]+' "$file"; then
  echo "Policy fail: No numbered functional requirements (FR-1, FR-2, ...) found in $file" >&2
  exit 1
fi

# Ban vague language (basic pass; extend as needed)
if grep -qiE '\b(should|maybe|might|as needed|etc\.)\b' "$file"; then
  echo "Policy fail: Vague language found (should/maybe/might/as needed/etc.) in $file" >&2
  exit 1
fi
