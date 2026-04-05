#!/usr/bin/env python3
"""Validate YAML frontmatter in SKILL.md files under the repo.

Checks that each SKILL.md begins with a '---' line, has a closing '---',
that the content between parses as valid YAML, and that the frontmatter
conforms to schemas/skill-metadata.schema.json.
"""
import json
from pathlib import Path
import sys
import yaml

try:
    import jsonschema
except ImportError:
    print("ERROR: jsonschema not installed. Run: pip install jsonschema")
    sys.exit(1)


def find_skill_files(root: Path):
    return list(root.glob("**/skills/**/SKILL.md"))


def load_schema(root: Path):
    schema_path = root / "schemas" / "skill-metadata.schema.json"
    return json.loads(schema_path.read_text(encoding="utf-8"))


def validate_file(path: Path, schema: dict):
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
        data = yaml.safe_load(fm)
    except Exception as e:
        return f"{path}: YAML parse error: {e}"

    try:
        jsonschema.validate(data, schema)
    except jsonschema.ValidationError as e:
        return f"{path}: schema validation error: {e.message}"

    return None


def main():
    root = Path(__file__).resolve().parents[2]
    files = find_skill_files(root)
    if not files:
        print("No SKILL.md files found; nothing to validate.")
        return 0

    schema = load_schema(root)

    errors = []
    for f in sorted(files):
        err = validate_file(f, schema)
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
