# Trigger, From Cppcheck Findings

Use this file when reviewing Cppcheck output from a build with `ENABLE_CPPCHECK=ON`.
Cppcheck runs inline during compilation and prints findings to the build console.

Enable Cppcheck on any configure preset:
```bash
cmake --preset GNU_Custom_Debug -DENABLE_CPPCHECK=ON
cmake --build --preset GNU_Custom_Debug
```

Cppcheck is configured in this project with `--enable=all --std=c++23 --inline-suppr`.

---

## Check-to-Pattern Mapping

| Cppcheck message ID | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `useAfterLifetime` | Use-after-free | MEM50-CPP | `patterns/MEM/use-after-free.md` |
| `doubleFree` | Double-free | MEM51-CPP | `patterns/MEM/double-free.md` |
| `memleak` | Resource leak | MEM51-CPP | `patterns/MEM/resource-leak.md` |
| `resourceLeak` | Resource leak, file handle | MEM51-CPP | `patterns/MEM/resource-leak.md` |
| `nullPointer` | Null pointer dereference | EXP34-CPP | `patterns/EXP/null-pointer-dereference.md` |
| `nullPointerRedundantCheck` | Null pointer dereference | EXP34-CPP | `patterns/EXP/null-pointer-dereference.md` |
| `uninitvar` | Uninitialized variable | EXP53-CPP | `patterns/EXP/uninitialized-read.md` |
| `uninitMemberVar` | Uninitialized member | EXP53-CPP | `patterns/EXP/uninitialized-read.md` |
| `arrayIndexOutOfBounds` | Buffer overrun | STR51-CPP | `patterns/STR/buffer-overrun-heap.md` |
| `bufferAccessOutOfBounds` | Buffer overrun | STR51-CPP | `patterns/STR/buffer-overrun-heap.md` |
| `integerOverflow` | Signed integer overflow | INT32-CPP | `patterns/INT/signed-integer-overflow.md` |
| `signedIntegerOverflow` | Signed integer overflow | INT32-CPP | `patterns/INT/signed-integer-overflow.md` |
| `checkLibraryUseRetVal` | Unchecked return value | ERR33-CPP | `patterns/ERR/unchecked-return-value.md` |

---

## Suppression Mechanism

Cppcheck supports inline suppressions via `--inline-suppr` (already enabled).
To suppress a false positive at a specific line, insert a comment on the
preceding line:

```cpp
// cppcheck-suppress <messageId>
```

Only suppress confirmed false positives. Document the reason for suppression
in the same comment. Do not suppress genuine findings.

---

If no entry matches, the finding may be a new pattern not yet in the catalog.
Use `patterns/PATTERN_TEMPLATE.md` to document it and add it to `SKILL.md`.
