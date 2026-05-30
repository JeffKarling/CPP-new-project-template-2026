# Clang-Tidy State Log

This file contains the logged static analysis warnings that fall into Category B (Situational Design) and Category C (Stylistic Noise). Category A issues are solved in the build pipeline; Category A issues are not allowed and are fixed directly. The purpose of this log is to keep the build console clean while preserving a record of minor static analysis findings.

All static analysis builds are executed using the dedicated CMake `Clang_Tidy` preset.

---

## Developer Elevation Workflow

If a developer reviews these logged findings and decides a warning should be resolved, the following workflow is used to elevate the issue to the active refactor queue:

1. Locate the file and line number of the target warning.
2. Insert an inline comment above the code using the standard `//ATR:` prefix:
   ```cpp
   //ATR: Fix magic number usage in output formatting
   ```
3. Run the tag parser script:
   ```bash
   python3 .agents/parse_tags.py
   ```
4. The tag parser will automatically scan the comment, extract its file context and line number, and elevate it to the active **Codebase Inline Tasks (//ATR)** list in [refactoring_roadmap.md](../.agents/refactoring_roadmap.md).

---

## Logged Category B & C Warnings

The following warnings are preserved for periodic manual inspection:
