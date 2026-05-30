# AI Agent Workspace (`.agents/`)

This directory is the dedicated space for AI agent metadata, planning blueprints, and developer-agent integration utilities. Maintaining this workspace folder prevents polluting the root project directory and ensures that the agent always has access to the design blueprints of the codebase.

## Layout

- [README.md](README.md) - This document.
- [refactoring_roadmap.md](refactoring_roadmap.md) - The persistent architectural blueprint and task list for refactoring.
- [parse_tags.py](parse_tags.py) - Standalone python tool that parses development comments and updates the roadmap.

---

## Codebase Comment Tags Guide

Developers and AI agents can inject dynamic tasks and architectural queries directly from code editors (like CLion) using standard inline comment formats:

### Add to Refactor (`//ATR:`)
Use this tag to flag technical debt, upcoming features, or code quality improvements.
* **Syntax**: `//ATR: <description>`
* **Example**:
  ```cpp
  //ATR: Migrate AsyncDatabaseUpdater to use parallel function_node instead of detaching threads.
  ```

### Design Discussions (`//DIS:`)
Use this tag to raise architectural questions or request expert opinions during code design reviews.
* **Syntax**: `//DIS: <description>`
* **Example**:
  ```cpp
  //DIS: Should we use thread_local Protobuf messages to avoid allocation overhead during serialization?
  ```

---

## How to Run the Tag Parser

The parser automatically scans the `srcTargets/` codebase for tags and updates [refactoring_roadmap.md](refactoring_roadmap.md) dynamically.

Run it directly from the project root directory:
```bash
python3 .agents/parse_tags.py
```
## Multi-Compiler Verification (`production_artifacts/build_all.sh`)

Due to CMake limitations, a single workflow preset can only execute compilation and test steps using a single configure preset (i.e. one specific compiler toolchain). 

To ensure robust cross-compiler compatibility without manual repetition, use the root verification runner:
```bash
./production_artifacts/build_all.sh [custom | default] [release | debug]
```
This script automates the full configure, build, and test pipeline (using workflow presets) across three compilers:
- **GNU (GCC)**
- **oneAPI (Intel C++ Compiler)**
- **Clang** (automatically handles Clang ABI link issues gracefully)

---

> [!IMPORTANT]
> **COMPULSORY AGENT RULES**:
> 1. AI agents MUST automatically update the [refactoring_roadmap.md](refactoring_roadmap.md) file (marking completed items as `[x]`) immediately after any refactoring task has been executed.
> 2. AI agents MUST always use the CMake preset named `Clang_Tidy` (via `cmake --preset Clang_Tidy && cmake --build --preset Clang_Tidy`) when asked to run clang-tidy checks on the codebase.
> 3. AI agents MUST by default always use the unified compilation script `build_all.sh` (located at `./production_artifacts/build_all.sh`, e.g. `./production_artifacts/build_all.sh [custom|default] [debug|release]`) to compile and verify code modifications. The agent should reason whether to run in `debug` or `release` mode based on the task requirements and must compare the build/test outputs from each of the three compilers (GNU, oneAPI, Clang) to ensure seamless cross-compatibility and verify that no warnings or regressions are introduced.
> 4. **Refactoring Roadmap Global Queue Workflow**:
>    - The project uses [refactoring_roadmap.md](refactoring_roadmap.md) as a persistent global state queue containing future refactoring jobs between agent sessions, allowing refactoring jobs to be queued in a file instead of tied to a specific session.
>    - **Clean Session Startup Mandate**: When entering a clean new chat session, *before performing any user-requested tasks*, the AI agent MUST ask the user one time: *"Should I scan the project for refactoring tags?"*. If the user confirms, the agent MUST run the tag parser script: `python3 .agents/parse_tags.py`.
>    - **Preferred Batch Workflow**: Combining several changes at once provides the agent with a larger, higher-fidelity context, leading to better code integration and significantly lower AI token consumption compared to small, piece-by-piece edits. This is the project's preferred workflow.
> 5. AI agents MUST NEVER use icons or emojis in any markdown (.md) files throughout the codebase to maintain a clean, formal, and professional layout.
> 6. AI agents MUST conduct all development, refactoring, and documentation modifications strictly on the branch named `next`. The agent must never commit directly to the `main` branch or perform push operations to GitHub, unless explicitly directed by the user.

