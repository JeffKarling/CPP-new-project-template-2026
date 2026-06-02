[Release Tag Page](https://github.com/JeffKarling/CPP-new-project-template-2026/releases) | [GitHub Repository](https://github.com/JeffKarling/CPP-new-project-template-2026)

# C++ Project Template 2026

## 1. Project Background and Objective

This is my personal C++ project template I use. It represents a structured transition from manual copy-paste project creation methods to a centralized, version-controlled located in a repository. Template is saved on GitHub, maybe it can be used for others seeking a modern project where developers project design aligns with my opinionated project configuration.

---
## 2. Template Architecture and Best Practices

The project is the template structure itself, not the specific application logic contained within it. The database scanning engine and parallel algorithms included in this repository is example code to make the template executable, validation of the build configurations, testing frameworks and profiling integrations.

The template implements my opinionated favourite build system architectural standards aligning with modern best practices:

* **[The Symmetry Principle (Directory == Target == Translation Unit)](symmetry_principle.md)**: The template's build system enforces a strict mapping where the directory name, CMake library target, translation unit source file, and namespaced library alias target, are identical. This eliminates naming translation cognitive overhead, isolates compilation boundaries to prevent circular dependencies, and automates rename refactoring.
* **[Dual-Preset Compilation Strategy](dual_preset_strategy.md)**: CMake configurations are separated into custom development presets (tailored for active local profiling with machine-specific optimization flags) and default distribution presets (ensuring zero-opinion portability for external users).
* **[Multi-Compiler Setup & Verification](multi_compiler_setup.md)**: Standardizing builds across GNU GCC, LLVM Clang, and Intel oneAPI compiler toolchains is a C++ software engineering best practice. Multi-compiler compilation guarantees strict ISO C++ standard compliance, prevents vendor-specific lock-in, and allows different optimizer backends to expose distinct memory bugs, performance bottlenecks, and compilation errors. To make this frictionless, the template orchestrates multiple compiler workflow presets sequentially under a unified verification script.
* **[Static Analysis & Clang-Tidy Workflow](static_analysis_workflows.md)**: The build system isolates static analysis diagnostics to maintain clean compilation logs. Structural and safety-critical findings (Category A) are checked directly in the active build pipeline. Non-critical situational design and stylistic findings (Categories B and C) are redirected automatically to the persistent state log (`clang_tidy_state.md`), providing a single-point summary containing clickable file links that navigate the IDE cursor directly to the target lines of code.
* **[Profiling & Performance Engineering](profiling_guide.md)**: Hardware-level performance analysis is critical, especially in autonomous or agent-assisted development workflows where AI-generated modifications must be evaluated for CPU-bound efficiency, thread load balancing, and cache utilization. Profiling provides empirical runtime metrics to ensure that code changes degrade neither scalability nor resource utilization, even when they pass functional unit tests.
* **CMake 3.23+ File Sets**: The template utilizes native [CMake header and source file sets](https://cmake.org/cmake/help/latest/command/target_sources.html#file-sets) (`FILE_SET`) instead of legacy globs or manually tracked list variables. This guarantees clean public interface tracking and simplifies downstream target consumption.
* **[Deep Debug Diagnostics](deep_debug_details.md)**: The build system defines multi-compiler diagnostic debugging profiles (`GNU_Custom_Debug_Deep` and `Clang_Custom_Debug_Deep`) that integrate maximum standard-library safety assertions (`_LIBCPP_HARDENING_MODE_EXTENSIVE` for Clang and `_GLIBCXX_DEBUG_PEDANTIC` for GCC) to expose out-of-bounds reads and iterator invalidations at runtime. Compiling under both configurations is critical due to the layout-neutral preconditions checking in Clang's hardened libc++ and the strict structural iterator safety checks in GCC's safe-mode libstdc++.

---

## 3. Template vs. Example Code Requirements & Building

The project template is configured and tested using Fedora Linux. While the workspace contains both the core C++ build template and a concrete database scanning code example, their toolchain and compilation requirements are distinct:

### A. Template Requirements
These tools and configurations represent the core architecture of the C++ template itself:
* **CMake 3.23+**: Enforces native File Sets (`FILE_SET`) attributes for header tracking.
* **Modern C++ Compilers**: Supports GCC 11+, LLVM Clang 13+, or **[Intel oneAPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/overview.html)** ICPX 2023+.
* **[Intel oneAPI Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/overview.html)**: Recommended system-level installation to support direct VTune, Advisor, and dynamic compiler optimization presets. Note that the **Intel Instrumentation and Tracing Technology (ITT) API** is integrated as a template feature to support low-noise profiling out of the box. While the build system is designed to compile successfully without it (by setting the `ENABLE_ITT` feature to `OFF` in CMake), having the ITT API libraries available is required if you want to utilize the template's integrated profiling tracing features. For detailed information on executing and managing performance profiles, see the **[Multi-Compiler Debugging & Profiling Guide](profiling_guide.md)**.

### B. Example Application Requirements
These system package libraries are strictly required by the concrete database scanning and parallel extraction code example included to demonstrate the template:
* **Google Protobuf**: Required for object serialization of database schemas.
* **Intel Threading Building Blocks (TBB)**: Required for the task-parallel Flow Graph database scanning algorithms. *(Note: Threading Building Blocks is also deeply integrated into the template's parallel build configurations).*
* **Google Test (GTest)**: Required by the unit testing harness to validate code modifications.

### Compilation Invocations
To compile, build, and verify the example application across GNU, LLVM, and oneAPI compiler suites sequentially, execute the multi-compiler verification runner from the workspace directory:

```bash
# Compile and test development configurations in debug mode
./production_artifacts/build_all.sh custom debug

# Compile and test standard configurations in release mode
./production_artifacts/build_all.sh default release
```
