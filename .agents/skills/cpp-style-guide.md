---
name: cpp-style-guide
description: Use this skill whenever writing, refactoring, or reviewing C++ source code, header files, or CMake configurations.
---
## 1. Libraries
* The project includes OneApi TBB for new targets.
* If a target is a Linux project, standard systemd journald logging is included via `<systemd/sd-journal.h>`.
* The project assumes OneApi MKL is available. For example, if a random uniform distribution is required, developers utilize the MKL Vector Statistics Library (VSL) `viRngUniform` in `#include <mkl.h>`, rather than standard STL functions in `#include <random>`.

## 2. Algorithms 
1. The project prefers parallel algorithms from TBB: `tbb::parallel_for`, `tbb::parallel_reduce`, `tbb::parallel_sort`, `tbb::parallel_scan`, `tbb::parallel_pipeline`, `tbb::parallel_invoke`.
2. The project prefers Ranges algorithms and adapters from STL `<ranges>` over standard STL algorithms from `<algorithm>` and `<numeric>`.
3. Developers investigate if the Intel OneApi MKL library has features to improve vectorization when combined with parallel algorithms.

## 3. General
* For systems using C++23 and later, developers prefer designing code around the Ranges memoryless collections architecture using ranges views and adaptors.
* Concepts and requires clauses are utilized for sanitizing input variables to functions:
  ```cpp
  LogScopeGuard(std::convertible_to<std::string_view> auto locale_name)
  ```

## 4. Naming things
Use long names, Use `input` instead of `in`, use `output` instead of `out`.
  ```cpp
  auto in {parseText()}; //Wrong
  auto input {parseText()}; //Correct
  ```

## 5. Tone and Documentation Formatting Standards
- **Subjective Adjectives**: Avoid subjective, loaded, or marketing adjectives (e.g., 'pristine', 'clean', 'highly', 'elegant', 'robust', 'frictionless', 'beautiful', 'mathematically', 'excellent', 'better'). Documentation and agent communications must remain objective, technical, and matter-of-fact.
- **Icons and Emojis**: Do not use icons, graphics, or emojis in documentation files, guides, or codebase markdown files.

## 6. Clang-Tidy Static Analysis Policy
The project enforces a static analysis policy during target builds. Emojis and icons are prohibited in static analysis tracking. All code compilation under the Clang_Tidy configuration generates warnings that are classified into three categories:

### Clang-Tidy Messages Classification Reasoning
* **Category A: Safety-Critical & Structural Explicit Check (Must Fix in Every Build)**:
  - **Implicit Boolean Conversions (`readability-implicit-bool-conversion`)**: Disallows implicit conversion of `size_t` or integer return values to booleans (e.g., `if (!MI.Open(path))`). Explicit comparisons against literal values (e.g., `if (MI.Open(path) == 0u)`) must be used.
  - **Namespace closing comments (`google-readability-namespace-comments`)**: Requires closing namespace brackets to have trailing comments indicating their target name (e.g., `} // namespace template2026`).
* **Category B: Situational Design Warnings (Developer Discretion)**:
  - **Braces Around Statements (`readability-braces-around-statements`)**: Single-line conditionals without braces are acceptable if simple, but braces are preferred.
  - **Magic Numbers (`readability-magic-numbers`)**: Constant wrapping is required for complex math and business logic, but standard layout formatting (`setw`) or basic unit conversion literals (e.g., dividing by 1000.0) may remain.
* **Category C: Stylistic Noise (Ignore or Log)**:
  - **Short Identifier Length (`readability-identifier-length`)**: Short standard variable names (e.g., `in`, `ec`, `i`, `MI`) are acceptable at local block scopes.
  - **Pointer Arithmetic (`cppcoreguidelines-pro-bounds-pointer-arithmetic`)**: Array subscripting on `argv` within standard `main()` entrypoints is acceptable.

### Agent Enforcement Policy
- The agent must always execute static analysis using the Clang_Tidy target parameters and **resolve all Category A warnings by default** in every build.
- All non-Category A warnings (Category B and C) are logged to the persistent state file [clang_tidy_state.md](../../production_artifacts/clang_tidy_state.md) for manual review.