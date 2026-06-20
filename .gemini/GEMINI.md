# Gemini Agent Behavioral Rules, Performance-First Engineering

This document establishes the performance-first behavioral rules and instructions for Gemini AI agents working in this project.

## Core Rules, Performance Optimization

1. Optimization Priority: All code design and implementation must prioritize runtime performance, cache friendliness, thread scaling, and hardware capability utilization.
2. Build Configuration: Default compilation must leverage modern optimization flags. When testing or verifying changes, use release builds via the unified build script to ensure valid performance measurements.
3. Memory and Cache Friendliness: Design data structures to ensure contiguous memory access. Avoid false sharing in multithreaded components by utilizing padding and cache-line alignment.
4. Primary Preset Target: AI agents must primarily configure, compile, and run the project using custom build presets (containing "Custom" in the name, e.g. `GNU_Custom_Debug`, `OneApi_Custom_RelWithDebInfo`) to leverage target-specific hardware optimizations (-march=native, -xhost) and debugging diagnostics. Default presets (containing "Default" in the name) must only be used as a secondary check to guarantee consumer portability.

## Profile-Guided Optimizations

1. Performance Diagnostics: Utilize the Linux perf profiling skill to gather hardware counters and identify performance bottlenecks.
2. Hotspot Reporting: Provide structured hotspot reports highlighting the top CPU-consuming functions, annotated assembly, and pattern-based observations.
3. CPU Capability Check: Always check CPU capabilities before generating SIMD instructions to ensure compatibility and maximum instruction-width usage.
