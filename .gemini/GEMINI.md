# Gemini Agent Behavioral Rules, Performance-First Engineering

This document establishes the performance-first behavioral rules and instructions for Gemini AI agents working in this project.

## How to Read This Document

This document encodes **engineering values and quality orientation** — it defines how agents think and what they prioritize when making decisions within their assigned scope. It is not a task warrant. It does not grant permission to act outside the scope defined by `agents.md`.

The relationship between the two documents is:
- `GEMINI.md` (this file): the engineer's values — *how to think*
- `agents.md`: the team's review protocol — *what to act upon in this session*

A C++ Engineer who reads Rule 1 below should design cache-friendly data structures as a matter of craftsmanship. The same engineer who notices a performance problem in another module should queue it via `//ATR:` for the Performance Engineer — not act on it. The value (performance-first) does not override the scope (C++ Engineer task boundary). Both are true simultaneously.

## Specs Are Code

Agent workflow documents, role definitions, research specs, and design decisions stored in `.agents/` are the **primary source of truth** for this project. The C++ source code in `srcTargets/` is the compiled output of that specification work.

Consequences of this principle:
1. All spec files in `.agents/` are version-controlled with the same discipline as source code. They are never discarded after use.
2. Research artifacts and analyses that drive workflow changes are saved to `.agents/specs/` before any code changes are made. The spec is committed first.
3. Throwing away a prompt, analysis, or design document while only committing the resulting code is equivalent to compiling a binary and deleting the source. This is prohibited.
4. When an agent produces a plan, walkthrough, or analysis that materially influences the project, that artifact belongs in the repository — not only in the conversation history.

## Core Rules, Performance Optimization

1. Optimization Priority: All code design and implementation must prioritize runtime performance, cache friendliness, thread scaling, and hardware capability utilization.
2. Build Configuration: Default compilation must leverage modern optimization flags. When testing or verifying changes, use release builds via the unified build script to ensure valid performance measurements.
3. Memory and Cache Friendliness: Design data structures to ensure contiguous memory access. Avoid false sharing in multithreaded components by utilizing padding and cache-line alignment.
4. Primary Preset Target: AI agents must primarily configure, compile, and run the project using custom build presets (containing "Custom" in the name, e.g. `GNU_Custom_Debug`, `OneApi_Custom_RelWithDebInfo`) to leverage target-specific hardware optimizations (-march=native, -xhost) and debugging diagnostics. Default presets (containing "Default" in the name) must only be used as a secondary check to guarantee consumer portability.

## Profile-Guided Optimizations

1. Performance Diagnostics: Utilize the Linux perf profiling skill to gather hardware counters and identify performance bottlenecks.
2. Hotspot Reporting: Provide structured hotspot reports highlighting the top CPU-consuming functions, annotated assembly, and pattern-based observations.
3. CPU Capability Check: Always check CPU capabilities before generating SIMD instructions to ensure compatibility and maximum instruction-width usage.
