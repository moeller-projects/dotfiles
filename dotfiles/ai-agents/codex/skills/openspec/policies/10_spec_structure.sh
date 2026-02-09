#!/usr/bin/env bash
set -euo pipefail

file="${1:?spec file required}"

# Minimal structure checks; adapt section names to your OpenSpec template if needed.
required=(
  "Overview"
  "Scope"
  "Assumptions"
  "Functional Requirements"
  "Non-Functional Requirements"
  "Acceptance Criteria"
  "Open Questions"
)

for s in "${required[@]}"; do
  grep -qiE "^[#]{1,6}[[:space:]]+$s" "$file" || {
    echo "Policy fail: Missing section header '$s' in $file" >&2
    exit 1
  }
done
