# Trigger, From Clang-Tidy Findings

Use this file when reviewing `production_artifacts/clang_tidy_state.md` or
the `Clang_Tidy` preset build output. Match the check name prefix to a pattern.

Run the analysis first if not already done:
```bash
cmake --preset Clang_Tidy && cmake --build --preset Clang_Tidy
```

---

## Security-Relevant Check Families

Clang-Tidy check families active in this project that produce security findings:

| Check prefix | Domain | CERT alignment |
| :--- | :--- | :--- |
| `bugprone-*` | Error-prone constructs and likely bugs | ERR, MEM, EXP families |
| `clang-analyzer-*` | Deep interprocedural analysis | MEM, STR, EXP families |
| `cppcoreguidelines-*` | C++ Core Guidelines safety rules | MEM, INT, EXP families |
| `concurrency-*` | Threading and synchronization issues | CON family |

---

## Check-to-Pattern Mapping

| Clang-Tidy check | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `bugprone-use-after-move` | Use-after-free (moved-from object) | MEM50-CPP | `patterns/MEM/use-after-free.md` |
| `bugprone-unused-return-value` | Unchecked return value | ERR33-CPP | `patterns/ERR/unchecked-return-value.md` |
| `bugprone-signed-char-misuse` | Unsigned wrap / sign misuse | INT30-CPP | `patterns/INT/signed-integer-overflow.md` |
| `bugprone-integer-division` | Integer truncation | INT32-CPP | `patterns/INT/signed-integer-overflow.md` |
| `bugprone-narrowing-conversions` | Narrowing conversion | INT31-CPP | `patterns/INT/narrowing-conversion.md` |
| `clang-analyzer-cplusplus.NewDelete` | Use-after-free, double-free | MEM50-CPP, MEM51-CPP | `patterns/MEM/use-after-free.md` |
| `clang-analyzer-cplusplus.NewDeleteLeaks` | Resource leak | MEM51-CPP | `patterns/MEM/resource-leak.md` |
| `clang-analyzer-core.NullDereference` | Null pointer dereference | EXP34-CPP | `patterns/EXP/null-pointer-dereference.md` |
| `clang-analyzer-core.UndefinedBinaryOperatorResult` | Uninitialized read | EXP53-CPP | `patterns/EXP/uninitialized-read.md` |
| `cppcoreguidelines-narrowing-conversions` | Narrowing conversion | INT31-CPP | `patterns/INT/narrowing-conversion.md` |
| `cppcoreguidelines-pro-bounds-*` | Buffer bounds safety | STR51-CPP | `patterns/STR/buffer-overrun-heap.md` |
| `concurrency-mt-unsafe` | Non-thread-safe function call | CON51-CPP | `patterns/CON/data-race.md` |

---

If no entry matches, the finding may be a new pattern not yet in the catalog.
Use `patterns/PATTERN_TEMPLATE.md` to document it and add it to `SKILL.md`.
