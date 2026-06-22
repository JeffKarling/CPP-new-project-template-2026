# Context Engineering Analysis — Research Spec

**Status:** Accepted — drove documentation refactoring commit on `next` branch  
**Date:** 2026-06-22  
**Sources:** Karpathy/X status/2015883857489522876 · humanlayer.dev/blog/advanced-context-engineering  
**Scope:** Informed additions to `agents.md`, `GEMINI.md`, and creation of Documentation Engineer role

---

## Source Summaries

---

### 1. Karpathy on X (Jan 2026)

Andrej Karpathy shared field notes from several weeks of heavy Claude-assisted coding. Key points:

**Workflow shift**
- Went from 80% manual / 20% agent coding in November to **80% agent / 20% edits+touchups** in December — the biggest workflow change in ~2 decades.
- Is "programming in English now" — giving the LLM large "code actions." Ego hit, but the leverage is undeniable.

**IDE + hawk watching**
- Rejects both "no IDE needed" and "agent swarm" hype as premature.
- Models still make **subtle conceptual mistakes**, not syntax errors. These are much harder to catch. You must watch agents closely, in a real IDE.

**CLAUDE.md = agent memory**
- A `CLAUDE.md` file in the project root is read at every session start. It becomes the **agent's persistent memory** — project conventions, what to avoid, architectural decisions, lessons learned.
- Gives the agent "encyclopedic context" so it can operate more autonomously.

**Commits as context resets**
- He advocates committing frequently, not because of Git hygiene, but because it gives the agent a clean baseline. Each commit is an implicit **context compaction boundary**.

**Token budget and loop avoidance**
- He explicitly warns that long agent loops accumulate drift. Fresh sessions with good scaffolding outperform a single long degraded session.

---

### 2. HumanLayer — "Advanced Context Engineering for Coding Agents" (Aug 2025)

A long-form technical post by Dex (HumanLayer), grounded in months of production experience with Claude Code on real brownfield codebases (300k LOC Rust, complex Go systems code).

**The core problem**
- Stanford study + practitioner consensus: AI coding tools work well for greenfield/small tasks but are **net negative for brownfield codebases and complex systems** because of rework, tech debt, and loss of alignment.
- The defeatist response is "wait for smarter models." The author's response is: **context engineering is the solution right now.**

**Frequent Intentional Compaction (FIC)**
The core technique. Rather than letting a session degrade to context exhaustion, you deliberately structure compaction points:

1. **Re-steering**: discard the session early when off-track, restart with a refined prompt.
2. **Intentional Compaction**: before the context window fills, ask the agent to write a structured progress summary to a file (`progress.md`), capturing goal, approach, steps done, current failure. Then start fresh with that file as context.
3. **Sub-agents as compaction**: delegate search/grep/read tasks to disposable sub-agents that return dense summaries, keeping the parent agent's context clean.

**What eats context**
- File search, understanding code flow, applying edits, test/build logs, huge tool JSON blobs.
- All of these can be compacted into structured artifacts that feed the next session.

**Context quality equation**
`Output Quality ∝ (Correctness × Completeness) / Noise`

Worst things for your context window, in order:
1. Incorrect information
2. Missing information
3. Too much noise

**Spec-driven development**
- References Sean Grove's "specs are the new code" insight: throwing away prompts while only committing code is like compiling a JAR and checking in the binary while deleting the source.
- Specs should be version-controlled as the primary artifact of development. Code becomes the "compiled output."

**Human-in-the-loop review**
- FIC naturally creates **review gates** at compaction boundaries — the human reads the structured summary before the next session starts.
- They found 8 weeks of discomfort transitioning to spec-driven review (reading tests + specs, not every line of PR code) before it started flying.

**Sub-agent context architecture**
- Sub-agents are not about role-playing; they are purely about **context isolation**. A sub-agent burns its context window doing discovery work; the parent gets a dense summary and stays fresh.

---

## Relationship to template2026

---

### Where the design is strongly validated

#### CLAUDE.md / GEMINI.md as persistent agent brain
Karpathy's `CLAUDE.md` insight is precisely what this template implements with `GEMINI.md` + `agents.md`. The template goes further by splitting:
- **Behavioral rules** (`GEMINI.md`) — what the agent always does
- **Role catalogue** (`agents.md`) — who the agent is in this phase

This is a more principled structure than a single flat `CLAUDE.md`.

#### Goldfish = Intentional Compaction boundary
HumanLayer's "frequent intentional compaction" and the Goldfish model describe the **same operational reality** from different angles. Each Goldfish session is a compaction unit: it receives dense, pre-structured context, does focused work, and produces artifacts that survive it.

#### Handoff artifacts as compacted state
The `//ATR:` / `//DIS:` tag system + `parse_tags.py` + `refactoring_roadmap.md` is a project-level implementation of "compaction output." This goes further than HumanLayer's `progress.md` pattern by capturing observations *between* sessions — when no AI session is open — which neither source addresses.

#### Human orchestration as review gate
Both Karpathy and HumanLayer independently arrive at the same conclusion: you cannot trust an autonomous long-running agent in code you care about. The template's human-in-the-loop orchestration — developer reads the pipeline, activates the next role, merges branches manually — is exactly right for solo or small-team.

#### Spec-driven development alignment
HumanLayer's embrace of "specs are the new code" maps onto the intent behind `agents.md` role definitions and `human_agent_efficient_workflow.md`. Throwing away prompts while only committing C++ is like discarding the `.agents/` directory. The template's insistence on version-controlling the entire `.agents/` workspace is already spec-driven development in practice.

---

### Gaps identified — drove changes in this refactoring

| Gap | Action taken |
|---|---|
| `GEMINI.md` vs `agents.md` values/scope conflict not documented | Added "values versus review protocol" clarification to both documents |
| "Specs are code" principle not explicitly stated anywhere | Added as universal principle in `agents.md` + `GEMINI.md` |
| No Documentation Engineer role | Created new role in `agents.md` |
| Intra-phase compaction trigger not documented | Deferred — added to `refactoring_roadmap.md` as `//ATR:` |
| Sub-agent isolation pattern absent | Deferred — future role/workflow addition |
| Commit frequency as context hygiene not documented | Added note to `human_agent_efficient_workflow.md` |

---

## Summary Table

| Concept | Karpathy | HumanLayer | template2026 | Gap? |
|---|---|---|---|---|
| Persistent agent brain file | `CLAUDE.md` | System prompt / `AGENTS.md` | `GEMINI.md` + `agents.md` | ✅ Well covered, more structured |
| Context compaction | Commit-as-reset | Frequent Intentional Compaction | Phase-boundary Goldfish lifecycle | Partial — no intra-phase trigger |
| Human review gate | Watch in IDE | Compaction boundary review | Role-branch merge + human activation | ✅ Well covered |
| Sub-agent isolation | Not discussed | Core technique | Not yet present | ❌ Gap |
| Cross-session state | Not discussed | `progress.md` pattern | `//ATR:` tags + roadmap | ✅ More robust than both |
| Spec-driven development | Implicit | Explicit (Sean Grove ref) | Implicit in `.agents/` design | Resolved — now explicit |
| Commit frequency for context | ✅ Explicit | Not discussed | Not documented | Resolved — now documented |
