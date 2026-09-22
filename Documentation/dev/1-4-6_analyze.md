# v1.4.6 Patch — `targetCompileOptions.cmake` Audit & Fix

**Date**: 2026-07-08  
**Branch**: `next`  
**Tag**: `1.4.6`  
**Files changed**: `Cmake/Templates/targetCompileOptions.cmake`, `CMakePresets.json`, `CMakeLists.txt`

## Background

A human reviewer flagged that `targetCompileOptions.cmake` contained multiple errors without specifying what they were. A full cross-reference audit was performed against `CMakePresets.json` build types and the project documentation (`dual_preset_strategy.md`, `deep_debug_details.md`, `symmetry_principle.md`).

---

## Issues Found & Fixed

### Critical Bugs (5 fixed)

| # | Location | Issue | Fix Applied |
|---|----------|-------|-------------|
| 1 | L25, L60 | `$<CONFIG:Clang_tidy>` — lowercase `t` never matches preset `"Clang_Tidy"` (CONFIG is case-sensitive on Linux) | Renamed to `Clang_Tidy` in both definitions and compile options blocks |
| 2 | L108–110 | OneApi `target_link_options` block had `Clang_Debug/Clang_Release/Clang_RelWithDebInfo` instead of `OneApi_*` config names | Corrected to `OneApi_Debug`, `OneApi_Release`, `OneApi_RelWithDebInfo` |
| 3 | L64 | `Clang_MemSan` compile options missing `-fsanitize=memory` — sanitizer requires compile-time instrumentation of every TU | Added `-fsanitize=memory -fsanitize-memory-track-origins=2` to compile options |
| 4 | L65 | `Clang_ThreadSan` compile options missing `-fsanitize=thread` | Added `-fsanitize=thread` to compile options |
| 5 | L67 | `Clang_LeakSan` compile options missing `-fsanitize=leak` and `-fPIE` | Added `-fsanitize=leak -fPIE` to compile options |

### Correctness Issues (5 fixed)

| # | Location | Issue | Fix Applied |
|---|----------|-------|-------------|
| 6 | L117 | `Clang_LeakSan` link options had `-fPIE` (compile flag) instead of `-pie` (link flag) | Changed link option to `-pie` |
| 7 | L113 | `Clang_UBSan` link options had `-fsanitize-trap=all` which silences human-readable UBSan reports | Replaced with `-fno-sanitize-recover=undefined` |
| 8 | L72 | `GNU_Debug` missing `-Wpedantic` — asymmetric with Clang_Debug and OneApi_Debug | Added `-Wpedantic` |
| 9 | L76 | `GNU_Debug_Deep` missing `-Wpedantic` | Added `-Wpedantic` |
| 10 | Presets L718 | Workflow `GNU_Custom_AddressSan_Verify` build step referenced `"GNU_Custom_AddressSanitizer"` (non-existent) | Fixed to `"GNU_Custom_AddressSan"` |

### Observations (deferred to user decision)

| # | Issue | Rationale for deferral |
|---|-------|----------------------|
| 11 | `GNU_RelWithDebInfo` uses `-O2` instead of `-O3 -ffast-math` like Clang's profiling build | May be intentional profiling philosophy difference |
| 12 | `-fstack-protector-strong` only on `Clang_Release`, not GNU/OneApi Release | Requires user hardening policy decision |
| 13 | `OneApi_Debug` has no hardening macros unlike Clang/GNU | Left for user decision |

---

## Key Technical Decisions

### Sanitizer Flags Must Appear in Both Compile AND Link Options
All sanitizers (MemSan, ThreadSan, AddressSan, LeakSan, UBSan) require `-fsanitize=*` to be passed at compile time (TU instrumentation) AND at link time (runtime pull-in). Having it only in link options produces a silently non-functional sanitizer binary.

### `-fsanitize-trap=all` vs `-fno-sanitize-recover=undefined`
`-fsanitize-trap=all` causes UBSan to emit a `ud2` trap with no diagnostic message. Replaced with `-fno-sanitize-recover=undefined` which halts execution but still prints the UBSan human-readable report.

### `-fPIE` vs `-pie`
- `-fPIE` is a **compile flag** (generate position-independent code for executables)
- `-pie` is a **link flag** (mark output as PIE executable)
Both are needed. `-fPIE` goes in compile options; `-pie` goes in link options.

---

## Verification

```bash
./production_artifacts/build_all.sh custom debug
```
