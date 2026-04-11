# Caveman Skill

Ultra-compressed communication protocol for coding agents and engineers.

## Purpose

Reduce token usage while preserving:
- correctness
- clarity
- safety

## When to Use

- debugging
- PR summaries
- architecture discussions
- agent-to-agent communication
- performance analysis

## When NOT to Use

- user-facing communication
- documentation
- onboarding explanations
- critical instructions without clarity

## Modes

- lite → readable
- full → balanced
- ultra → max compression

## Key Concepts

- **Δ (delta mode)** → describe change, not whole system
- **ctx anchor** → prevent drift
- **risk + conf** → avoid wrong decisions
- **numbered steps** → deterministic execution

## File Structure

- `SKILL.md` → core rules (loaded by agent)
- `examples.md` → patterns
- `evals.md` → validation prompts
- `anti-patterns.md` → what to avoid

## Usage

Trigger manually:
```

/caveman
/caveman ultra

```

Or naturally:
- "be terse"
- "less tokens"
- "compress output"

## Design Philosophy

Caveman is not style.  
Caveman is protocol.

Goal:
> maximum signal, minimum tokens

## Future Improvements

- machine-readable mode (JSON)
- abbreviation registry
- auto template selection engine
- CI evaluation integration