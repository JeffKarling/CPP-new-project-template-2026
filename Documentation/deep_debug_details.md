# Deep Debug Diagnostics & Compiler Assertions

The `template2026` build system implements high-diagnostic debugging build presets (`GNU_Custom_Debug_Deep` and `Clang_Custom_Debug_Deep`) to uncover latent memory corruption, iterator invalidation, and out-of-bounds violations at runtime. 

---

## 1. The Core Purpose: Beyond Standard Debug Symbols

Standard debug compilations (compiled via `-O0 -g`) map assembly instructions back to C++ source lines for stack traces, but they do not actively validate the runtime states of standard containers or memory access invariants. Structural logical defects—such as out-of-bounds reads in vector elements, iterator invalidation during vector reallocations, or container mismatched range boundaries—regularly execute without triggering immediate segmentation faults. These errors manifest as silent memory corruption, resulting in unpredictable runtime bugs.

Deep Debug diagnostics address this by compiling standard library containers with maximum runtime validation assertions enabled.

---

## 2. GNU (GCC) safe-iterator and Pedantic Checks

Under GCC, compiling in deep debug mode activates the standard library’s defensive debugging instrumentation (`_GLIBCXX_DEBUG` and `_GLIBCXX_DEBUG_PEDANTIC` macro definitions).

* **Mechanism**: Replaces standard `std::vector`, `std::list`, `std::map`, and other standard library containers with specialized wrapper classes containing structural assertions.
* **Safe Iterators**: The compiler tracks iterator associations with their parent containers. If an iterator is dereferenced after a operation that invalidates it (such as a container resize/reallocation), or if iterators originating from two separate containers are compared, the standard library aborts execution immediately.
* **Mismatched Ranges**: Validates that range parameters passed to standard library algorithms represent a valid, iterable sequence (e.g. ensuring `first` actually precedes `last`).
* **ABI Compatibility Side Effect (Important)**: GNU safe containers alter the internal binary layout (size, alignment, and internal structure) of the library classes. This breaks ABI (Application Binary Interface) compatibility. Objects compiled with safe containers enabled **cannot** be mixed in the same binary with objects compiled under standard release or default configurations. The entire execution dependency graph must be compiled using the same diagnostic flags.

---

## 3. Clang (LLVM) Hardened libc++ Assertions

Under Clang, standard library diagnostics are managed through LLVM’s modern, layout-neutral `libc++` hardening modes, utilizing the maximum check preset (`_LIBCPP_HARDENING_MODE_EXTENSIVE`).

* **Mechanism**: Rather than wrapping containers in separate structural classes, Clang compiles standard library components with inline safety assertions on all memory access hot-paths.
* **Pre-condition Validation**: Enforces safety checks on STL method inputs, validating iterator dereferencability and bounds-checking indexing operations (such as `std::vector::operator[]` or `std::span` subscripting).
* **Layout Preserved (ABI Neutral)**: Unlike GNU's safe mode, Clang's hardened diagnostics do not alter the physical size or alignment of standard library containers. This preserves ABI compatibility, meaning hardened code can safely link against un-hardened static or shared libraries without memory layout corruption.

---

## 4. Synergy: Why It Is Important to Compile Under Both

Enforcing dual-verification across both GNU and Clang deep diagnostics is essential because their safety-checking architectures complement one another:

| Diagnostic Feature | GNU (`libstdc++` Safe Mode) | Clang (`libc++` Hardened Mode) |
| :--- | :--- | :--- |
| **Out-of-bounds Bounds Checking** | Yes | Yes (Extensive) |
| **Iterator Invalidation Tracking** | Yes (Comprehensive runtime tracking) | Limited to basic pre-condition checks |
| **ABI Compatibility** | **Breaks ABI** (Incompatible with standard builds) | **Preserves ABI** (Safe to link across boundaries) |
| **Detection Scope** | Focuses on structural C++ algorithm and container usage logic | Focuses on raw bounds checking and input pre-condition safety |

By testing modifications across both compiler suites:
1. **Clang Deep Debug** acts as a high-velocity check, capturing bounds and memory index violations while preserving layout compatibility with external dependencies.
2. **GNU Deep Debug** acts as an aggressive logic verification tool, detecting complex iterator invalidation bugs, container mismatches, and structural STL violations.
