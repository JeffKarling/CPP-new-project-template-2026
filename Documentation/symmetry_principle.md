# Symmetry Principle Architecture

This guide details the concrete implementation, template configurations, and refactoring guidelines that enforce the **Symmetry Principle** across the `template2026` codebase.

---

## 1. Architectural Motivation

In standard C++ codebases, a common source of cognitive friction is naming discrepancy. For example, a subdirectory might be named `utils/`, while its CMake library target is registered as `utility_lib`, the primary source file is named `helper.cpp`, and the exported namespace target is `my_project::common`. 

This variation introduces a naming translation overhead that developers must track mentally. The Symmetry Principle removes this translation by establishing a strict, identical relationship across the project structure:

$$\text{Directory Name} == \text{Target Name} == \text{Translation Unit File Name} == \text{Library Object Name}$$

Knowing a folder is named `foo` guarantees that:
* The library target is `foo`.
* The main source implementation file is `foo.cpp`.
* The public header file path is `foo/foo.hpp`.
* The namespaced internal link target is `${PROJECT_NAME}::foo`.

---

## 2. Compilation Boundaries and Modularity

This symmetrical structure serves as a strong check on software coupling. Because a library target cannot consume classes or headers from another directory without explicitly linking against that target in its CMake configuration, structural boundaries remain ironclad, preventing circular dependencies.

### Guidelines for Multi-Source Targets

While the Symmetry Principle maps one directory to one target, it is architecturally acceptable to add multiple `.cpp` source files to a target if they represent private helper implementations that meet the following criteria:

* **Internal Isolation**: The helper files are only used internally inside that specific target.
* **Encapsulation**: The code within these files is never referenced, seen, or linked directly by other targets.
* **Readability**: They exist solely to keep the target's main `.cpp` source file clean, readable, and structured.

### Criteria for Target Splitting

Conversely, a new source file must be split into a new target and directory under the following conditions:

* **External Dependencies**: If the source file implements a class, function, or interface that other targets in the project must call, reference, or link against, the Symmetry Principle requires placing it in its own physical folder as a separate, isolated target. This enforces strict compilation boundaries and maintains a clean, decoupled dependency graph.

---

## 3. Dynamic Target Resolution and Rename Refactoring

Target names are resolved dynamically from their physical directory locations using `cmake_path`:

```cmake
# Dynamic target binding to current directory name
cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)

# Library target registration
add_library(${DIR_NAME})

# Export namespaced ALIAS target for global consumption
add_library(${PROJECT_NAME}::${DIR_NAME} ALIAS ${DIR_NAME})
```

### Simplified Rename Refactoring

Determining clear, accurate nomenclature for modules during early development is difficult. Consequently, it is of great benefit to be able to rename targets later in the lifecycle when a better name is identified.

In C++ projects, renaming an internal library is a manual process that requires:
1. Renaming the physical directory.
2. Modifying target names in the local `CMakeLists.txt`.
3. Updating file paths inside `target_sources(...)`.
4. Updating all downstream configurations where the library target is linked.

Under the Symmetry Principle, renaming a library is simplified, adhering to the DRY (Don't Repeat Yourself) principle. Because target registration and file paths are dynamically bound to `${DIR_NAME}`, renaming the physical directory automatically updates the target, the source file tracking, and the compilation graph. The directory rename is the single action required, allowing developers to adapt module names without repeating configurations or performing manual build system maintenance.

---

## 4. The Executable Target Exception

The main executable target (`exeMain`) is the only component where this naming convention is bypassed. For profiling, custom runners, and global compilation tracking, the executable target name must resolve to the master project name `${PROJECT_NAME}` rather than `exeMain`.

The unified template structure is preserved by temporarily overriding the dynamic binding in [exeMain/CMakeLists.txt](file:///home/ello/CLionProjects/template2026/srcTargets/exeMain/CMakeLists.txt):

```cmake
cmake_path(GET CMAKE_CURRENT_LIST_DIR FILENAME DIR_NAME)

# 1. Bind target to the master project name
set(MAIN_TARGET ${PROJECT_NAME})

# 2. Swap DIR_NAME with MAIN_TARGET so compilation templates configure the executable target
set(ORIGINAL_DIR_NAME ${DIR_NAME})
set(DIR_NAME ${MAIN_TARGET})

add_executable(${MAIN_TARGET})

# 3. Include centralized compilation templates
include(${CMAKE_BINARY_DIR}/targetProperties.cmake)
include(${CMAKE_BINARY_DIR}/targetCompileOptions.cmake)

# 4. Restore DIR_NAME to original directory name for local source and header tracking
set(DIR_NAME ${ORIGINAL_DIR_NAME})
```

---

## 5. Centralized Target Option Templating

A direct benefit of the Symmetry Principle is the ability to implement centralized target option templating. Because targets are uniform in structure, all compilation options and properties (such as those defined in `targetCompileOptions.cmake` and `targetProperties.cmake`) are stored in a single central location.

Instead of writing complex, custom CMake modules that require significant developer time, cognitive effort, and maintenance, this template utilizes a straightforward file-inclusion approach. When a target requires custom options, it includes the shared configuration files using a single line in the target's `CMakeLists.txt` file (e.g. `include(${CMAKE_BINARY_DIR}/targetProperties.cmake)`). This copying of templates is a simple, direct mechanism that adheres strictly to the KISS (Keep It Simple, Stupid) principle, avoiding the design overhead of custom build scripting.

---

## 6. Side Effects of Symmetry Principle

While Symmetry Principle provides modularity and refactoring safety, the architecture introduces specific build-time and structural **trade-offs**. Below are the key criticisms alongside system mitigations:

* **Clean Build Duration**:
    * **Criticism**: Splitting the codebase into numerous small library targets increases clean compilation times due to redundant header parsing across compiler boundary invocations and the overhead of generating multiple static archives.
    * **Mitigation**: The clean build overhead is heavily offset by a reduction in incremental build times during active development. Because local source changes only trigger recompilation of the modified target, daily compilation runs are fast. This clean-build overhead can be further mitigated through Precompiled Headers (PCH) or C++20 Modules.
* **Build System Configuration Density**:
    * **Criticism**: Maintaining a 1-to-1 directory-to-target mapping increases the total count of files, requiring a dedicated local `CMakeLists.txt` and explicit subdirectory registration in parent files for every new module.
    * **Mitigation**: The build configuration utilizes centralized target templates (`targetProperties.cmake` and `targetCompileOptions.cmake`). This keeps individual module `CMakeLists.txt` files down to a few lines of DRY configuration, minimizing configuration maintenance.
* **Explicit Dependency Management Complexity**:
    * **Criticism**: Rigid compilation boundaries force developers to explicitly declare and track linkage dependency chains (`target_link_libraries`) for every single target, increasing build graph complexity.
    * **Mitigation**: This is a deliberate architectural constraint that forces developers to construct a clear, decoupled dependency graph, making circular dependencies impossible. The system simplifies this configuration by exporting namespaced ALIAS targets (`${PROJECT_NAME}::${DIR_NAME}`) automatically.
* **Template Instantiation and Binary Bloat**:
    * **Criticism**: Segregating targets can cause duplicate template instantiations to be compiled across separate static archive boundaries, increasing final executable size.
    * **Mitigation**: The build system addresses this by enabling Interprocedural Optimization / Link-Time Optimization (`ENABLE_IPO`) in release configurations, allowing the compiler to perform global inlining and strip duplicate symbols during the final linkage phase.
