# OpenSpec Expert Workflow

1. Clarify goal, success criteria, and input type.
2. Generate the spec using the appropriate script.
3. Validate with `scripts/validate_spec.sh` and collect results.
4. Run CI/policy gates and record pass/fail.
5. Produce a diff against the prior version and summarize changes.
6. Conduct review and sign-off (Tech lead + QA).
7. Score quality and remediate until score >= 80.
8. Report the final output contract.
