#!/usr/bin/env bash
# scripts/validate-skills.sh
#
# Validates SKILL.md files across the repository:
#   - YAML frontmatter is present and parseable
#   - Required fields (name, description) exist
#   - name matches kebab-case convention
#
# Usage:
#   bash scripts/validate-skills.sh [--dir <path>]
#
# Requires: python3, pyyaml

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEARCH_DIR="${REPO_ROOT}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir) SEARCH_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

python3 - "$SEARCH_DIR" <<'PY'
import sys, re
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: pyyaml not installed. Run: pip install pyyaml")
    sys.exit(1)

search_dir = Path(sys.argv[1])
skill_files = sorted(search_dir.glob("**/skills/**/SKILL.md"))

if not skill_files:
    print(f"No SKILL.md files found under {search_dir}")
    sys.exit(0)

errors = []
warnings = []
kebab_re = re.compile(r'^[a-z][a-z0-9-]*$')

for path in skill_files:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    if not lines or lines[0].strip() != "---":
        errors.append(f"{path}: missing YAML frontmatter start '---'")
        continue

    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break

    if end is None:
        errors.append(f"{path}: missing YAML frontmatter closing '---'")
        continue

    fm_text = "\n".join(lines[1:end])
    try:
        fm = yaml.safe_load(fm_text) or {}
    except Exception as e:
        errors.append(f"{path}: YAML parse error: {e}")
        continue

    if not isinstance(fm, dict):
        errors.append(f"{path}: frontmatter must be a YAML mapping")
        continue

    if "name" not in fm:
        errors.append(f"{path}: missing required field 'name'")
    elif not kebab_re.match(str(fm["name"])):
        errors.append(f"{path}: 'name' must be kebab-case, got: {fm['name']!r}")

    if "description" not in fm:
        errors.append(f"{path}: missing required field 'description'")
    elif len(str(fm["description"])) < 20:
        warnings.append(f"{path}: 'description' is very short (<20 chars)")

    meta = fm.get("metadata", {})
    if isinstance(meta, dict):
        if "version" in meta:
            ver = str(meta["version"])
            if not re.match(r'^\d+\.\d+\.\d+$', ver):
                errors.append(f"{path}: metadata.version must be semver (x.y.z), got: {ver!r}")

if warnings:
    print(f"\nWarnings ({len(warnings)}):")
    for w in warnings:
        print(f"  ⚠ {w}")

if errors:
    print(f"\nErrors ({len(errors)}):")
    for e in errors:
        print(f"  ✗ {e}")
    sys.exit(1)

print(f"OK: {len(skill_files)} SKILL.md files validated (0 errors, {len(warnings)} warnings)")
PY
