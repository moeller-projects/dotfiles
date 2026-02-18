#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
HELPERS="$DIR/../helpers"

source "$HELPERS/ensure_cmd.sh"
source "$HELPERS/log.sh"

ensure_cmd bash
ensure_cmd jq
ensure_cmd curl
ensure_cmd openspec

log "Environment OK"
