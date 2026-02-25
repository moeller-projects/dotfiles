# Layering

Typical Clean Structure:

Presentation
Application
Domain
Infrastructure

Violations:
- Infrastructure logic in Domain
- Domain referencing framework types
- Cross-layer imports skipping levels