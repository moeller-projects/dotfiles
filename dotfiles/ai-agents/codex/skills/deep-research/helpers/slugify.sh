#!/usr/bin/env bash
set -euo pipefail

in="${1:-}"
slug="$(echo "$in" \
  | tr '[:upper:]' '[:lower:]' \
  | sed -E 's/[^a-z0-9]+/-/g' \
  | sed -E 's/^-+|-+$//g' \
  | sed -E 's/-+/-/g')"
echo "${slug:0:48}"
