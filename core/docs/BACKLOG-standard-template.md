# {{PROJECT_NAME}} — Backlog

**Canonical ID prefix:** `{{REPO_CODE}}`
**Registry:** `sherpa-vault/docs/repo-id-registry.md`
**Last Updated:** {{SCAFFOLD_DATE}}

All items use ID format `{{REPO_CODE}}-<N>` or `{{REPO_CODE}}-<STREAM>-<N>` if this project adopts streams. Short form inside this file; qualified form on all cross-repo surfaces.

---

## Streams (optional — add when category justifies it)

| Prefix | Stream | Description |
|--------|--------|-------------|
| — | — | (none defined yet; add rows as categories emerge) |

---

## Priority: High

| ID | Item | Category | Effort | Notes |
|----|------|----------|--------|-------|
| (none) | | | | |

## Priority: Medium

| ID | Item | Category | Effort | Notes |
|----|------|----------|--------|-------|
| (none) | | | | |

## Priority: Low

| ID | Item | Category | Effort | Notes |
|----|------|----------|--------|-------|
| (none) | | | | |

---

## Completed

| ID | Item | Completed |
|----|------|-----------|
| (none) | | |

---

## Size Legend

| Size | Meaning |
|------|---------|
| S | < 2 hours |
| M | 2-8 hours (half day to full day) |
| L | 1-3 days |
| XL | 3+ days (should be broken down) |

---

## Conventions

- **Branch naming:** `feature/{{REPO_CODE_LOWER}}-<n>-<slug>` (or `feature/{{REPO_CODE_LOWER}}-<stream>-<n>-<slug>` with streams) — qualified ID in branch names enables sync-boards automation.
- **Commit messages:** lead with qualified ID — `{{REPO_CODE}}-<n>: <subject>` or `<type>({{REPO_CODE_LOWER}}): {{REPO_CODE}}-<n> <subject>`.
- **New items:** append to the appropriate priority table. IDs are monotonic within their stream (or within the project if no streams). Never reuse a retired ID.
- **Completion:** move row to Completed table with completion date. Keep original ID.
- **Adding a new stream:** add a row to the Streams table, then start numbering that stream's items from 1.
