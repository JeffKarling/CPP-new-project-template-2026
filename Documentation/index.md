## 1. Project Overview

`template2026` is my c++ template when starting new projects.

## 2. Installation and Building

I use Fedora Linux, it is not tested anywhere else but i dont see why it should not work other linux distributions.
Project relies on modern compiler features and standard package libraries. Project is setup to use OneApi profiling tools, so its recommended to have OneApi installed.

### Requirements:
- Compilers GCC 11+, Clang 13+ and oneAPI ICPX 2023+
- Google Protobuf library.
- Intel oneAPI Threading Building Blocks (TBB).
- Google gtest for testing.

### Compilation Steps:
The project has Cmake presets for all three above compilers. To execute a build using all compilers, Run the preset build workflow helper script from the production_artifacts directory:
```bash
# To build custom machine configurations in release mode:
./build_all.sh custom release

# To build standard machine configurations in debug mode:
./build_all.sh default debug
```
## 1. Usage Guide

## 2. Advanced Debugging & Profiling

The system features profiling and debugging support integrated directly into CMake and CLion:
* **Deep Debug Profiles**: Custom configurations (`GNU_Custom_Debug_Deep` / `Clang_Custom_Debug_Deep`) using extensive standard-library safety containers and safe-iterators to catch silent memory bugs.
* **Low-Noise VTune Tracking**: ITT API integration that isolates TBB Flow Graph execution, pausing database initialization and serialization overhead.
* **One-Click Profiling Targets**: Custom targets (`Perf`, `Perf_record`, `Vtune_collect`, `Advisor_collect`) to run automated profiles and record reports inside `production_artifacts/profiling/`.

For complete details on configuring, running, and analyzing performance reports, see the **[Advanced Debugging & Profiling Guide](profiling_guide.md)**.

