# Dual-Preset Compilation Strategy

The build system utilizes a dual-preset configuration scheme inside [CMakePresets.json](file:///home/ello/CLionProjects/template2026/CMakePresets.json) to manage compilation targets. This strategy balances developer requirements with downstream consumer portability.

---

## 1. The Core Strategy

C++ projects often face a conflict in compiler flag configuration:
* **Developer Requirements**: Developers require maximum compilation diagnostics, automated static analysis (Clang-Tidy), sanitizers, and aggressive machine-specific instruction optimizations (`-march=native`) to profile parallel performance on host CPU hardware.
* **Consumer Portability**: External open-source consumers and package maintainers require neutral, unopinionated builds that compile on generic architectures without hardcoded compiler choices, specific standard-library hardening flags, or localized CPU optimizations.

The project solves this by defining two separate classes of build presets:

```
                  ┌───────────────────────────────┐
                  │      Developer Code Change    │
                  └───────────────┬───────────────┘
                                  │
                  ┌───────────────┴───────────────┐
                  │   Double-Verification Cycle   │
                  └──────┬─────────────────┬──────┘
                         │                 │
         ┌───────────────┴───────┐ ┌───────┴───────────────┐
         │ Custom Presets        │ │ Default Presets       │
         │ (Active Development)  │ │ (Distribution Phase)  │
         ├───────────────────────┤ ├───────────────────────┤
         │ • -march=native       │ │ • No custom flags     │
         │ • Maximum warnings    │ │ • Standard build type │
         │ • Target diagnostics  │ │ • Portable binaries   │
         └───────────────┬───────┘ └───────┬───────────────┘
                         │                 │
                         └────────┬────────┘
                                  │
                  ┌───────────────┴───────────────┐
                  │    Verify and Merge to Next   │
                  └───────────────────────────────┘
```

---

## 2. Custom Development Presets

Custom presets are configured for local development and CPU-specific profiling.

* **Target Naming**: Configured under names containing `Custom` (e.g., `GNU_Custom_Debug`, `Clang_Custom_Release`, `OneApi_Custom_RelWithDebInfo`).
* **Hardware Optimizations**: Emits specialized instructions tailored to the host CPU architecture.
    * **GNU and Clang**: Configured with `-march=native -ffast-math`.
    * **oneAPI (Intel DPC++ Compiler)**: Configured with `-xhost -ffast-math`.
    * *Objective*: Maximizes Instruction-Level Parallelism (ILP), vectorization capabilities (AVX2, AVX-512), and floating-point throughput for parallel algorithms (such as the TBB-based scanning engine).
* **Diagnostics**: Enables advanced runtime checks:
    * Standard library validation container macros (`_GLIBCXX_DEBUG` / `_LIBCPP_HARDENING_MODE_DEBUG`).
    * Preservation of frame pointers (`-fno-omit-frame-pointer`) and tail-call elimination (`-fno-optimize-sibling-calls`) to guarantee exact call stack generation during debugging and profiling.

---

## 3. Default Presets

Default presets are configured to guarantee zero-opinion portability for external consumers.

* **Target Naming**: Configured under names containing `Default` (e.g., `GNU_Default_Debug`, `Clang_Default_Release`).
* **Compiler Flags**: Configured with no custom compiler flags, relying entirely on the host system's standard CMake defaults.
* *Objective*: Ensures the codebase compiles cleanly in any environment (including CI/CD runners, packaging systems, and multiple Linux distributions) without forcing instruction set overrides, specific optimization selections, or non-portable optimization parameters.

---

## 4. The Double-Verification Cycle

Before modifications are merged to the `next` branch, they must pass verification under both preset environments.

Developers execute the unified verification runner script from the workspace root:

```bash
# Verify custom profiling/development presets in debug mode
./production_artifacts/build_all.sh custom debug

# Verify standard unopinionated presets in release mode
./production_artifacts/build_all.sh default release
```

This sequence guarantees that:
1. Active development optimizations compile, run tests, and generate valid profiling results.
2. The codebase remains portable, compiling successfully on generic systems that do not support native host-level compiler directives.
