# v1.4.7 — `Documentation/agents/` Duplicate Audit & Symlink Verification

**Date**: 2026-07-08
**Branch**: `next`
**Tag**: `1.4.7`
**Files changed**: `Documentation/dev/1-4-7_analyze.md` (new — this document)

---

## Background

During the agent workflow documentation refactoring session, both
`Documentation/agents/` and `.agents/` appeared to contain identical content. This
raised a maintenance concern: two directories with identical files means any edit to
one diverges silently from the other.

A full audit was performed to determine whether a real duplication existed.

---

## Audit Findings

### Finding 1: No physical duplication — symlink already in place

```bash
git ls-files -s Documentation/agents
# 120000 7bcb9556370366dca99e9c5cf5e0f12d8c719ac9 0  Documentation/agents

git show HEAD:Documentation/agents
# ../.agents

readlink Documentation/agents
# ../.agents
```

Git mode `120000` is the symlink file mode. `Documentation/agents` is not a directory
— it is a symlink pointing to `../.agents`. It was already correctly set up in the
repository before this audit. There is only one physical copy of the agent files,
stored in `.agents/`. The `Documentation/agents/` path is purely a resolution alias.

### Finding 2: The perceived duplication was path aliasing, not file duplication

The appearance of "two copies" arose because both paths resolve to the same inodes:

```
.agents/agents.md                      ← physical file
Documentation/agents/agents.md         ← resolves via symlink → same file
```

Opening either path in an editor or file manager shows identical content because they
ARE the same content. No divergence is possible at the file system level.

### Finding 3: MkDocs publication is intact and correct

The `mkdocs.yml` nav references `agents/README.md`, `agents/agents.md`, etc. under
`docs_dir: Documentation`. MkDocs resolves these through the symlink to `.agents/`
transparently. Agent workflow documentation (Elephant/Goldfish model, role definitions,
workflow guides) continues to be published to GitHub Pages without any `mkdocs.yml`
changes required.

---

## Decision: No Implementation Required

Three options were evaluated during the analysis discussion:

| Option | Description | Decision |
|--------|-------------|----------|
| A | Symlink `Documentation/agents/` → `../.agents` | ✅ Already implemented correctly |
| B | Delete `Documentation/agents/`, remove from MkDocs nav | Rejected — loses GitHub Pages publication of agent workflow docs, which are a template showcase feature |
| C | Change `docs_dir` in `mkdocs.yml` to project root | Rejected — significant restructuring risk, potential exposure of non-public files |

Option A was already the correct implementation. The audit confirmed its integrity.

---

## Source of Truth Confirmed

| Location | Role | Physical files |
|----------|------|----------------|
| `.agents/` | Authoritative agent workspace — read by Antigravity and agent tooling | ✅ Yes — real directory |
| `Documentation/agents/` | MkDocs publication alias | ❌ No — symlink only |

Any future edits to agent documentation belong exclusively in `.agents/`. The
`Documentation/agents/` symlink requires no maintenance.

---

## Notes

- The `.agents/specs/context_engineering_analysis.md` committed in the 1.4.5 cycle is
  a pre-workflow artifact predating the finalized spec workflow design (`values.md` +
  `spec.md` in `Documentation/dev/<feature>/`). It will be relocated in a future cleanup.
- The `agents` entry was verified against `.agignore` and `.gitignore` — neither
  excludes the symlink or the `.agents/` directory.
