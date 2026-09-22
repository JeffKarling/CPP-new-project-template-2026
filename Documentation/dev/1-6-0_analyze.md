# v1.6.0 Architecture Analysis

**Date**: 2026-09-22
**Branch**: `next`
**Tag**: `1.6.0`

---

## Change: Promote Intel VTune & Advisor to First-Class Documentation Status

### Problem Statement

The `Documentation/README.md` and `.github/README.md` section 2 architecture overview
contained a single generic bullet:

> **Profiling & Performance Engineering**: Hardware-level performance analysis is critical...

This bullet provided no indication that the project contains:
- Two dedicated CMake modules: `OneApi_Vtune.cmake` and `OneApi_Advisor.cmake`
- Four custom CMake IDE targets: `Vtune_collect`, `Vtune_gui`, `Advisor_collect`, `Advisor_gui`
- Intel ITT API instrumentation compiled into the binary via `ENABLE_ITT` (auto-set in `OneApi_Custom_RelWithDebInfo`)
- A Systemd transient user service workflow (`vtune-web.service`) for Wayland-compatible VTune web GUI
- Roofline Model analysis with arithmetic intensity (OP/Byte) and GFLOPS measurement via Advisor

A developer reading the architecture overview would never know that VTune, Advisor, and ITT
are integrated at the build system level — not just external tools.

### Decision: Split into Two Bullets

The existing bullet is split into two architecturally distinct entries:

| Bullet | Scope | CMake Mechanism |
| :--- | :--- | :--- |
| **Linux `perf` Profiling** | Hardware counter CLI analysis; `Perf`, `Perf_multithread`, `Perf_record`, `Perf_report` | Custom targets via `perf` system binary |
| **Intel VTune & Advisor Integration** | Threading analysis, Roofline Model, ITT hot-path isolation | `OneApi_Vtune.cmake`, `OneApi_Advisor.cmake`, `ENABLE_ITT` |

This follows the same precedent established when **Deep Debug Diagnostics** and **Sanitizer Usage**
were separated into independent bullets despite both relating to "runtime error detection".

### Files Changed

| File | Change |
| :--- | :--- |
| `Documentation/README.md` | Replaced single Profiling bullet with two: `linux perf` + Intel VTune & Advisor |
| `.github/README.md` | Same split, using `../Documentation/` relative link paths |
| `mkdocs.yml` | Split single nav entry into two matching the README bullets |
| `CMakeLists.txt` | Version bumped 1.4.6 → 1.6.0 (also corrects gap: file was behind tags at 1.5.0) |

### Version Note

`CMakeLists.txt` was at `1.4.6` while the latest git tag was `1.5.0`. This was a gap introduced
when v1.5.0 (sanitizer guide) was tagged without bumping the file. This release corrects the gap
by setting the file to `1.6.0`, bringing it in sync with and ahead of the tag sequence.
