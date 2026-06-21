# Cross-Session State, Extending In-Session AI Planning

This document is written for users already familiar with Antigravity's built-in planning workflow. It explains the gap that workflow leaves open, and how the `//ATR:` and `//DIS:` tag system combined with `refactoring_roadmap.md` fills it at the project level.

---

## In-Session Planning, What Antigravity Provides

When a complex task is delegated to Antigravity, the agent generates a set of structured planning artifacts automatically:

- `implementation_plan.md`: A technical design document describing the proposed changes. Created before execution begins and updated if significant deviations occur.
- `task.md`: A living checklist of sub-tasks, updated in real time as the agent works through each step.
- `walkthrough.md`: A post-execution summary of what was changed, what was tested, and what was verified.

These artifacts are powerful within their scope. They give the agent a structured working memory and give the developer a clear audit trail of what happened during the session.

However, all three artifacts share a critical characteristic: **they are created during an active AI session and their useful life ends when that session ends.** They are intra-session tools. Once the conversation is closed, they become static history documents. They do not carry deferred observations forward into future sessions, and they have no mechanism for capturing work that was noticed *outside* of an AI session.

---

## The Gap, Out-of-Session Observations

Consider the following scenario: a developer is writing C++ code in CLion at their workstation. No AI session is open. During this coding work, two things are noticed:

1. A class is growing beyond a single clear responsibility. It should eventually be split, but splitting it now would derail the current implementation task.
2. A design question arises about the best threading strategy for a new module. The answer is not obvious and requires deliberation, but the current task is not the right moment.

There is no `task.md` to update. There is no AI agent to tell. The in-session planning infrastructure does not exist yet. If these observations are not captured immediately, they are likely to be forgotten by the time an AI session opens.

This is the gap the in-session tools cannot address: **structured, durable capture of observations made by a human developer outside of any active AI session.**

---

## The Project Solution, Inline Tags and the Persistent Queue

This template bridges the gap with two cooperating mechanisms.

### Inline Comment Tags

Two tag formats are recognized across C++ source files and documentation:

```cpp
//ATR: Split DatabaseScanner into a dedicated CMake target — consumed externally by tbbAlgos.
//DIS: Should WorkerPool use a condition_variable or a blocking queue for task dispatch?
```

- `//ATR:` (Add to Refactor): Marks a concrete, deferred task. The author knows what needs doing and is deliberately queuing it for a future session rather than acting on it now.
- `//DIS:` (Design Discussion): Marks an open architectural question. The answer is not known and requires deliberation before work proceeds.

Both tags are inserted directly at the point of observation — inside the source file, on the line or block where the issue lives. No separate document needs to be opened. No AI session needs to be active. The observation is anchored to its exact location in the codebase.

### The Persistent Roadmap Queue

The tag parser consolidates all tags across the entire codebase into a single state file:

```bash
python3 .agents/parse_tags.py
```

Running this command scans `srcTargets/` and `Documentation/`, extracts every `//ATR:` and `//DIS:` entry, and writes them to [refactoring_roadmap.md](refactoring_roadmap.md) with their source file paths and line numbers. The roadmap becomes the **unified inbox** for all deferred observations regardless of when or by whom they were written.

This file lives in the project repository. It is version-controlled, survives across sessions, and is available to any future AI agent or developer who opens the project.

---

## Comparison, In-Session vs. Cross-Session State

| Dimension | Antigravity in-session tools | This template's tag system |
| :--- | :--- | :--- |
| Created during | Active AI session | Any time, including outside sessions |
| Author | AI agent | Human developer, AI agent |
| Survives session end | No, becomes static history | Yes, persisted in git repository |
| Scope | Single conversation | Entire project lifetime |
| Location | Conversation artifact directory | `.agents/refactoring_roadmap.md` in the repo |
| Triggered by | Complex task request | Developer noticing something, agent noticing something |
| Consumed by | The agent that created it | Any future AI session or developer |
| Primary purpose | "What am I doing right now?" | "What have I noticed that needs doing later?" |

---

## How Both Layers Work Together

The two systems are not competing alternatives. They operate at different time horizons and serve complementary purposes within a single development cycle:

```
Human codes in CLion              Agent executes a role task
       |                                      |
  //ATR: tag inserted              //ATR: tag inserted (optional)
  to source file                   to source file
       |                                      |
       |                            session ends, task.md
       |                            becomes static history
       |                                      |
       └──────────── parse_tags.py ───────────┘
                            |
                   refactoring_roadmap.md
                   (cross-session queue)
                            |
               New AG session opens:
               agent reads roadmap,
               creates implementation_plan.md
               for the next task
```

The in-session tools handle the active execution. The tag system handles the quiet observation made between sessions. Both feed the same development cycle. Neither replaces the other.

---

## Practical Workflow

1. Code in CLion. When something is noticed that does not belong in the current task, insert `//ATR:` or `//DIS:` at the relevant line and continue.
2. When ready to review the accumulated observations, open an Antigravity session and run the tag parser:
   ```bash
   python3 .agents/parse_tags.py
   ```
3. Review [refactoring_roadmap.md](refactoring_roadmap.md) with the agent. Prioritize items, ask the agent to elaborate on `//DIS:` entries, and decide which items to promote to active tasks.
4. For promoted items, the agent creates an `implementation_plan.md` for that specific task and begins in-session execution. The in-session planning tools take over from this point.
5. After execution, the agent marks completed roadmap items as `[x]`. Observations that arose during the session and were tagged `//ATR:` will appear in the next parse run.

This cycle ensures that nothing noticed during active coding is lost between sessions, and that AI planning tools are applied precisely where they are designed to operate: within an active, focused execution session.
