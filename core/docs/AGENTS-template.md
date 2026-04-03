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

## 0. Delivery Principles

Three pillars guide every decision — what to build, how to build it, and when to abstract.

### Repeatability
If solving a problem for the second time, abstract it into a reusable tool. If the first time, solve it and document the pattern. If the third time and no reusable tool exists, that's a process failure. Invest upfront in planning when a repeatable pattern is likely — speed to delivery is an outcome of repeatability done well.

### Reliability
Double-check, triple-check. Dry runs before production. Reconciliation after every batch. End-to-end source document traceability — every output traces back to its source input. Audit trail is a deliverable, not an afterthought. Zero-error tolerance where achievable.

### Scalability
Will this approach work at 10x volume? Design for the next order of magnitude. If a solution works for 50 records but breaks at 500, document the breakpoint and plan the upgrade path.

### Security (CIA Triad)
- **Confidentiality** — credentials in env vars or secret stores, never in committed files. Principle of least privilege.
- **Integrity** — data validated at input and verified at output. Checksums, reconciliation, source verification.
- **Availability** — crash-resilient state files, documented recovery procedures, no single points of failure in automation.

### Build vs. Script Decision Rule
> **First time** → solve it, document the pattern.
> **Second time** → abstract into a reusable tool.
> **Third time** → it should already be a tool.

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

## 4. Document Generation

### Standard Tool: OfficeCLI

All projects use `officecli` for generating Word (.docx), Excel (.xlsx), and PowerPoint (.pptx) deliverables. No npm packages (`docx`, `exceljs`, `pptxgenjs`), no Python libraries (`python-docx`, `openpyxl`), no custom scripts.

**Why:** Single binary, zero dependencies, no Office installation required. Any agent can produce documents with shell commands or JSON batch — no language-specific libraries to install or maintain.

**Installation:** `curl -fsSL https://raw.githubusercontent.com/iOfficeAI/OfficeCLI/main/install.sh | bash`

**Key commands:**
```bash
officecli create report.docx                    # Create blank document
officecli open report.docx                      # Resident mode (fast multi-op)
officecli add report.docx /body --type paragraph --prop text="..." --prop style=Heading1
officecli batch report.docx --json < ops.json   # Batch operations
officecli view report.docx outline              # Inspect structure
officecli view report.docx text                 # Extract text
officecli validate report.docx                  # Schema validation
officecli close report.docx                     # Save and release
```

**Batch pattern:** For reports with tables and structured data, build a JSON array of operations and pipe to `officecli batch`. This keeps the document definition declarative and data-driven.

**When NOT to use:** Reading existing Excel data files for analysis — pandas/openpyxl remain the right tool for data processing. OfficeCLI is for *producing* deliverables, not ETL.

---

## 5. Quality Standards

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

## 6. Handoff Standards

Any work product should be resumable by a different agent or human. This means:

- **State files** capture exact progress (not "about halfway done")
- **SESSION_LOG.md** has enough context to resume without the original agent
- **Scripts are idempotent** where possible (re-running doesn't duplicate work)
- **Credentials and secrets** are never in committed files — reference env vars or secret stores

---

## 7. Communication

### With the Project Owner
- Be autonomous but transparent
- Make decisions and explain them — don't ask for permission on routine choices
- Escalate when: the scope changes, costs exceed estimates, or errors are unrecoverable
- Alert before mass deletions or secret exposure

### Bias Awareness
- **Always challenge the project owner's thinking.** Don't agree reflexively. If an assumption, sequence, or scope seems off, say so.
- **Name the bias when you spot one.** Common biases to watch for:
  - **Confirmation bias** — seeking evidence that supports a decision already made
  - **Sunk cost fallacy** — continuing an approach because of time already invested, not because it's the best path forward
  - **Anchoring** — over-weighting the first number or approach proposed
  - **Scope creep** — expanding the work beyond what was asked without acknowledging the trade-off
  - **Recency bias** — over-weighting the most recent data point or experience
  - **Availability bias** — assuming a solution that worked last time is the right one this time
- **Frame challenges constructively:** "Here's what I'd push back on" not "you're wrong." Propose alternatives with reasoning.
- **Ask clarifying questions** before executing when the direction seems driven by assumption rather than evidence.
- This is not optional. The project owner expects to be challenged. Unchallenged decisions are a risk.

### With Other Agents
- Suffix entries with your agent name in shared logs (e.g., `— Claude`, `— Codex`, `— Gemini`)
- Read other agents' entries before writing your own — don't overwrite or contradict
- If you disagree with a prior decision, note your reasoning and flag for the project owner
