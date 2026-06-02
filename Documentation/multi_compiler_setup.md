# Multi-Compiler Setup & Verification Guide

This guide details how to build, run, and verify the `template2026` codebase across multiple compiler suites sequentially. 

---

## 1. Technical Architecture, The How

To make multi-compiler builds frictionless, the template provides a two-layered automation structure:

1. **CMake Workflow Presets (`CMakePresets.json`)**: Configures, builds, and runs the test harness (`ctest`) as a single, unified pipeline step for a specific toolchain.
2. **Verification Runner Script (`production_artifacts/build_all.sh`)**: A bash script that orchestrates the execution of these workflow presets across all three supported compilers.

### Why the Script Wrapper is Required
While CMake 3.25+ Workflow Presets allow chaining steps (Configure -> Build -> Test), **CMake restricts a single workflow preset to a single active toolchain configuration**. 

In professional C++ projects, developers must verify code changes across multiple distinct compiler suites (GNU, Clang, oneAPI) to catch compiler-specific quirks, linker behaviors, and standard library differences. Because CMake cannot natively execute a sequence of workflow presets that span different compilers, the wrapper script (`build_all.sh`) is used. It:

* Manages path environments and overrides.
* Runs verification workflows sequentially.
* Gracefully handles expected quirks (such as Clang ABI link issues with static libraries when using certain standard library configurations).

---

## 2. Compilation Strategy, Default vs. Custom Build Types

The build presets inside `CMakePresets.json` are divided into two primary categories to balance portable distribution with optimal local performance:

### A. Default Presets, System-Neutral
Designed for distribution, package maintainers, and general users:

* **Optimization**: Standard compiler optimization flags (e.g., `-O2` or `-O3`) without CPU-specific extensions.
* **Compatibility**: Guarantees system-neutral binaries that run across any x86-64 target architecture.
* **Usage**: Ideal for continuous integration (CI) servers and releasing portable binary archives.

### B. Custom Presets, Machine-Tuned
Designed for local active development and high-performance profiling:

* **Optimization**: Includes `-march=native` (or compiler-specific equivalents) to utilize all instruction sets available on your local CPU (such as AVX-512, FMA, and BMI).
* **Profiling Support**: Integrates debug symbols (`-g`) alongside optimizations and enables optional features like the Intel ITT API for low-noise profiling.
* **Usage**: Used during local hot-path micro-benchmarking, VTune analysis, and loop vectorization studies.

---

## 3. Practical CLI Commands

All compilation and testing workflows are executed from the repository root.

### Running the Orchestrated Verification Script
The `build_all.sh` script automates full verification (GNU GCC -> Intel oneAPI -> LLVM Clang). It takes two optional parameters:
`./production_artifacts/build_all.sh [preset_type] [build_mode]`

```bash
# Verify local custom machine configurations in debug mode:
./production_artifacts/build_all.sh custom debug

# Verify standard portable configurations in release mode:
./production_artifacts/build_all.sh default release

# Verify local configurations under maximum diagnostic assertions (Deep Debug):
./production_artifacts/build_all.sh custom deep
```

### Manual Individual Workflow Presets
To work on a single compiler suite, run individual workflows directly via CMake:

```bash
# Run the complete GNU custom release verification pipeline:
cmake --workflow --preset GNU_Custom_Release_Verify

# Run the Clang default debug verification pipeline:
cmake --workflow --preset Clang_Default_Debug_Verify

# Run the Intel oneAPI custom RelWithDebInfo pipeline:
cmake --workflow --preset OneApi_Custom_RelWithDebInfo_Verify
```

---

## 4. Compiler Integration & Behavior

The script sequentially invokes the following compiler frontends:

1. **GNU Compiler Collection (`g++`)**: Acts as the baseline validator. Runs first to ensure standard conformance.
2. **Intel oneAPI Compiler (`icpx`)**: Optimized frontend for Intel hardware architectures. Executes second to generate optimization reports and register low-noise profiling. *(Note: skipped in Deep Debug mode).*
3. **LLVM Clang Compiler (`clang++`)**: Executes third. The script is configured to run Clang with error tolerance during linking (`ignore_errors=true`) to gracefully handle ABI compatibility constraints while still capturing Clang's static warnings.
