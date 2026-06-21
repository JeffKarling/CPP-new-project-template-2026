---
name: security-patterns
description: >-
  Detect and remediate C++ security defect patterns using static analysis,
  sanitizer output, and the SEI CERT C++ Coding Standard as the authoritative
  reference. Invoke when the Security Engineer role is active, when a
  sanitizer preset produces findings, or when Clang-Tidy reports bugprone-*,
  clang-analyzer-*, or cppcoreguidelines-* check violations. Trigger on:
  buffer overrun, use-after-free, uninitialized read, integer overflow,
  null pointer dereference, resource leak, data race, unchecked return value,
  unsafe API usage, type punning, narrowing conversion, missing bounds check,
  format string vulnerability, or any request to harden a C++ codebase.
  Vulnerability families: MEM (memory management), CON (concurrency),
  INT (integer), STR (strings and buffers), ERR (error handling),
  EXP (expressions), MSC (miscellaneous).
---

# Security Patterns Skill

A catalog of C++ security defect patterns organized by vulnerability family.
Each pattern maps a defect class to its SEI CERT C++ rule, the Clang-Tidy or
Cppcheck check that surfaces it, the sanitizer that catches it at runtime, and
a remediation playbook.

---

## Authoritative Reference

All patterns in this skill are anchored to the SEI CERT C++ Coding Standard:
https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=88046682

Each rule identifier in this skill uses the CERT naming convention:
`<FAMILY><ID>-CPP` (example: `MEM51-CPP`, `CON51-CPP`, `INT30-CPP`).

---

## How to Use This Skill

### Step 1, Load the right trigger file for your context

| Context | Read this file |
| :--- | :--- |
| Sanitizer output, AddressSan or MemSan findings | `triggers/from-sanitizer.md` |
| Clang-Tidy static analysis findings | `triggers/from-clang-tidy.md` |
| Cppcheck findings | `triggers/from-cppcheck.md` |
| Source code review with no tool output | `triggers/from-source.md` |

### Step 2, Identify the matching pattern

Each trigger file contains a compact detection table — enough to match a
finding to a named vulnerability pattern and its CERT rule.

### Step 3, Read the pattern detail file

When a pattern matches, read the corresponding file from `patterns/`. Each
pattern file contains the CERT rule, CWE mapping, compliant and non-compliant
code examples, the exact remediation steps, and the verification method.

### Step 4, Apply the fix and verify

Follow the remediation steps. Run the relevant sanitizer preset to confirm the
defect is eliminated before closing the finding.

---

## Vulnerability Family Index

| Family prefix | Domain | CERT section |
| :--- | :--- | :--- |
| `MEM` | Memory allocation, deallocation, lifetime | MEM rules |
| `CON` | Concurrency, data races, lock discipline | CON rules |
| `INT` | Integer arithmetic, overflow, truncation | INT rules |
| `STR` | String and buffer handling | STR rules |
| `ERR` | Error handling, unchecked return values | ERR rules |
| `EXP` | Expression evaluation, type punning, UB | EXP rules |
| `MSC` | Miscellaneous: format strings, entropy, API misuse | MSC rules |

---

## Pattern Catalog, Current Entries

This catalog grows as real findings are encountered in the project. Each entry
links to its detail file.

| Pattern | CERT Rule | CWE | Primary detector |
| :--- | :--- | :--- | :--- |
| Use-after-free | MEM50-CPP | CWE-416 | AddressSanitizer |
| Double-free | MEM51-CPP | CWE-415 | AddressSanitizer |
| Resource leak, RAII missing | MEM51-CPP | CWE-401 | LeakSanitizer |
| Uninitialized read | EXP53-CPP | CWE-457 | MemorySanitizer |
| Signed integer overflow | INT32-CPP | CWE-190 | UBSanitizer |
| Unsigned wrap used as sentinel | INT30-CPP | CWE-190 | UBSanitizer, Clang-Tidy `bugprone-signed-char-misuse` |
| Buffer overrun, stack | STR51-CPP | CWE-121 | AddressSanitizer |
| Buffer overrun, heap | STR51-CPP | CWE-122 | AddressSanitizer |
| Unchecked return value | ERR33-CPP | CWE-252 | Clang-Tidy `bugprone-unused-return-value`, Cppcheck |
| Data race | CON51-CPP | CWE-362 | ThreadSanitizer |
| Null pointer dereference | EXP34-CPP | CWE-476 | UBSanitizer, Cppcheck |
| Type punning via reinterpret_cast | EXP63-CPP | CWE-843 | UBSanitizer |
| Narrowing conversion | INT31-CPP | CWE-197 | Clang-Tidy `cppcoreguidelines-narrowing-conversions` |

---

## Adding New Patterns

When a new security finding is encountered during an audit session that does
not match an existing pattern:

1. Create a new file under `patterns/<family>/<pattern-name>.md`.
2. Use the template in `patterns/PATTERN_TEMPLATE.md`.
3. Add the new entry to the Pattern Catalog table above.
4. Add a row to the relevant trigger file under `triggers/`.
