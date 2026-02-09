#!/usr/bin/env bash
set -euo pipefail

file="${1:?spec file required}"

# Prevent leaking secrets (basic checks; extend with trufflehog/gitleaks in CI if desired)
if grep -qiE '\b(password|apikey|api_key|secret|token)\b' "$file"; then
  echo "Policy fail: Potential secret-related terms found in $file (password/apikey/secret/token)." >&2
  echo "Ensure examples use placeholders like '<REDACTED>'." >&2
  exit 1
fi
