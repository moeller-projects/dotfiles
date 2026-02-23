#!/usr/bin/env python3
"""Validate YAML frontmatter in SKILL.md files under the repo.

Checks that each SKILL.md begins with a '---' line, has a closing '---',
and that the content between parses as valid YAML.
"""
from pathlib import Path
import sys
import yaml


def find_skill_files(root: Path):
    return list(root.glob("**/skills/**/SKILL.md"))


def validate_file(path: Path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines:
        return f"{path}: empty file"
    if lines[0].strip() != "---":
        return f"{path}: missing YAML frontmatter start '---'"

    end = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            end = i
            break
    if end is None:
        return f"{path}: missing YAML frontmatter closing '---'"

    fm = "\n".join(lines[1:end])
    try:
        yaml.safe_load(fm)
    except Exception as e:
        return f"{path}: YAML parse error: {e}"

    return None


def main():
    root = Path(__file__).resolve().parents[2]
    files = find_skill_files(root)
    if not files:
        print("No SKILL.md files found; nothing to validate.")
        return 0

    errors = []
    for f in sorted(files):
        err = validate_file(f)
        if err:
            errors.append(err)

    if errors:
        print("Frontmatter validation failed for the following files:")
        for e in errors:
            print("- ", e)
        return 2

    print(f"All {len(files)} SKILL.md files have valid YAML frontmatter")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
