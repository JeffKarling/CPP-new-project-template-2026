# Pattern Template

Copy this file to `patterns/<family>/<pattern-name>.md` when documenting a new finding.

---

## Pattern Name

One-line description of the vulnerability class.

## CERT Rule

`<FAMILY><ID>-CPP` — Rule title.
Full rule: https://wiki.sei.cmu.edu/confluence/display/cplusplus/<FAMILYID>-CPP

## CWE Mapping

CWE-<ID>: CWE title.
Reference: https://cwe.mitre.org/data/definitions/<ID>.html

## Detectors

| Tool | Check or signal |
| :--- | :--- |
| Sanitizer | AddressSanitizer / UBSanitizer / MemorySanitizer / ThreadSanitizer / LeakSanitizer |
| Clang-Tidy | `<check-name>` |
| Cppcheck | `<check-name>` |

## Non-Compliant Example

```cpp
// Describe what is wrong and why it is a defect.
```

## Compliant Example

```cpp
// Describe the corrected pattern and why it is safe.
```

## Remediation Steps

1. Step one.
2. Step two.
3. Step three.

## Verification

Run the following to confirm the defect is eliminated:

```bash
cmake --workflow --preset Clang_<SanitizerName>_Verify
```

A clean sanitizer run with no relevant findings confirms the fix.

## Notes

Any caveats, project-specific considerations, or links to related patterns.
