#!/usr/bin/env python3
import json
import re
import sys

TRIGGERS = [
    "caveman",
    "less tokens",
    "be terse",
    "compress",
    "short answer",
]

IMPLICIT = [
    r"\bdiff\b",
    r"\bpr\b",
    r"\bpull request\b",
    r"\bdebug\b",
    r"\berror\b",
    r"\bstack\b",
    r"\bslow\b",
    r"\bperformance\b",
]

LEVEL_RE = re.compile(r"/caveman\s+(lite|full|ultra)", re.IGNORECASE)


def read():
    try:
        return json.loads(sys.stdin.read())
    except:
        return {}


def get_text(payload):
    for k in ["user_prompt", "prompt", "message", "text"]:
        v = payload.get(k)
        if isinstance(v, str):
            return v
    return ""


def main():
    payload = read()
    text = get_text(payload)
    lower = text.lower()

    active = False
    mode = "full"

    # explicit trigger
    if any(t in lower for t in TRIGGERS):
        active = True

    # implicit trigger
    if not active:
        for p in IMPLICIT:
            if re.search(p, lower):
                active = True
                break

    # level override
    m = LEVEL_RE.search(text)
    if m:
        active = True
        mode = m.group(1).lower()

    # explicit off
    if "stop caveman" in lower or "normal mode" in lower:
        active = False

    output = {"continue": True}

    if active:
        output["systemMessage"] = (
            f"Caveman active (mode={mode}). "
            "Use compressed technical output. "
            "Keep code exact. "
            "Use cause->fix. "
            "Number steps if multi-step. "
            "Use Δ for diffs."
        )

    print(json.dumps(output))


if __name__ == "__main__":
    main()