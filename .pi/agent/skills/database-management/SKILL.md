---
name: database-management
description: Guidelines for creating an maintaining databases
---

## Database Migration Assumptions

- Treat applied migrations as truth: if recorded as applied, assume they ran successfully.
- Do not add defensive migrations for schema already guaranteed by applied migrations.
- Add a new migration only for a real schema change not covered by prior migrations.
- If drift is suspected, inspect the target database first; repair migrations require observed drift.
