# {{PROJECT_NAME}} — Backlog

**Project:** {{PROJECT_NAME}}
**Canonical ID prefix:** `{{REPO_CODE}}`
**Registry:** `sherpa-vault/docs/repo-id-registry.md`
**Last Updated:** {{SCAFFOLD_DATE}}
**Governance:** Lex Immutabilis (`sherpa-vault/memory/claude-memory/reference_data_governance_lex_immutabilis.md`) — schema changes require a governance event; no silent namespace drift.

All items use ID format `{{REPO_CODE}}-<STREAM>-<N>` (streams are required at production tier for category discipline). Short form (`<STREAM>-<N>`) is acceptable inside this file; qualified form (`{{REPO_CODE}}-<STREAM>-<N>`) required on all cross-repo surfaces (Kanban boards, commit messages, PR titles, memory files, Slack, external docs).

---

## Streams

| Prefix | Stream | Description |
|--------|--------|-------------|
| — | — | (define streams for this project before first item is created — e.g., DL=Data Layer, IN=Infrastructure, AQ=Application Query, EIA=Enterprise Info Architecture, SA=Security Audit) |

*Adding a new stream is a governance event — append a row here, log in `sherpa-vault/memory/daily-logs/improvement-log.md` before first use.*

---

## Priority: High

### {{STREAM_EXAMPLE}}

| ID | Item | Category | Effort | Notes |
|----|------|----------|--------|-------|
| (none) | | | | |

---

## Priority: Medium

| ID | Item | Category | Effort | Notes |
|----|------|----------|--------|-------|
| (none) | | | | |

---

## Priority: Low

### Pre-Production Hardening

| ID | Item | Category | Effort | Notes |
|----|------|----------|--------|-------|
| PH-1 | | Security | | |

---

## Security Audit Findings

*Populate as audits are conducted. Format: severity + finding + mitigation.*

| ID | Severity | Item | Category | Effort | Notes |
|----|----------|------|----------|--------|-------|
| (none) | | | | | |

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

### ID discipline (governed by Lex Immutabilis)

- **Branch naming:** `feature/{{REPO_CODE_LOWER}}-<stream>-<n>-<slug>` — qualified ID in branch names enables sync-boards automation and PR auto-linking.
- **Commit messages:** lead with qualified ID — `<type>({{REPO_CODE_LOWER}}): {{REPO_CODE}}-<STREAM>-<n> <subject>`.
- **PR titles:** `{{REPO_CODE}}-<STREAM>-<n>: <subject>`.
- **Never coin an ID on a commit without adding it to this file** — that was the SPK-DW-6 collision pattern. Add row → commit → reference.
- **New items** append to the appropriate priority + stream table. IDs are monotonic within `<STREAM>`. Never reuse a retired ID.
- **Completion:** strike through in-place OR move row to Completed table with completion date. Keep original ID.
- **Retiring an item:** note in the Completed table with status "RETIRED" + reason. Do NOT delete — IDs are immutable once minted.

### Governance events (all require improvement-log entry)

- Adding a new stream
- Changing any stream's meaning
- Retiring any ID
- Migrating this project to a different REPO-CODE (should never happen; would break cross-references everywhere)

### Cross-references

- **Kanban board (if one exists for this project):** link here.
- **Related repos:** list with their REPO-CODE + canonical BACKLOG path.
- **External dependencies:** note contracts/APIs/schemas.
