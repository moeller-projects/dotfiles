# Complexity Metrics

## Cyclomatic Complexity

Definition:
Number of independent execution paths.

Calculation:
+1 per:
- if / else if
- switch case
- for / while
- catch
- logical operators (&&, ||)
- ternary operator

Thresholds:
1–5 Low
6–10 Medium
11–15 High
16+ Critical

—

## Cognitive Complexity

Penalizes:
- nested control flow
- recursion
- multiple conditionals in same block
- deeply nested logic

Add +1 per nesting level beyond 1.

—

## Nesting Depth

Depth >3 is high risk.
Depth >4 critical.

—

## Public Surface Area

Count of:
- public methods
- exported functions
- external API endpoints

>15 Warning
>30 High Risk