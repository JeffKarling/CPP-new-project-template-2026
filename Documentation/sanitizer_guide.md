# Sanitizer Usage Guide

The `template2026` build system provides seven runtime sanitizer presets across Clang and GNU compilers. Sanitizers are binary-rewriting passes injected at compile time; they detect entire classes of memory safety and concurrency bugs **at runtime**, with exact source-line attribution, that neither compiler warnings nor deep debug library assertions can catch.

---

## 1. The Three-Layer Safety Net

The project enforces safety at three independent, complementary layers:

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 1 — Compiler Warnings  (-Wall -Wextra -Wpedantic…)   │
│  • Compile-time: catches obvious static code patterns       │
│  • Zero runtime overhead                                     │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│  Layer 2 — Deep Debug Diagnostics  (GNU_Custom_Debug_Deep   │
│             / Clang_Custom_Debug_Deep)                       │
│  • Runtime: validates STL container invariants and iterator  │
│    associations using standard library instrumentation       │
│  • ~10× slower; ABI-breaking for GCC safe-mode containers   │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│  Layer 3 — Sanitizers  (this guide)                         │
│  • Runtime: instruments every memory access, integer op,    │
│    and thread synchronization at machine-code level          │
│  • Detects heap corruption, races, leaks, and UB that       │
│    STL wrappers cannot observe                              │
└─────────────────────────────────────────────────────────────┘
```

Run Layer 2 and Layer 3 checks independently. They intercept different bug families and must not be combined in the same binary.

---

## 2. Quick Reference

| Preset | Compiler | Detects | Build Preset Name |
| :--- | :--- | :--- | :--- |
| `Clang_UBSan` | Clang | Undefined behavior (integer overflow, null deref, misaligned access, etc.) | `Clang_UbSan` |
| `Clang_MemSan` | Clang | Reads from uninitialized memory | `Clang_MemSan` |
| `Clang_ThreadSan` | Clang | Data races and lock-order inversions | `Clang_ThreadSan` |
| `Clang_AddressSan` | Clang | Heap/stack/global buffer overflows, use-after-free | `Clang_AddressSanitizer` |
| `Clang_LeakSan` | Clang | Memory leaks (standalone, lower overhead than ASan) | `Clang_LeakSanitizer` |
| `GNU_Custom_UBSan` | GCC | Undefined behavior | `GNU_Custom_UBSan` |
| `GNU_Custom_AddressSan` | GCC | Heap/stack/global buffer overflows, use-after-free | `GNU_Custom_AddressSanitizer` |

> [!IMPORTANT]
> **Sanitizers are mutually exclusive.** Never combine sanitizer flags in the same build. Each preset activates exactly one sanitizer. Attempting to combine them (e.g., ASan + TSan) produces linker errors or unreliable results. Use a dedicated preset per investigation.

---

## 3. Configuring and Building

Every sanitizer preset follows the same two-step workflow from the workspace root:

```bash
# Step 1: Configure the build directory
cmake --preset <ConfigurePresetName>

# Step 2: Compile with the sanitizer instrumentation
cmake --build --preset <BuildPresetName>
```

### Full Examples

```bash
# Clang UBSan
cmake --preset Clang_UBSan
cmake --build --preset Clang_UbSan

# Clang MemorySanitizer
cmake --preset Clang_MemSan
cmake --build --preset Clang_MemSan

# Clang ThreadSanitizer
cmake --preset Clang_ThreadSan
cmake --build --preset Clang_ThreadSan

# Clang AddressSanitizer
cmake --preset Clang_AddressSan
cmake --build --preset Clang_AddressSanitizer

# Clang LeakSanitizer
cmake --preset Clang_LeakSan
cmake --build --preset Clang_LeakSanitizer

# GNU UBSan
cmake --preset GNU_Custom_UBSan
cmake --build --preset GNU_Custom_UBSan

# GNU AddressSanitizer
cmake --preset GNU_Custom_AddressSan
cmake --build --preset GNU_Custom_AddressSanitizer
```

After building, run the resulting binary normally — the sanitizer runtime is embedded in the executable and reports violations directly to `stderr`:

```bash
./Build/Clang_UBSan/srcTargets/exeMain/template2026
```

---

## 4. UndefinedBehaviorSanitizer (UBSan)

**Presets:** `Clang_UBSan`, `GNU_Custom_UBSan`

### What It Detects

UBSan instruments every operation that the C++ standard classifies as undefined behavior:

- **Signed integer overflow** — e.g., `INT_MAX + 1`
- **Null pointer dereference** — dereferencing a pointer confirmed null at instrumentation time
- **Misaligned memory access** — dereferencing a `T*` not aligned to `alignof(T)`
- **Out-of-bounds array indexing** — accessing past the end of a fixed-size C array or `std::array`
- **Invalid enum values** — enum variables holding bit patterns not corresponding to any declared enumerator
- **Shift amount violations** — shifting an integer by a negative amount or by ≥ bit width
- **`vptr` type mismatches** — calling a virtual method through a pointer to the wrong dynamic type

### Compiler Flags

```
-fsanitize=undefined
-fno-sanitize-recover=undefined   # Clang only
-fno-omit-frame-pointer
-fno-optimize-sibling-calls
-O2 -ggdb -gdwarf-5
```

**`-fno-sanitize-recover=undefined`** (Clang preset only): By default, UBSan logs a warning and continues execution after each violation. This flag converts every UB detection into an immediate `SIGABRT`, stopping the program at the exact offending instruction. This makes Clang UBSan findings **blocking** — a sanitizer run either passes cleanly or aborts with an exact stack trace. The GNU preset omits this flag, continuing after each report, which is useful for collecting all violations in a single pass.

### Example Output

```
srcTargets/libExample/libExample.cpp:42:18: runtime error: signed integer overflow:
  2147483647 + 1 cannot be represented in type 'int'
SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior srcTargets/libExample/libExample.cpp:42:18
```

The format is always: `<file>:<line>:<col>: runtime error: <description>`. Open the file at the given line and eliminate the undefined operation (e.g., add an overflow check using `__builtin_add_overflow`, or switch to `unsigned` arithmetic where wrap-around is intentional).

---

## 5. MemorySanitizer (MSan)

**Preset:** `Clang_MemSan` *(Clang only)*

### What It Detects

MSan tracks every byte of heap and stack memory for initialization status. It fires when a program **reads from memory that was allocated but never written**. This class of bug is completely invisible to AddressSanitizer and UBSan: reading from valid but uninitialized memory is not an access violation — it just produces garbage values that silently propagate through calculations.

Common triggers:
- Reading a struct field that was never assigned before use
- Passing an output-only buffer to a function and reading it before the function writes to it
- Partial struct initialization with `= {}` omitted

### Compiler Flags

```
-fsanitize=memory
-fsanitize-memory-track-origins=2
-fno-omit-frame-pointer
-fno-optimize-sibling-calls
-O2 -g
```

**`-fsanitize-memory-track-origins=2`**: The `=2` level tracks **both the allocation site and every propagation step** of uninitialized bytes through the program. Without this flag, MSan only reports where the uninitialized value was *read*. With `=2`, the report additionally shows where the memory was *allocated* and each intermediate store that propagated the garbage value. This doubles runtime overhead but dramatically reduces investigation time by pinpointing the missing initialization directly.

### Important Constraint: Fully Instrumented Build

MSan requires that **all code the binary links against is compiled with `-fsanitize=memory`**, including any standard library components. Linking against prebuilt system libc or libstdc++ that was not compiled with MSan produces false positives from inside the standard library. The preset targets only the project's own translation units. If false positives appear from system library code, they can be suppressed via `MSAN_OPTIONS=halt_on_error=0` or a suppressions file.

### Example Output

```
WARNING: MemorySanitizer: use-of-uninitialized-value
    #0 0x... in ComputeScore srcTargets/libScoring/libScoring.cpp:87:14
    #1 0x... in main srcTargets/exeMain/main.cpp:34:5

  Uninitialized value was created by an allocation of 'result' in the stack frame
    #0 0x... in ComputeScore srcTargets/libScoring/libScoring.cpp:73
```

---

## 6. ThreadSanitizer (TSan)

**Preset:** `Clang_ThreadSan` *(Clang only)*

### What It Detects

TSan detects **data races**: two or more threads simultaneously accessing the same memory location where at least one access is a write, with no synchronization mechanism (mutex, atomic, or acquire/release barrier) protecting the access. It also detects **lock-order inversions** (potential deadlocks from inconsistent mutex acquisition ordering across threads).

Data races are among the hardest bugs to reproduce manually because they depend on precise thread scheduling. TSan detects them deterministically by maintaining a happens-before vector clock for every memory access and reporting inconsistencies without requiring the race to actually manifest as incorrect behavior during the test run.

### Compiler Flags

```
-fsanitize=thread
-pie
-fno-omit-frame-pointer
-fno-optimize-sibling-calls
-O2 -g
```

**`-pie` (Position-Independent Executable)**: TSan's shadow memory layout requires the binary to be compiled as a PIE. Without it, TSan's address-space reservation conflicts with the executable's fixed load address, causing initialization failures at startup.

> [!WARNING]
> **TSan and ASan cannot be used together.** They use incompatible shadow memory layouts. If you need both race detection and memory safety checking, run them in separate passes using their respective presets.

### Example Output

```
WARNING: ThreadSanitizer: data race (pid=12345)
  Write of size 4 at 0x7f9a1c002a80 by thread T2:
    #0 UpdateCounter srcTargets/libCounter/libCounter.cpp:55:18

  Previous read of size 4 at 0x7f9a1c002a80 by thread T1:
    #0 ReadCounter srcTargets/libCounter/libCounter.cpp:48:12

  Location is global 'g_counter' of size 4 at 0x7f9a1c002a80
SUMMARY: ThreadSanitizer: data race
```

Resolve data races by protecting the shared variable with a `std::mutex`, upgrading it to `std::atomic<T>`, or restructuring the algorithm to use per-thread local state merged after the parallel phase.

---

## 7. AddressSanitizer (ASan)

**Presets:** `Clang_AddressSan`, `GNU_Custom_AddressSan`

### What It Detects

ASan surrounds every heap allocation, stack variable, and global with **red-zone** shadow memory that poisons adjacent bytes. Any access into a red zone triggers an immediate, precise error report. Detected classes include:

- **Heap buffer overflow** — reading or writing past the end of a `malloc`/`new` allocation
- **Stack buffer overflow** — overflowing a fixed-size local array on the stack
- **Global buffer overflow** — overflowing a statically allocated global array
- **Use-after-free** — accessing heap memory after it has been `delete`d or `free`d
- **Use-after-return** — accessing a stack variable after the stack frame has been unwound
- **Use-after-scope** — accessing a local variable outside its lexical scope
- **Double-free** — calling `delete` on the same pointer twice

### Clang vs. GNU Differences

| Aspect | `Clang_AddressSan` | `GNU_Custom_AddressSan` |
| :--- | :--- | :--- |
| **Compiler** | `clang++` | `g++` |
| **Error symbolization** | Uses LLVM symbolizer for rich demangled output | Uses `addr2line`; less detailed by default |
| **LeakSanitizer integration** | Enabled automatically at process exit | Enabled automatically at process exit |
| **Recommendation** | Preferred for richest reports | Use to cross-validate or when Clang is unavailable |

### Example Output

```
=================================================================
==12345==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x602000000050
READ of size 4 at 0x602000000050 thread T0
    #0 0x... in ProcessBuffer srcTargets/libBuffer/libBuffer.cpp:103:9
    #1 0x... in main srcTargets/exeMain/main.cpp:29:5

0x602000000050 is located 4 bytes to the right of 16-byte region [0x602000000040,0x602000000050)
allocated by thread T0 here:
    #0 0x... in operator new[](unsigned long)
    #1 0x... in ProcessBuffer srcTargets/libBuffer/libBuffer.cpp:99:22

SUMMARY: AddressSanitizer: heap-buffer-overflow
```

The report shows: the access type and size, the faulting instruction location, and the allocation site of the overflowed region.

---

## 8. LeakSanitizer (LSan)

**Preset:** `Clang_LeakSan` *(Clang only)*

### What It Detects

LSan detects **memory leaks**: heap allocations that are never freed before process exit. It runs as a lightweight check at program termination, making it significantly cheaper than full ASan.

Note that ASan (`Clang_AddressSan`) automatically activates LSan at process exit as well. Use the dedicated `Clang_LeakSan` preset when:

- You only want leak detection without the full runtime overhead of memory red-zone instrumentation.
- ASan is too slow for your workload (e.g., large data processing pipelines).
- You want to confirm leaks independently from memory safety issues.

### Compiler Flags

```
-fsanitize=leak
-fPIE
-fno-omit-frame-pointer
-fno-optimize-sibling-calls
-O2 -g
```

**`-fPIE`**: Required for LSan's address-space layout to function correctly on Linux. LSan intercepts `malloc`/`free` at the dynamic linker level and needs a position-independent executable to reliably track all allocation roots.

### Example Output

```
=================================================================
==12345==ERROR: LeakSanitizer: detected memory leaks

Direct leak of 1024 byte(s) in 1 object(s) allocated from:
    #0 0x... in operator new(unsigned long)
    #1 0x... in BuildIndex srcTargets/libIndex/libIndex.cpp:212:24
    #2 0x... in main srcTargets/exeMain/main.cpp:41:5

SUMMARY: LeakSanitizer: 1024 byte(s) leaked in 1 allocation(s).
```

---

## 9. Reading Sanitizer Reports

All sanitizers write to `stderr`. Redirect both stdout and stderr to capture a complete log:

```bash
./Build/Clang_AddressSan/srcTargets/exeMain/template2026 2>&1 | tee sanitizer_report.txt
```

### Symbolization

Sanitizer stack frames are symbolized automatically when the binary is compiled with debug info (`-g` or `-ggdb`). If frames appear as raw hex addresses instead of source lines, verify that `llvm-symbolizer` is on `PATH` for Clang builds:

```bash
# Verify symbolizer is accessible
which llvm-symbolizer

# Or set it explicitly for a single run
ASAN_SYMBOLIZER_PATH=$(which llvm-symbolizer) ./Build/Clang_AddressSan/.../template2026
```

### Runtime Tuning via Environment Variables

Each sanitizer runtime accepts environment variables for additional control at run time without recompilation:

| Variable | Sanitizer | Example Value | Effect |
| :--- | :--- | :--- | :--- |
| `ASAN_OPTIONS` | ASan | `halt_on_error=0` | Continue after first error to collect all violations |
| `ASAN_OPTIONS` | ASan | `detect_stack_use_after_return=1` | Enable stack use-after-return detection (off by default) |
| `UBSAN_OPTIONS` | UBSan | `print_stacktrace=1` | Print full stack traces for every UB violation |
| `UBSAN_OPTIONS` | UBSan | `halt_on_error=1` | Abort on first violation (equivalent to `-fno-sanitize-recover`) |
| `TSAN_OPTIONS` | TSan | `halt_on_error=1` | Stop at the first detected race |
| `MSAN_OPTIONS` | MSan | `halt_on_error=0` | Collect all uninitialized reads before exiting |
| `LSAN_OPTIONS` | LSan | `suppressions=lsan.supp` | Path to a suppressions file |

### Suppressions

To suppress known false positives or third-party library noise, create a suppressions file and point the runtime at it:

```bash
# LSan suppression file format (lsan.supp):
# leak:ThirdPartyLibraryFunctionName

LSAN_OPTIONS=suppressions=lsan.supp ./Build/Clang_LeakSan/.../template2026
```

---

## 10. Agent Role, Test Engineer

Sanitizer runs are the responsibility of the **Test Engineer** agent role. When operating in this role:

1. Run the relevant sanitizer preset(s) after every code change that touches memory allocation, pointer arithmetic, parallel data access, or integer arithmetic.
2. Treat any sanitizer finding as a **blocking defect**. Changes that pass standard tests but trigger a sanitizer must be corrected before reaching the `next` branch.
3. Prefer the Clang variants for the richest, most detailed reports. Cross-validate with GNU ASan and UBSan when cross-compiler correctness is in question.
4. For parallel code (TBB algorithms), always run `Clang_ThreadSan` in addition to `Clang_AddressSan` — ASan does not detect data races.
5. For memory-leak investigations, start with `Clang_LeakSan` for speed, then escalate to `Clang_AddressSan` if the leak origin is not immediately clear from the LSan stack trace.

For the full role definition, see [agents.md](agents/agents.md).

For how sanitizers complement deep debug library diagnostics, see [deep_debug_details.md](deep_debug_details.md).
