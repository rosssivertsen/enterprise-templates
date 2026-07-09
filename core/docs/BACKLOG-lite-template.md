# {{PROJECT_NAME}} — Backlog

**Canonical ID prefix:** `{{REPO_CODE}}`
**Registry:** `sherpa-vault/docs/repo-id-registry.md`

All items use ID format `{{REPO_CODE}}-<N>`. Short form is fine inside this file (context is implicit); qualified form required on all cross-repo surfaces (Kanban boards, commit messages, PR titles, memory files, Slack).

---

## Active

- (none yet — first item will be `{{REPO_CODE}}-1`)

## Completed

- (none yet)

---

## Conventions

- **Branch naming:** `feature/{{REPO_CODE_LOWER}}-<n>-<slug>` — qualified ID in branch names enables auto-linking back to this backlog.
- **Commit messages:** lead with the qualified ID — `{{REPO_CODE}}-<n>: <subject>`.
- **New items:** append to the end of Active; IDs are monotonic. Never reuse a retired ID.
- **Completion:** strike through and move to Completed with a date.
