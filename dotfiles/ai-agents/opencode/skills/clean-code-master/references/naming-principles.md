# Naming Principles

- Use domain language
- Avoid generic names: Manager, Helper, Utils
- Methods must describe intent, not mechanism
- Avoid boolean flag parameters
- Avoid overloaded names across modules

Violation Example:
processData()

Preferred:
validateInvoiceDraft()