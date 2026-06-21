# Trigger, From Sanitizer Output

Use this file when one or more Clang sanitizer presets have produced findings.
Match the sanitizer name and finding type to a pattern in the catalog.

---

## AddressSanitizer Findings, `Clang_AddressSan_Verify`

| ASan report keyword | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `heap-use-after-free` | Use-after-free | MEM50-CPP | `patterns/MEM/use-after-free.md` |
| `heap-buffer-overflow` | Buffer overrun, heap | STR51-CPP | `patterns/STR/buffer-overrun-heap.md` |
| `stack-buffer-overflow` | Buffer overrun, stack | STR51-CPP | `patterns/STR/buffer-overrun-stack.md` |
| `double-free` | Double-free | MEM51-CPP | `patterns/MEM/double-free.md` |
| `use-after-return` | Use-after-scope | MEM50-CPP | `patterns/MEM/use-after-free.md` |

## UBSanitizer Findings, `Clang_UBSan_Verify`

| UBSan report keyword | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `signed integer overflow` | Signed integer overflow | INT32-CPP | `patterns/INT/signed-integer-overflow.md` |
| `null pointer dereference` | Null pointer dereference | EXP34-CPP | `patterns/EXP/null-pointer-dereference.md` |
| `load of misaligned address` | Type punning | EXP63-CPP | `patterns/EXP/type-punning.md` |
| `member access within null pointer` | Null pointer dereference | EXP34-CPP | `patterns/EXP/null-pointer-dereference.md` |

## MemorySanitizer Findings, `Clang_MemSan_Verify`

| MemSan report keyword | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `use-of-uninitialized-value` | Uninitialized read | EXP53-CPP | `patterns/EXP/uninitialized-read.md` |

## LeakSanitizer Findings, `Clang_LeakSan_Verify`

| LeakSan report keyword | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `Direct leak` | Resource leak, RAII missing | MEM51-CPP | `patterns/MEM/resource-leak.md` |
| `Indirect leak` | Resource leak, RAII missing | MEM51-CPP | `patterns/MEM/resource-leak.md` |

## ThreadSanitizer Findings, `Clang_ThreadSan_Verify`

| ThreadSan report keyword | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `data race` | Data race | CON51-CPP | `patterns/CON/data-race.md` |
| `lock-order-inversion` | Lock order violation | CON53-CPP | `patterns/CON/data-race.md` |

---

If no entry matches, the finding may be a new pattern not yet in the catalog.
Use `patterns/PATTERN_TEMPLATE.md` to document it and add it to `SKILL.md`.
