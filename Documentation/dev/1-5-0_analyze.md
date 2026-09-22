# v1.5.0 Implementation Analysis

## Change Summary

**Type:** Minor version bump (documentation addition)
**Branch:** `next`
**Tag:** `1.5.0`

## Problem Statement

Seven sanitizer presets were fully implemented in `CMakePresets.json` and
`Cmake/Templates/targetCompileOptions.cmake` (compile flags + linker flags)
but had zero dedicated documentation. The only mention of sanitizers in the
existing docs was a single word in `dual_preset_strategy.md` and a code
comment URL inside the CMake file. Users had no way to discover:

- Which presets exist or what commands to run
- What each sanitizer detects vs. the others
- Why certain flags are present (e.g., `-fno-sanitize-recover`,
  `-fsanitize-memory-track-origins=2`, `-pie/-fPIE`)
- The mutual exclusivity constraint between sanitizers
- How to read and act on sanitizer output
- Which agent role owns sanitizer runs

## Files Changed

| File | Change |
|:---|:---|
| `Documentation/sanitizer_guide.md` | **NEW** — 380-line comprehensive guide |
| `Documentation/README.md` | Added sanitizer bullet to Section 2 architecture list |
| `mkdocs.yml` | Added `sanitizer_guide.md` to nav between Deep Debug and Static Analysis |

## Design Decisions

### Document structure mirrors existing guides
The guide follows the exact structure of `deep_debug_details.md` and
`profiling_guide.md`: numbered sections, tables, code blocks, callout alerts,
agent role section at the end, and cross-references to related docs.

### Three-layer safety net framing
Sanitizers are positioned as Layer 3 in an explicit hierarchy: compiler
warnings (static) → deep debug STL assertions (runtime, library-level) →
sanitizers (runtime, machine-code-level). This makes clear that all three
layers are complementary and should be used independently.

### Flag rationale documented for every non-obvious flag
Each sanitizer section documents *why* non-obvious flags are present, not just
*what* they are. This prevents future maintainers from removing them
accidentally (e.g., removing `-fno-sanitize-recover=undefined` would turn
blocking failures into silent continuations; removing `-pie` from the TSan
preset would cause startup crashes).

### Mutual exclusivity made prominent
An `[!IMPORTANT]` alert is placed directly in Section 2 (Quick Reference)
before the first build command, ensuring it cannot be missed.

### GNU vs. Clang asymmetry documented
The guide notes which sanitizers are Clang-only (MSan, TSan, LSan) and
explains the practical differences between Clang and GNU variants for ASan and
UBSan (e.g., `-fno-sanitize-recover` is Clang-only; GNU UBSan continues after
violations by default; Clang ASan produces richer symbolized output).

## Preset Inventory Verified Against Source

All preset names, configure-preset names, and build-preset names were
cross-verified against `CMakePresets.json` before documenting. All flag
descriptions were cross-verified against
`Cmake/Templates/targetCompileOptions.cmake`.
