#!/usr/bin/env bash
set -euo pipefail

ts() { date +"%Y-%m-%dT%H:%M:%S%z"; }
log() { echo "[deep-research][$(ts)] $*"; }
warn(){ echo "[deep-research][$(ts)][WARN] $*" >&2; }
err() { echo "[deep-research][$(ts)][ERROR] $*" >&2; }
