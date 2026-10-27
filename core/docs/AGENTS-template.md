# AGENTS.md

> Agent-agnostic project standards. Any AI assistant (Claude, Gemini, OpenAI, Codex,
> Perplexity, or custom agents) should read this file when working on this project.
> Platform-specific files (CLAUDE.md, GEMINI.md) extend these standards — they do not
> replace them.

## Project Identity

- **Name:** {{PROJECT_NAME}}
- **Language:** {{LANGUAGE}}
- **Tier:** {{TIER}}

## Project Context

> Project facts live here, not in CLAUDE.md / GEMINI.md, so every agent sees them.

### Overview

_What this project does, who it is for, and who owns it. Replace this line._

### Commands

#### Development
{{COMMANDS_DEV}}

#### Testing
{{COMMANDS_TEST}}

#### Deployment
{{COMMANDS_DEPLOY}}

### Architecture

{{ARCHITECTURE}}

### Hard Rules

_Project-specific constraints every agent must follow: data that must never be committed, systems that are read-only, actions that need the owner's approval. Replace this line, or write "None"._

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

**Agent attribution:** several agents may work on this project. Every entry heading names the agent that wrote it, e.g. `## 2026-10-27 — Repository setup — Claude` (or `— Codex`, `— Gemini`, `— <human name>`). Read entries by other agents before writing your own; don't rewrite them. If you disagree with one, say so in your own entry.

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

## 5. Model Routing

### Standard Router: LiteLLM

All agents that need to call an LLM go through **LiteLLM** at `https://litellm.lrs.ai/v1` (or `http://127.0.0.1:4000/v1` on-DGX). Never instantiate a direct provider SDK (`from anthropic import Anthropic`, `from openai import OpenAI` against api.openai.com, etc.) inside CCE agent code.

**Why:** Single binary surface, unified billing layer, per-agent attribution via virtual keys, ability to route to the local inference cluster (DGX Spark + GX10) for free marginal cost when frontier capability isn't required, and the alias contract means backends can move without touching agent code.

**Doctrine reference:** `sherpa-vault/memory/claude-memory/feedback_litellm_only_for_cce_agents.md`
**Alias contract (what each model name means):** `sherpa-vault/projects/clustered-inference/09-alias-contract.md`
**VK provisioning SOP:** `sherpa-vault/projects/clustered-inference/10-agent-vk-sop.md`

### Per-agent Virtual Key (required)

Every new agent gets its own VK:

- **Named** `cce-<agent-name>` (kebab-case)
- **Scoped** to an explicit allowlist of aliases from the contract (never `all-team-models`)
- **Budget-capped** monthly (even if small — $10 minimum, no uncapped new VKs)
- **Tagged** `app=<agent-name>` for Langfuse trace attribution

Provision via the SOP. The VK arrives in the agent's `.env` as `LITELLM_VK_<AGENT_UPPER>` (mode 600, never committed).

### Agent code pattern

```python
import os, sys, openai

# Mandatory: fail loud at startup if env is empty (per feedback_env_substitution_silent_fail)
for var in ("LITELLM_BASE_URL", "LITELLM_VK_<AGENT_UPPER>"):
    if not os.environ.get(var):
        sys.exit(f"FATAL: {var} is empty. See 10-agent-vk-sop.md.")

client = openai.OpenAI(
    base_url=os.environ["LITELLM_BASE_URL"],
    api_key=os.environ["LITELLM_VK_<AGENT_UPPER>"],
)

# Ask for an alias from the contract — NOT a raw provider model name.
resp = client.chat.completions.create(
    model="reasoner",   # or workhorse, coding, frontier, research, multimodal, bulk
    messages=[...],
)
```

### Picking an alias

From the contract — three questions answer it:

1. Needs current web information? → `research`
2. Needs image/video input? → `multimodal`
3. Otherwise: `workhorse` (default), `reasoner` (deep thinking), `coding` (code gen), `frontier` (quality-critical), `bulk` (high-volume cheap), `workhorse-context` (>32K context).

**Default to local tier.** Cloud aliases (`frontier`, `frontier-pinnacle`, `research`, `bulk`, `multimodal`) are for the 20% of work that genuinely needs them. Cluster is for the 80%.

### Exception: `claude` CLI agents

If your agent runs via the `claude` CLI binary (Pro/Max subscription) instead of needing a provider API key, this rule does not apply — `claude` CLI handles its own auth and rides flat-rate subscription. Examples: overnight-research, batch-route, email-agent classifier. These stay as-is.

The rule applies when you would *otherwise* reach for `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `PERPLEXITY_API_KEY`, etc. in the agent's `.env`.

### Anti-patterns

- `from anthropic import Anthropic` at the top of agent code — replace with `openai.OpenAI(base_url=LITELLM_URL, ...)`
- Sharing a VK across agents — kills attribution; mint one per agent
- Hardcoded model strings like `claude-sonnet-4-6` in agent code — use the alias (`frontier`) so backends can move
- Catching a LiteLLM 401/404 and silently falling back to a direct provider SDK — defeats the doctrine; fail loud

---

## 6. Quality Standards

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

### Wargaming (pre-simulation for high-risk missions)
Missions that are **irreversible or production-touching, fork-rich, and executing within ~2–3 weeks** get a wargame before execution: a move-by-move pre-simulation with expected observations, failure countermoves, fork triggers, abort conditions, and verification runs, written so any executor agent can run it blind. Convention, templates, and executor contract: `docs/wargames/` per `WARGAME-template.md` (this directory). Agent-agnostic by design — the artifact is plain markdown; any agent that can read files can execute it.

---

## 7. Handoff Standards

Any work product should be resumable by a different agent or human. This means:

- **State files** capture exact progress (not "about halfway done")
- **SESSION_LOG.md** has enough context to resume without the original agent
- **Scripts are idempotent** where possible (re-running doesn't duplicate work)
- **Credentials and secrets** are never in committed files — reference env vars or secret stores

---

## 8. Communication

### With the Project Owner
- Be autonomous but transparent
- Make decisions and explain them — don't ask for permission on routine choices
- Escalate when: the scope changes, costs exceed estimates, or errors are unrecoverable
- Alert before mass deletions or secret exposure

### People, Process, Tools
Every solution must be framed in all three dimensions — never just one. If the conversation is only about the tool, ask "who does this affect and what process does it change?" If the process is clear but the tooling is being over-architected, ask "is this the simplest tool that serves the process?" If neither the person nor the process has been named, the solution isn't ready.

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
