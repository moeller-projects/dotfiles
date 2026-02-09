#!/usr/bin/env bash
set -euo pipefail

ts() { date +"%Y-%m-%dT%H:%M:%S%z"; }
log() { echo "[openspec][$(ts)] $*"; }
warn(){ echo "[openspec][$(ts)][WARN] $*" >&2; }
err() { echo "[openspec][$(ts)][ERROR] $*" >&2; }
