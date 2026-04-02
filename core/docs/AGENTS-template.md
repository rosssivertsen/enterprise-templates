# AGENTS.md

> Agent-agnostic project standards. Any AI assistant (Claude, Gemini, OpenAI, Codex,
> Perplexity, or custom agents) should read this file when working on this project.
> Platform-specific files (CLAUDE.md, GEMINI.md) extend these standards — they do not
> replace them.

## Project Identity

- **Name:** {{PROJECT_NAME}}
- **Language:** {{LANGUAGE}}
- **Tier:** {{TIER}}

---

## 1. Session Discipline

### Session Log

Every project maintains `docs/SESSION_LOG.md` as a living progress journal.

**On session start:** Read `docs/SESSION_LOG.md` to restore context.
**During work:** Update at every meaningful progress point — not just at session end.
**On session end:** Ensure the log reflects what was done, decided, and learned.

Each session entry must include:

| Section | Purpose |
|---------|---------|
| **Goal** | What this session set out to accomplish |
| **Timeline** | Chronological actions and outcomes |
| **Key Discoveries** | Things learned that affect future work |
| **Decisions Made** | Choices and their rationale |
| **Decisions Pending** | Blockers needing stakeholder input |
| **Action Items** | Checklist of next steps |
| **Files Created/Modified** | What changed |
| **Metrics** | Items processed, errors, time invested (for ROI tracking) |

Newest entries at the top. Never delete old entries.

### State Files

For long-running or interruptible work, maintain a JSON state file (e.g., `migration-state.json`, `batch-state.json`) that captures exact pickup points. Any agent should be able to read the state file and continue the work.

---

## 2. ROI Tracking

Every project must produce quantifiable results. Track these metrics throughout execution:

### During Execution (in SESSION_LOG.md)

- **Items processed** per session
- **Errors** per session
- **Wall-clock time invested** (estimate per session)
- **Manual equivalent** (how long would this have taken a human?)

### At Completion (in docs/ROI-ANALYSIS.md)

Use the ROI Framework Template to produce:

| Section | Content |
|---------|---------|
| **A. Baseline** | Manual effort estimate (hours, cost, error rate) |
| **B. Investment** | Actual automation effort (hours, costs per session) |
| **C. Results** | Efficiency gains, quality metrics, risk reduction |
| **D. Reuse Value** | Future run projections, annual savings |
| **E. Summary Card** | Portfolio-ready headline metrics |

**Headline metrics every project must report:**
- Items processed / dollar value handled
- Labor hours saved (% reduction)
- Cost saved (% reduction)
- Error rate (actual vs manual estimate)
- Reuse potential (estimated annual savings)

---

## 3. Continuous Improvement (Plus/Delta)

At project completion, produce `docs/PLUS-DELTA-POSTMORTEM.md`:

### Plus (What Worked)
- List practices that should be repeated
- Cite the lean principle each embodies (poka-yoke, jidoka, PDCA, etc.)

### Delta (What to Change)
- List specific, actionable changes — not vague aspirations
- For each delta, specify:
  - **What** to change
  - **Why** (root cause, not symptom)
  - **Where to implement** (which template, standard, or process)
  - **Applies to** (this project only, or all future projects)

### Generalizable Changes
- Extract deltas that apply beyond this project
- These become updates to the enterprise templates or shared standards

---

## 4. Quality Standards

### Data Integrity
- Verify inputs before processing (dry runs, checksums, schema validation)
- Verify outputs after processing (reconciliation, spot checks)
- Report variance explicitly — "$0.00 variance" is a result, not an assumption

### Error Handling
- Define an error threshold per batch/operation
- Log every error with context (what failed, why, what was attempted)
- Never silently skip failures

### Audit Trail
- Every batch produces a report (CSV, JSON, or structured log)
- Reports include: items processed, items skipped, items errored, totals, timestamps
- Reports are committed to the repository

---

## 5. Handoff Standards

Any work product should be resumable by a different agent or human. This means:

- **State files** capture exact progress (not "about halfway done")
- **SESSION_LOG.md** has enough context to resume without the original agent
- **Scripts are idempotent** where possible (re-running doesn't duplicate work)
- **Credentials and secrets** are never in committed files — reference env vars or secret stores

---

## 6. Communication

### With the Project Owner
- Be autonomous but transparent
- Make decisions and explain them — don't ask for permission on routine choices
- Escalate when: the scope changes, costs exceed estimates, or errors are unrecoverable
- Alert before mass deletions or secret exposure

### With Other Agents
- Suffix entries with your agent name in shared logs (e.g., `— Claude`, `— Codex`, `— Gemini`)
- Read other agents' entries before writing your own — don't overwrite or contradict
- If you disagree with a prior decision, note your reasoning and flag for the project owner
