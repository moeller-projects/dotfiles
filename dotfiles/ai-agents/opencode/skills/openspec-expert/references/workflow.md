# OpenSpec Expert Workflow

1. Clarify goal, success criteria, and input type.
2. Generate the spec using the appropriate script.
3. Run governance locally via:
   - validate_spec.sh
   - score_spec.sh
   - enforce_version.sh
   - diff_spec.sh

4. In CI environments, execute ONLY:
   - scripts/ci_gate.sh <spec>

5. ci_gate.sh performs atomic enforcement:
   - openspec validation
   - policy gates
   - quality scoring (>= 80)
   - version governance
   - diff intelligence
   - artifact emission

6. Review artifact.json and gates.json for structured diagnostics.

7. Conduct review and sign-off (Tech lead + QA).

8. Report final output contract.
