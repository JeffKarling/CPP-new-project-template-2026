# Static Analysis & Clang-Tidy Workflow

The `template2026` build system integrates modern static analysis directly into the compilation cycle. This setup guarantees structural integrity and code hygiene while maintaining a fast active development cycle.

---

## 1. The Unified Clang-Tidy Summary

Traditional static analysis builds output hundreds of lines of compiler warnings to the standard build console. In large projects, this output obscures critical build errors and leads to warning fatigue.

The project addresses this by filtering and redirecting minor analysis findings into a single, unified static analysis log:

**[production_artifacts/clang_tidy_state.md](../production_artifacts/clang_tidy_state.md)**

### Clickable Source Line Integration
Every warning logged in `clang_tidy_state.md` is formatted as a standard markdown file link with precise line anchoring. The entries are presented in the following format:

`[file.cpp:line](file:///absolute/path/to/file.cpp#Lline)`

Inside CLion or any modern Markdown-enabled editor, clicking this link opens the source file and positions the editor's cursor directly on the offending line of code. This allows developers to inspect, modify, and verify warning contexts immediately without manual file searching.

---

## 2. Triggering the Analysis

To execute static analysis and generate the updated warning summary:

### From the Command Line
Run the configure and build workflows using the dedicated `Clang_Tidy` CMake preset:

```bash
# Configure the static analysis build environment
cmake --preset Clang_Tidy

# Compile and execute Clang-Tidy static analysis checks
cmake --build --preset Clang_Tidy
```

### From within CLion
1. Open the **Run/Debug Configuration** dropdown at the top right of the IDE.
2. Select the **`Clang_Tidy`** preset.
3. Click the **Build** button (or press `Ctrl + F9` / `Cmd + F9`).
4. Once compilation completes, open **[clang_tidy_state.md](file:///home/ello/CLionProjects/template2026/production_artifacts/clang_tidy_state.md)** to inspect the updated summary of findings.

---

## 3. Warning Classification and Action Strategy

To balance rigorous safety verification with active developer velocity, compilation warnings under the `Clang_Tidy` configuration are divided into three distinct categories:

### Category A: Safety-Critical & Structural Explicit Checks
These checks target code patterns that are prone to bugs or violate core project architecture. 
* *Policy*: **Must be resolved immediately.** Compilation will flag these as errors, and they are not permitted to reach the repository.
* *Examples*:
    * **Implicit Boolean Conversions (`readability-implicit-bool-conversion`)**: Disallows implicit conversion of numeric return values to booleans. Explicit comparison against literals must be used.
    * **Namespace Closing Comments (`google-readability-namespace-comments`)**: Requires closing namespace brackets to have trailing comments indicating their target name.

### Category B: Situational Design Warnings
These warnings target design patterns that may warrant attention but are subject to developer discretion.
* *Policy*: Automatically redirected to `clang_tidy_state.md` for periodic review.
* *Examples*:
    * **Braces Around Statements (`readability-braces-around-statements`)**: Flags single-line conditionals compiled without braces.
    * **Magic Numbers (`readability-magic-numbers`)**: Warns against raw numeric literals in calculations, except in layout configuration code.

### Category C: Stylistic Noise
Stylistic checks that do not impact code execution safety or parallel correctness.
* *Policy*: Automatically redirected to `clang_tidy_state.md` to prevent console clutter.
* *Examples*:
    * **Short Identifier Length (`readability-identifier-length`)**: Flags short local variable names.
    * **Pointer Arithmetic (`cppcoreguidelines-pro-bounds-pointer-arithmetic`)**: Subscripting on command-line argument lists (`argv`) inside standard main entrypoints.

---

## 4. Developer Elevation and Refactoring Workflow

If a developer reviews `clang_tidy_state.md` and decides a Category B or C warning should be addressed, they can elevate it to the active development roadmap using the following automated workflow:

1. Click the file link in `clang_tidy_state.md` to jump directly to the target line in the editor.
2. Insert an inline comment above the code using the standard `//ATR:` prefix:
   ```cpp
   //ATR: Fix magic number usage in output formatting
   ```
3. Run the comment tag parser from the project root:
   ```bash
   python3 .agents/parse_tags.py
   ```
4. The tag parser scans the source code, extracts the comment context and file coordinates, and automatically adds the item to the active **Codebase Inline Tasks** queue inside `.agents/refactoring_roadmap.md`.

---

## 5. Dependency Minimization (Include-What-You-Use)

To prevent compile-time degradation and keep target configurations clean, the build system integrates **Include-What-You-Use (IWYU)** analysis. 

Managed through customized mapping configurations (`iwyu_mappings.imp`), this tool automatically parses target source files to ensure that:
1. Every header file explicitly required by the source code is directly included.
2. Unnecessary transitive headers are removed.

This optimization keeps compilation dependencies minimal, structured, and compliant with C++ standard practices.
