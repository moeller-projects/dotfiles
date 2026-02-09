#!/usr/bin/env bash
set -euo pipefail

cmd="$1"
if ! command -v "$cmd" >/dev/null 2>&1; then
  echo "Missing required command: $cmd" >&2
  exit 1
fi
