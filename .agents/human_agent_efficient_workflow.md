# Human-Agent Integration Guide, Efficient Workflow Strategy

This document describes the recommended practices for integrating specialized agent roles into the daily development cycle, including role activation, model selection, and multi-model pipeline execution.

## Overview, Role-Based Development

Specialized agent roles partition responsibilities to ensure consistency and context efficiency. By configuring agents with specific execution boundaries, developers reduce setup overhead and maintain uniform standards across model transitions.

## Activating Agent Roles, Prompt Patterns

To activate a specific role at the start of a session, direct the agent to read the roles configuration file and explicitly assume the target role.

### C++ Engineer Activation
* **Command Prompt**:
  ```
  Read .agents/agents.md and assume the C++ Engineer role. Design and implement a new ThreadPool class using modern C++ semantics.
  ```

### Performance Engineer Activation
* **Command Prompt**:
  ```
  Read .agents/agents.md and assume the Performance Engineer role. Profile the parallel workload in tbbAlgos.cpp and scan for SIMD upconversion opportunities.
  ```

### Refactoring Specialist Activation
* **Command Prompt**:
  ```
  Read .agents/agents.md and assume the Refactoring Specialist role. Split databaseManager into two decoupled library targets.
  ```

### Test Engineer Activation
* **Command Prompt**:
  ```
  Read .agents/agents.md and assume the Test Engineer role. Generate Google Test suites for boundary conditions in databaseManagerTEST.
  ```

### Build and Release Specialist Activation
* **Command Prompt**:
  ```
  Read .agents/agents.md and assume the Build and Release Specialist role. Run static analysis using Clang_Tidy preset and document findings in clang_tidy_state.md.
  ```

### Security Engineer Activation
* **Command Prompt**:
  ```
  Read .agents/agents.md and assume the Security Engineer role. Run a full security audit: execute Clang-Tidy with the Clang_Tidy preset, enable Cppcheck, and run the sanitizer verification presets. Classify all findings by severity and resolve Critical and High severity defects.
  ```

## Model Selection, Role Mapping Guidelines

To maximize efficiency, map agent roles to language models based on model capability and task complexity.

| Agent Role | Recommended Model | Rationale |
| :--- | :--- | :--- |
| **C++ Engineer** | Claude Sonnet or Gemini Pro | Broad knowledge of modern C++ standards, excellent at zero-to-one implementation and architectural design. |
| **Refactoring Specialist** | Claude Sonnet | High reasoning capacity for complex, multi-file structural edits, codebase symmetry enforcement, and dependency mapping. |
| **Performance Engineer** | Gemini Pro | Balanced reasoning for parsing compiler logs, analyzing hardware performance counters, and vectorizing hot loops. |
| **Build and Release Specialist** | Gemini Flash or Pro | Highly efficient for compilation preset maintenance, dependency analysis, and running command-line verification scripts. |
| **Test Engineer** | Gemini Flash | Fast execution and high efficiency for authoring standard boundary tests and running cross-compiler test scripts. |
| **Security Engineer** | Claude Sonnet or Gemini Pro | Strong reasoning for interpreting sanitizer output, static analysis security findings, and CWE-class defect patterns across multi-file C++ codebases. |

## Multi-Model Handoff Pipelines, Pipeline Flow

Complex tasks benefit from structured pipelines where tasks are handed off between models according to their specialized roles:

```
┌────────────────────────────────────────────────────────┐
│ 1. Feature Dev, Claude Sonnet, C++ Engineer            │
│    Translates requirements into new C++ classes and    │
│    interfaces, enforcing modern idioms.                 │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ 2. Refactoring, Claude Sonnet, Refactoring Specialist  │
│    Restructures codebase, decouples targets, updates    │
│    CMakeLists.txt to enforce Symmetry Principle.        │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ 3. Optimization, Gemini Pro, Performance Engineer      │
│    Profiles parallel loops, compiles custom presets,    │
│    uses Intel Performance Skills to vectorize code.     │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ 4. Validation, Gemini Flash, Test Engineer             │
│    Generates standard GTest unit tests for boundaries,  │
│    verifies builds via build_all.sh.                    │
└────────────────────────────────────────────────────────┘
```

### Handoff Workflow Execution

1. Phase 1, Feature Dev: Initialize a session with a capable model (Claude Sonnet/Gemini Pro). Activate the C++ Engineer role. Direct the model to implement the core logic.
2. Phase 2, Refactoring: Initialize a session with Claude Sonnet. Activate the Refactoring Specialist role. Direct the model to restructure files and update CMake rules.
3. Phase 3, Optimization: Initialize a session with Gemini Pro. Activate the Performance Engineer role. Direct the model to run custom profile presets and optimize hot paths.
4. Phase 4, Validation: Initialize a session with Gemini Flash. Activate the Test Engineer role. Direct the model to run the verification suite and verify all test targets under GNU, oneAPI, and Clang compilers.

## Integration Benefits, Performance and Consistency

This workflow structure provides the following advantages:

1. Context Efficiency: Loading explicit roles and instructions in a single file reduces the configuration prompts to a minimum number of tokens.
2. Consistency: Different language models refer to the same unified definitions and guidelines, ensuring uniform project standards.
3. Portability: Custom presets, tool configurations, and compilation targets are kept in a single location, allowing the development cycle to adapt dynamically to model switches.
