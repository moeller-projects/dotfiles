# Dependency Direction

Rules:
- Core domain must not depend on infrastructure
- UI must not contain business rules
- Infrastructure depends inward
- High-level modules must not depend on low-level details

Detect:
- Domain referencing database client directly
- Business logic referencing HTTP client