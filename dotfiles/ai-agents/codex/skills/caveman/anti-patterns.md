# Anti-Patterns

## 1. Over-compression

Bad:
`bug fix thing maybe cache`

Good:
`cause: cache miss → DB load`

---

## 2. Missing sequence

Bad:
`validate then DB then cache`

Good:
1. validate
2. cache
3. DB

---

## 3. Missing risk

Bad:
`delete table`

Good:
risk: critical  
impact: data  

---

## 4. False certainty

Bad:
`cause: race condition`

Good:
cause: race condition  
conf: medium  
alt: deadlock  

---

## 5. Abbreviation chaos

Bad:
`svc cfg ctx fn impl dto req`

Good:
`cfg + svc init issue`