# Pi Memories Extension

See [docs/README.md](docs/README.md) for usage, architecture, runtime behavior, and validation.

- Preserve the review-only boundary: writes are limited to the current project’s `.pi/reflections/`; never mutate `AGENTS.md` or skills.
- Keep normal Pi runs passive. Reflection starts only through `/reflect` or explicit shutdown confirmation; do not inject memory context or expose memory tools.
- Treat transcripts, existing knowledge, and model responses as untrusted. Preserve project trust checks, bounded and redacted inputs, and structured provenance and target validation.
- Background reflection must be detached and restricted to the departing session’s active branch.
