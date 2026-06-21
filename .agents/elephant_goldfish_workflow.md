# Elephant/Goldfish Workflow Variant

This document is written for readers already familiar with the Elephant/Goldfish collaborative AI model. It maps that model's terminology directly to the structures already present in this template, so that a new user can orient themselves immediately without re-reading the full agent documentation from scratch.

---

## Overview, What is the Elephant/Goldfish Model

The Elephant/Goldfish model is a collaborative AI workflow pattern for complex, multi-phase tasks such as software engineering or large-scale brainstorming. It pairs two distinct agent archetypes:

- The Elephant: a long-lived Senior AI with persistent, full project context. It retains architectural decisions, standards, and state across sessions.
- The Goldfish: one or more short-lived Junior AI sub-agents, each activated for a narrow, well-defined task. Each Goldfish operates within a focused scope and is discarded when the task completes.

The Elephant orchestrates and delegates. The Goldfish executes and hands off.

---

## How This Template Maps to the Model

### The Elephant, Persistent Project Context

The Elephant role is fulfilled by the combination of two files that are loaded at the start of every agent session:

- [GEMINI.md](../../.gemini/GEMINI.md): Establishes the global behavioral rules for all agents operating in the project. Defines performance-first engineering priorities, build configuration mandates, and profiling standards.
- [agents.md](agents.md): Defines the full catalogue of specialized roles, their exact responsibilities, and their execution procedures. This is the Elephant's long-term memory of who does what and how.

Together, these files form a stable, persistent brain that survives across every model switch, session restart, and role handoff. Any agent that reads them immediately inherits the full architectural context of the project.

The [README.md](README.md) of the `.agents/` workspace reinforces this with a set of compulsory agent rules that apply universally, regardless of which Goldfish role is active.

---

### The Goldfish, Specialized Short-Lived Roles

The Goldfish roles are the five specialized agent roles defined in [agents.md](agents.md). Each role is activated for a specific phase of development and deactivated when the phase ends:

| Goldfish Role | Scope | Recommended Model |
| :--- | :--- | :--- |
| C++ Engineer | Implement new features and class architectures | Claude Sonnet or Gemini Pro |
| Refactoring Specialist | Decouple targets, enforce Symmetry Principle | Claude Sonnet |
| Performance Engineer | Profile hot paths, vectorize loops, analyze hardware counters | Gemini Pro |
| Test Engineer | Author GTest suites, run cross-compiler verification | Gemini Flash |
| Build and Release Specialist | Maintain CMake presets, run static analysis | Gemini Flash or Pro |

A Goldfish is activated using the role activation prompts documented in [human_agent_efficient_workflow.md](human_agent_efficient_workflow.md). The activation prompt directs the agent to read `agents.md` and assume the target role, granting it the Elephant's context before it begins its narrow task.

---

### Handoff Mechanism, the Persistent State Queue

In a canonical Elephant/Goldfish implementation, the Goldfish leaves a structured handoff note for the next agent. This template implements that handoff through three mechanisms:

1. Inline comment tags in source code: The `//ATR:` (Add to Refactor) and `//DIS:` (Design Discussion) tags are injected directly into C++ source files to queue future tasks without requiring a live agent session.

2. Automated tag parser: Running `python3 .agents/parse_tags.py` from the project root scans the entire `srcTargets/` codebase and consolidates all discovered tags into the roadmap.

3. Refactoring roadmap: [refactoring_roadmap.md](refactoring_roadmap.md) is the persistent global state queue. It survives session death and is read by the next Goldfish at startup. Completed items are marked `[x]` immediately after execution.

This system replaces an ephemeral in-context handoff with a durable, file-backed queue that remains accurate regardless of how many sessions, model switches, or role transitions have occurred.

---

### The Multi-Model Pipeline, Full Goldfish Sequence

The [human_agent_efficient_workflow.md](human_agent_efficient_workflow.md) document defines the complete four-phase pipeline, which is the Elephant/Goldfish pattern expressed as a structured development cycle:

```
Phase 1, Feature Development
  Goldfish: C++ Engineer (Claude Sonnet)
  Task: Translate requirements into new classes and interfaces.
  Handoff: //ATR: tags inserted where refactoring is anticipated.

Phase 2, Refactoring
  Goldfish: Refactoring Specialist (Claude Sonnet)
  Task: Decouple targets, enforce Symmetry Principle, update CMake.
  Handoff: Roadmap updated, role branch committed.

Phase 3, Optimization
  Goldfish: Performance Engineer (Gemini Pro)
  Task: Profile hot paths, vectorize loops, verify hardware counters.
  Handoff: Benchmark results documented, custom presets validated.

Phase 4, Validation
  Goldfish: Test Engineer (Gemini Flash)
  Task: Generate GTest suites, run cross-compiler verification suite.
  Handoff: All tests pass across GNU, oneAPI, and Clang toolchains.
```

Each phase is a discrete Goldfish session. The model is switched between phases to match the cost and capability profile of the task. The Elephant context (GEMINI.md + agents.md) is reloaded at the start of each new session.

---

## Key Difference, Human Orchestration

The canonical Elephant/Goldfish model typically assumes an automated orchestrator that programmatically spawns and delegates to Goldfish sub-agents. This template uses a human-in-the-loop orchestration model instead. The developer reads the pipeline, activates the next role manually, and merges completed role branches into `next` before promoting to `main`.

This is an intentional design decision. Human orchestration provides a review checkpoint at every phase boundary, which is well suited to a solo or small-team environment where the cost of unchecked automated delegation exceeds the overhead of manual handoffs.

---

## Locating the Key Files

| Purpose | File |
| :--- | :--- |
| Elephant brain, global behavioral rules | [.gemini/GEMINI.md](../../.gemini/GEMINI.md) |
| Elephant brain, role definitions and procedures | [.agents/agents.md](agents.md) |
| Compulsory agent rules and workspace layout | [.agents/README.md](README.md) |
| Goldfish activation prompts and model selection | [.agents/human_agent_efficient_workflow.md](human_agent_efficient_workflow.md) |
| Persistent handoff queue, refactoring roadmap | [.agents/refactoring_roadmap.md](refactoring_roadmap.md) |
| Handoff tag parser script | [.agents/parse_tags.py](../../.agents/parse_tags.py) |
