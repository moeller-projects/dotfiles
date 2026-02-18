#!/usr/bin/env bash
set -euo pipefail

# Deterministic slug for spec names.
# Input: arbitrary text
# Output: lowercase kebab-case, max 64 chars

in="${1:-}"
if [[ -z "$in" ]]; then
  echo "spec"
  exit 0
fi

slug="$(echo "$in" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/<[^>]+>//g' \
  | sed -E 's/[^a-z0-9]+/-/g' \
  | sed -E 's/^-+|-+$//g' \
  | sed -E 's/-+/-/g')"

if [[ -z "$slug" ]]; then
  slug="spec"
fi

echo "${slug:0:64}"
