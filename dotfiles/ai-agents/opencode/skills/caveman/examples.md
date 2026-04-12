# Examples

## React re-render

lite:
Your component re-renders because a new object reference is created each render. Use useMemo.

full:
New object ref each render → re-render. Use useMemo.

ultra:
new ref → re-render → useMemo

---

## DB pooling

full:
Pool reuse DB connections. No new conn per req. Skip handshake.

ultra:
pool reuse conn → no handshake → faster

---

## Debugging

ctx: auth middleware  
issue: expired tokens pass  
cause: `<` instead of `<=`  
fix: change operator  
risk: low  
conf: high  
next: add test  

---

## PR summary

Δ:
- sync HTTP call
+ async await
→ less blocking

risk: medium  
tests: timeout + retry  

---

## Performance

hotspot: query  
cause: no index  
Δ: add index(user_id)  
expected: O(n) → O(log n)  
risk: low