# Production Artifacts

The `production_artifacts/` directory is the dedicated space for storing production-ready artifacts, compiler-verified build schemas, static documentation outputs, and serialized database files.

## Layout

- **[build_all.sh](../production_artifacts/build_all.sh)**: Cross-compiler verification shell runner.
- **[clang_tidy_state.md](../production_artifacts/clang_tidy_state.md)**: Warning classification and static analysis tracking log.

---

## Integrated Output Control

Our application entrypoint automatically verifies workspace configuration. If `production_artifacts/` is present or can be initialized, all database serialization outputs (specifically `template_database.pb`) are redirected here rather than cluttering the repository root.

This enforces clean project structure and repository hygiene.

