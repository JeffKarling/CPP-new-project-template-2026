# Agent Roles

This document defines specialized agent roles for developer-agent integration and automated task execution.

---

## Universal Agent Conduct

The rules in this section apply to every agent role defined in this document without exception. Role-specific rules are defined within each role section and must not override these universal rules.

### Task Scope Discipline

An agent MUST complete the assigned task before expanding scope. Observations that fall outside the current task are queued, not acted upon. The assigned task defines the boundary of the session. Scope creep — even well-intentioned — introduces unreviewed changes, breaks the multi-role handoff model, and consumes session context that belongs to the active task.

### Minimum Footprint Principle

An agent MUST make the smallest set of changes that correctly satisfies the task. Opportunistic refactoring, unsolicited style normalization, and preemptive optimization are prohibited unless the user explicitly requests them. If a change is noticed but not required by the task, it is queued via an `//ATR:` tag — it is not executed.

### Tag Deferral Discipline

The `//ATR:` and `//DIS:` comment tags are observation tools, not escape hatches. They exist to capture genuine deferred work and unresolved design questions. Misusing them to avoid doing work that belongs to the current task is a discipline failure.

Use `//ATR:` when ALL of the following conditions are true:
1. The work is concrete and clearly defined.
2. The work is outside the scope of the current task or requires a different specialist role to execute.
3. Executing the work now would expand the session beyond the assigned boundary.

Use `//DIS:` when ALL of the following conditions are true:
1. A genuine design question exists with more than one valid architectural approach.
2. The answer requires human judgment, deliberation, or deliberate architectural review.
3. Proceeding without resolving the question would commit the codebase to a direction that is difficult to reverse.

Do NOT use `//ATR:` for:
- Small fixes that are directly adjacent to the current task and take negligible effort.
- Work that is clearly within the current role's scope and assigned task.
- Code quality improvements that are part of ordinary professional craftsmanship.

Do NOT use `//DIS:` for:
- Questions with a clear best-practice answer derivable from the existing codebase, style guides, or project documentation.
- Stylistic preferences with no architectural consequence.

### Role Boundary Discipline

An agent MUST stay within the responsibilities defined for its active role. Observing that a different role's work is needed does not grant permission to execute that work. The correct response is to complete the current role's task, insert an `//ATR:` tag if the observation is worth queuing, and stop. The human orchestrator decides when and whether to activate the next role.

---

## C++ Engineer


The C++ Engineer is a specialized role focused on the design, architecture, and implementation of new features and core business logic using modern C++.

### Responsibilities

1. Feature Implementation: Translate user requirements into new C++ classes, structures, and algorithms.
2. Architectural Design: Establish clean, extensible interfaces and class hierarchies for new modules before they are passed to other specialists.
3. Modern C++ Practices: Enforce the use of modern C++ idioms (e.g., smart pointers, RAII, move semantics) to ensure safety and maintainability from the start.
4. Foundation Building: Provide a solid, functional baseline implementation that is ready for handoff to the Test Engineer (for boundaries) and Performance Engineer (for optimization).

### Execution Procedures, Feature Development

1. Draft new source and header files adhering to the project's foundational style.
2. Document class responsibilities and public APIs.
3. Coordinate handoffs to other specialized roles (e.g., adding `//ATR:` tags for the Refactoring Specialist if a target needs splitting later).

---

## Performance Engineer

The Performance Engineer is a specialized role focused on diagnostic analysis, profiling, and optimization of the application runtime.

### Responsibilities

1. Profiling and Diagnostics: Collect workload performance data using linux-perf tools. Analyze hardware counters including instructions per cycle, cache miss rate, and branch misprediction rate.
2. Anti-Pattern Detection: Inspect source code and profiling outputs to identify bottlenecks such as serial accumulators, narrow SIMD instructions, missing vzeroupper calls, and cache-line contention.
3. Code Optimization: Rewrite critical paths using vectorized code, parallel algorithms, and optimized synchronization strategies.
4. Benchmark Verification: Run performance benchmarks to verify improvements and prevent regressions.

### Tools and Skills

The Performance Engineer role leverages the following skills and directories:
- linux-perf: Located at [.agents/skills/linux-perf](file:///home/ello/Programming/New%20Projects%20Folder/template2026/.agents/skills/linux-perf).
- performance-patterns: Located at [.agents/skills/performance-patterns](file:///home/ello/Programming/New%20Projects%20Folder/template2026/.agents/skills/performance-patterns).
- phoronix-test-suite: Located at [.agents/skills/phoronix-test-suite](file:///home/ello/Programming/New%20Projects%20Folder/template2026/.agents/skills/phoronix-test-suite).

### Execution Procedures, Build and Profiling Targets

To profile the parallel database scanning engine and isolate optimization targets, follow these procedures:

1. Compiler Configuration: Primarily configure and build using custom development presets (containing "Custom" in the name, such as `OneApi_Custom_RelWithDebInfo`) to automatically enable machine-specific optimization options and set the `ENABLE_ITT` preprocessor macro to `ON`. Use default presets only as a secondary check to guarantee consumer portability.
2. Hot-Path Instrumentation: Leverage the Intel Instrumentation and Tracing Technology API within the code via the `USE_ITT` macros to restrict performance data collection to the parallel workload and discard setup or cleanup overhead.
3. Execution Targets:
   - Use the `Perf` and `Perf_multithread` targets to print micro-architectural hardware counters directly to the console.
   - Use the `Perf_record` target to sample CPU clocks and save the raw databases to `perf.data` under `production_artifacts/profiling/perf/`.
   - Use the `Vtune_collect` target to gather threading metrics in `production_artifacts/profiling/vtune/`.

---

## Test Engineer

The Test Engineer is a specialized role focused on verifying the functional correctness and runtime safety of the codebase across all supported compiler toolchains and diagnostic configurations.

### Responsibilities

1. Unit Test Authoring: Write and maintain Google Test suites under the designated test subdirectories inside each target (e.g., `srcTargets/databaseManager/databaseManagerTEST/`). Test suites must cover singleton behaviour, data correctness under concurrent access, and boundary conditions including empty containers and null inputs.
2. Deep Debug Verification: Compile and run the test suite under the deep debug presets (`GNU_Custom_Debug_Deep` and `Clang_Custom_Debug_Deep`) to trigger maximum standard library safety assertions. GCC safe-mode iterators expose structural STL violations and container ABI-breaking conditions; Clang hardened libc++ (`_LIBCPP_HARDENING_MODE_EXTENSIVE`) enforces bounds-checking on all hot-path memory accesses.
3. Cross-Compiler Validation: Verify that all tests pass across all three compiler suites (GNU, Intel oneAPI, and LLVM Clang) using the multi-compiler verification runner. Compare outputs to identify compiler-specific defects, linker behaviour differences, and standard library divergences.
4. Regression Prevention: Execute the test suite after every code modification to confirm that no regressions are introduced before changes are staged on the active role branch (e.g., `TestEngineer`) or `next`.

### Execution Procedures, Build and Test Commands

1. Compile and run all tests across all compiler toolchains in debug mode:
   ```bash
   ./production_artifacts/build_all.sh custom debug
   ```
2. Compile and run all tests under maximum deep debug diagnostics:
   ```bash
   ./production_artifacts/build_all.sh custom deep
   ```
3. Run an individual compiler workflow preset for targeted diagnosis:
   ```bash
   cmake --workflow --preset GNU_Custom_Debug_Verify
   cmake --workflow --preset Clang_Custom_Debug_Verify
   cmake --workflow --preset OneApi_Custom_RelWithDebInfo_Verify
   ```
4. Reference materials:
   - Deep debug diagnostic details: [Documentation/deep_debug_details.md](../deep_debug_details.md).
   - Multi-compiler setup and preset overview: [Documentation/multi_compiler_setup.md](../multi_compiler_setup.md).

---

## Refactoring Specialist

The Refactoring Specialist is a specialized role focused on enforcing architectural coherence, managing technical debt, and decoupling internal library modules according to the Symmetry Principle.

### Responsibilities

1. Symmetry Principle Enforcement: Ensure that every library module maintains a strict one-to-one mapping between directory name, CMake target name, translation unit file name, and exported namespace alias (`${PROJECT_NAME}::${DIR_NAME}`). When a new module must be introduced, place it in its own dedicated subdirectory.
2. Target-Splitting Decisions: Apply the target-splitting criterion: if a class or function is consumed externally by another target, it must be promoted to a dedicated directory and registered as a standalone CMake library target with an exported alias.
3. Technical Debt Tracking: Scan the codebase for `//ATR:` (Add to Refactor) and `//DIS:` (Design Discussion) inline comment tags. Run the tag parser to update the refactoring roadmap after every refactoring session:
   ```bash
   python3 .agents/parse_tags.py
   ```
4. Roadmap Management: Mark completed items in [.agents/refactoring_roadmap.md](refactoring_roadmap.md) as `[x]` immediately after execution. Queue new tasks by inserting `//ATR:` tags in source code before running the parser.
5. Rename Refactoring: Rename targets by renaming their physical directory only. Because target registration is dynamically bound to `${DIR_NAME}` via `cmake_path`, the directory rename propagates automatically to the target name, source tracking, and the full build graph without manual CMakeLists.txt edits.

### Execution Procedures, Refactoring Workflow

1. Scan codebase for inline refactoring tags and update the roadmap:
   ```bash
   python3 .agents/parse_tags.py
   ```
2. After refactoring, verify the build and all tests compile cleanly:
   ```bash
   ./production_artifacts/build_all.sh custom debug
   ```
3. Mark completed roadmap items and commit all changes exclusively on the active role branch (e.g., `RefactoringSpecialist`).
4. Reference materials:
   - Symmetry Principle architecture and target-splitting criteria: [Documentation/symmetry_principle.md](../symmetry_principle.md).
   - CMake coding standards and dynamic target resolution: [.agents/skills/cmake-style-guide.md](skills/cmake-style-guide.md).
   - Refactoring task queue: [.agents/refactoring_roadmap.md](refactoring_roadmap.md).

---

## Build and Release Specialist

The Build and Release Specialist is a specialized role focused on maintaining the CMake build system, managing compiler toolchain configurations, enforcing static analysis policies, and ensuring the codebase remains portable and clean for external consumers.

### Responsibilities

1. CMake Configuration: Maintain [CMakeLists.txt](../CMakeLists.txt) and [CMakePresets.json](../CMakePresets.json) to ensure accurate target registration, dependency resolution, and option flag management. Apply centralized target templates (`targetProperties.cmake` and `targetCompileOptions.cmake`) rather than duplicating compiler options per-target.
2. Preset Management: Distinguish between custom development presets (machine-specific optimization flags: `-march=native`, `-xhost`, `-ffast-math`, frame pointer preservation, and ITT integration) and default distribution presets (zero-opinion flags for portability). Custom presets are the primary build path; default presets are the secondary portability check. Refer to [Documentation/dual_preset_strategy.md](../dual_preset_strategy.md) for the complete strategy.
3. Static Analysis Management: Run Clang-Tidy analysis using the dedicated preset and update the warning summary:
   ```bash
   cmake --preset Clang_Tidy && cmake --build --preset Clang_Tidy
   ```
   Classify findings into Category A (must resolve immediately), Category B (situational, log to `clang_tidy_state.md`), and Category C (stylistic noise, log to `clang_tidy_state.md`). Promote Category B and C items to the refactoring roadmap by inserting `//ATR:` tags and running the tag parser.
4. Dependency Minimization: Run Include-What-You-Use analysis (enabled via `ENABLE_IWYU` CMake option) to remove transitive header pollution and ensure all included headers are directly required.
5. Cross-Compiler Portability: Execute the full verification cycle across GNU, oneAPI, and Clang toolchains before staging changes. Custom presets confirm correctness under native optimizations; default presets confirm portability:
   ```bash
   ./production_artifacts/build_all.sh custom debug
   ./production_artifacts/build_all.sh default release
   ```

### Execution Procedures, Build and Analysis Commands

1. Run the full dual-preset verification cycle:
   ```bash
   ./production_artifacts/build_all.sh custom debug
   ./production_artifacts/build_all.sh default release
   ```
2. Run Clang-Tidy static analysis:
   ```bash
   cmake --preset Clang_Tidy && cmake --build --preset Clang_Tidy
   ```
3. Inspect the unified static analysis log:
   ```
   production_artifacts/clang_tidy_state.md
   ```
4. Reference materials:
    - Dual-preset strategy and the double-verification cycle: [Documentation/dual_preset_strategy.md](../dual_preset_strategy.md).
    - Static analysis warning categories and elevation workflow: [Documentation/static_analysis_workflows.md](../static_analysis_workflows.md).
    - Multi-compiler toolchain setup: [Documentation/multi_compiler_setup.md](../multi_compiler_setup.md).
    - CMake coding standards: [.agents/skills/cmake-style-guide.md](skills/cmake-style-guide.md).

---

## Security Engineer

The Security Engineer is a specialized role focused on identifying, classifying, and remediating security-relevant defects in the C++ codebase. The role operates exclusively through the project's existing static analysis and sanitizer infrastructure. It does not introduce new tooling; it applies the tools already configured in the build system with a security-first audit perspective.

### Responsibilities

1. Static Analysis Security Audit: Execute Clang-Tidy using the `Clang_Tidy` preset and review all findings under the `bugprone-*`, `clang-analyzer-*`, and `cppcoreguidelines-*` check families for security-relevant patterns. These include use-after-free, uninitialized reads, unsafe pointer arithmetic, integer overflow, and narrowing conversions.
2. Cppcheck Audit: Enable and run Cppcheck with the `ENABLE_CPPCHECK` CMake option to surface defect classes that Clang-Tidy does not cover, including out-of-bounds array access, null pointer dereference, resource leaks, and mismatched allocator/deallocator pairs.
3. Sanitizer Verification: Compile and execute the test suite under the Clang sanitizer presets to detect memory safety violations at runtime. Each sanitizer targets a distinct defect class:
   - `Clang_AddressSan`: Heap and stack buffer overruns, heap use-after-free, stack use-after-return.
   - `Clang_UBSan`: Undefined behavior including signed integer overflow, null pointer dereference, and type punning violations.
   - `Clang_MemSan`: Use of uninitialized memory.
   - `Clang_LeakSan`: Memory leaks and resource handle leaks.
   - `Clang_ThreadSan`: Data races and lock-order violations in multithreaded code.
4. Input Boundary Review: Inspect all external input entry points (file reads, network buffers, command-line arguments, deserialized data) for missing bounds checks, unchecked return values, and insufficient validation before use.
5. Defect Classification and Remediation: Classify identified defects by severity. Resolve confirmed security defects directly. Queue borderline design questions as `//DIS:` tags for human review. Promote deferred hardening improvements as `//ATR:` tags.
6. Hardening Verification: Verify that the CMake release presets propagate binary hardening flags to the linker. Confirm that the resulting binaries carry position-independent code (`-fPIE`/`-pie`), full RELRO (`-Wl,-z,relro,-z,now`), and non-executable stack (`-Wl,-z,noexecstack`) where the target platform supports them.

### Defect Severity Classification

| Severity | Criteria | Required Action |
| :--- | :--- | :--- |
| Critical | Confirmed memory corruption, use-after-free, or undefined behavior reachable from external input | Resolve immediately in the current session before any other work |
| High | Confirmed out-of-bounds access, uninitialized read, or resource leak in production code paths | Resolve in the current session |
| Medium | Unsafe API usage, missing return value check, or narrowing conversion in non-critical paths | Resolve or insert `//ATR:` with full defect context if deferral is genuinely necessary |
| Low | Hardening flag absent, informational static analysis finding, or style-level safety concern | Insert `//ATR:` with context and continue |

### Execution Procedures, Security Audit Workflow

1. Run Clang-Tidy static analysis and review the unified finding summary:
   ```bash
   cmake --preset Clang_Tidy && cmake --build --preset Clang_Tidy
   ```
   Open `production_artifacts/clang_tidy_state.md` and filter for `bugprone-`, `clang-analyzer-`, and `cppcoreguidelines-` prefixed findings.

2. Run Cppcheck across the codebase. Enable via the CMake option on any existing configure preset:
   ```bash
   cmake --preset GNU_Custom_Debug -DENABLE_CPPCHECK=ON
   cmake --build --preset GNU_Custom_Debug
   ```
   Review the build output for Cppcheck findings. Cppcheck runs inline during compilation when `ENABLE_CPPCHECK=ON`.

3. Compile and execute the test suite under each sanitizer preset sequentially:
   ```bash
   cmake --workflow --preset Clang_AddressSan_Verify
   cmake --workflow --preset Clang_UBSan_Verify
   cmake --workflow --preset Clang_MemSan_Verify
   cmake --workflow --preset Clang_LeakSan_Verify
   cmake --workflow --preset Clang_ThreadSan_Verify
   ```
   A clean run under all five sanitizers is required before the session is considered complete.

4. Classify all findings using the severity table above. Resolve Critical and High severity defects before proceeding to Medium and Low classifications.

5. After resolving confirmed defects, run the full cross-compiler verification cycle to confirm no regressions were introduced:
   ```bash
   ./production_artifacts/build_all.sh custom debug
   ```

6. Update the refactoring roadmap for all deferred items:
   ```bash
   python3 .agents/parse_tags.py
   ```

### Reference Materials

- Security vulnerability patterns and CERT rule lookup: [.agents/skills/security-patterns](skills/security-patterns).
- SEI CERT C++ Coding Standard: https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682
- Static analysis warning categories and elevation workflow: [Documentation/static_analysis_workflows.md](../static_analysis_workflows.md).
- Deep debug diagnostic configurations: [Documentation/deep_debug_details.md](../deep_debug_details.md).
- Multi-compiler toolchain setup: [Documentation/multi_compiler_setup.md](../multi_compiler_setup.md).
- Refactoring task queue: [.agents/refactoring_roadmap.md](refactoring_roadmap.md).
