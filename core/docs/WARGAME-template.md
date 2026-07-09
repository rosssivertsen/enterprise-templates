# WARGAME Convention — Agent-Agnostic Pre-Simulation Standard

> **Harness-agnostic by design.** A wargame is plain markdown + a folder convention. The executor contract is: *can read files, can follow a brief*. Any agent qualifies — Claude Code, OpenClaw/Hermes, Codex, a local model behind LiteLLM. No tool dependency, no vendor syntax.
>
> Sits beside `AGENTS.md` at the agnostic layer of the project-standards stack. Rationale + provenance: `sherpa-vault/memory/knowledge/pattern-studies/kashef-wargaming-as-execution-primitive-2026-07-06.md`.

## When to wargame

Wargame a mission when it is **irreversible or production-touching, fork-rich, and executing within ~2–3 weeks**. Do NOT wargame: decisions a human must make, reading/learning tasks, one-shot admin with an existing checklist, or work months from execution (wargames rot — see Staleness).

**Division of labor:** the *wargamer* is the strongest available reasoner; the *executor* is whatever is cheap and present where the work runs; the *red-teamer* is a different model/instance than the wargamer.

## Folder convention (per project)

```
docs/wargames/
├── tasks/<mission>.md      # WARGAME ORDER + mission brief (template below)
├── <mission>.md            # the battle plan the wargamer writes
├── SUCCESS.md              # the 8-point pass standard (below)
└── LEDGER.md               # blocked inputs, self-grades, patches, staleness
```

## The WARGAME ORDER template (`tasks/<mission>.md`)

```markdown
WARGAME ORDER. You are not executing this mission, you are wargaming it.
A cheaper executor ({{EXECUTOR MODEL/AGENT}}) runs the brief below later.
Your job is the route it will follow.

Recon first, read-only: {{WHAT TO INSPECT — systems, configs, docs the mission touches}}.

Then fight the mission on paper, move by move, and write it to docs/wargames/{{mission}}.md:

- every move states its expected observation — exactly what you should see if it worked
- every move carries its most likely failure, the cause it signals, and the counter-move
- every fork gets a trigger: if you observe X, take route B — no judgment calls left to the executor
- assumptions recon could not settle get marked RECON NEEDED with the exact check that settles it
- end with abort conditions, and the verification runs the executor must perform with what pass looks like for each

Write it so the executor can run the brief end to end without asking a single question.
Record anything you cannot resolve as {{BLOCKED: what input is needed}} in docs/wargames/LEDGER.md
— never assume a value for a blocked input.

=== THE MISSION BRIEF (the executor's orders, not yours) ===

{{THE ACTUAL TASK, SPECIFIED PRECISELY: goal, constraints, environment,
what done looks like, and the testing paths the plan must exercise.}}
```

## SUCCESS.md — the 8-point pass standard

A wargame passes only when ALL eight hold:

1. Every move states its expected observation — exactly what you should see if the move worked.
2. Every move carries its most likely failure, the cause that failure signals, and the counter-move.
3. Every fork has a trigger. If you observe X, take route B. No judgment calls left to the executor.
4. Every assumption recon could not settle is marked RECON NEEDED with the exact check that settles it.
5. Abort conditions exist — the moments to stop and flag rather than improvise.
6. Verification is spelled out: which runs the executor performs, when, and what pass looks like for each.
7. It has survived a red-team pass **by a different model/instance than the wargamer**. The doc records the attack that failed against it, and the patch born from the attack that did not.
8. It is executable blind. A mid-tier model could run the mission end to end without asking a single question.

## LEDGER.md format

One entry per mission:

```markdown
## <mission> — wargamed YYYY-MM-DD by <model/agent>
- **stale_after:** YYYY-MM-DD (default: wargame date + 21 days)
- **Blocked inputs:** {{BLOCKED: ...}} items surfaced, each with who/what unblocks it
- **Self-grade vs SUCCESS.md:** point-by-point pass/fail
- **Red-team record:** attack that failed / attack that landed + patch
- **Patches:** every refinement made after first draft, dated
- **Execution record:** (filled by executor) date, agent, outcome, deviations from plan
```

## Staleness — the failure mode

A wargame is a snapshot of assumed reality; it decays as the environment moves. Rules:

- **Executor MUST check `stale_after` before running.** Past date → re-recon before execution; do not run a stale plan blind.
- If the environment moved since the wargame (version bumps, config changes, infra reboots), re-verify the affected moves' assumptions first.
- **A failed expected-observation is a dual signal:** the move failed, OR the wargame is stale. Two consecutive expected-observation misses = abort condition — stop and flag; do not improvise past a plan that no longer matches reality.

## Executor contract (any agent)

1. Read `docs/wargames/<mission>.md`, `SUCCESS.md`, and the mission's LEDGER entry before acting.
2. Refuse to start if: LEDGER has unresolved `{{BLOCKED}}` inputs, `stale_after` has passed without re-recon, or the wargame fails any SUCCESS point.
3. Follow moves in order; at each fork, match the observed trigger — never improvise a route.
4. On abort condition: stop, write what was observed to the LEDGER execution record, and surface to the human. Do not push past an abort.
5. On completion: run every verification listed, then fill the LEDGER execution record (outcome + any deviations).
