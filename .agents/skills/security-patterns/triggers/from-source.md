# Trigger, From Source Code Review

Use this file when reviewing C++ source code without any tool output.
Scan for the patterns listed below by reading the code directly.

---

## Source Code Patterns, What to Look For

### Memory Management

| Observable in source | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| Raw `new`/`delete` without RAII wrapper | Resource leak, double-free risk | MEM51-CPP | `patterns/MEM/resource-leak.md` |
| Pointer used after `std::move()` | Use-after-free, moved-from object | MEM50-CPP | `patterns/MEM/use-after-free.md` |
| Manual memory sizing using arithmetic on user input | Buffer overrun | STR51-CPP | `patterns/STR/buffer-overrun-heap.md` |
| `reinterpret_cast` between unrelated types | Type punning, UB | EXP63-CPP | `patterns/EXP/type-punning.md` |

### Integer Arithmetic

| Observable in source | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| `int` used in size or index arithmetic with no overflow check | Signed integer overflow | INT32-CPP | `patterns/INT/signed-integer-overflow.md` |
| Implicit conversion from wider to narrower integer type | Narrowing conversion | INT31-CPP | `patterns/INT/narrowing-conversion.md` |
| Loop index used as array subscript without bounds check | Buffer overrun | STR51-CPP | `patterns/STR/buffer-overrun-heap.md` |

### Error Handling

| Observable in source | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| Return value of allocation, I/O, or system call discarded | Unchecked return value | ERR33-CPP | `patterns/ERR/unchecked-return-value.md` |
| Exception caught and silently swallowed | Suppressed error | ERR33-CPP | `patterns/ERR/unchecked-return-value.md` |

### Concurrency

| Observable in source | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| Shared mutable state accessed without synchronization | Data race | CON51-CPP | `patterns/CON/data-race.md` |
| Non-thread-safe standard library function called from multiple threads | Data race | CON51-CPP | `patterns/CON/data-race.md` |
| Multiple locks acquired in inconsistent order across code paths | Lock-order violation | CON53-CPP | `patterns/CON/data-race.md` |

### Input Boundaries

| Observable in source | Pattern | CERT Rule | Detail file |
| :--- | :--- | :--- | :--- |
| External data used as array index or allocation size without validation | Buffer overrun | STR51-CPP | `patterns/STR/buffer-overrun-heap.md` |
| Null check absent before pointer dereference from external source | Null pointer dereference | EXP34-CPP | `patterns/EXP/null-pointer-dereference.md` |

---

If no entry matches, the pattern may be a new defect class not yet in the catalog.
Use `patterns/PATTERN_TEMPLATE.md` to document it and add it to `SKILL.md`.
