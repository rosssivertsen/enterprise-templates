# Subscription ROI Review — Monthly

**Purpose:** Answer four decisions about every recurring subscription, fast.
Run time: **~20 minutes/month**. Keep it lightweight — this is a decision tool, not an audit.

**Decisions this review answers:**
1. **Keep** — still earning its money
2. **Cut** — not earning its money; cancel
3. **Consolidate** — overlaps with another sub; fold work into that one
4. **Upgrade / Downgrade** — tier is wrong

---

## Metadata

- **Review period:** `YYYY-MM-01` to `YYYY-MM-DD`
- **Reviewed by:**
- **Review date:**
- **Total monthly spend (before review):** `$___`
- **# of active subscriptions:** `__`

---

## Per-Subscription Block

*Duplicate this block for each sub. Keep answers to one line where possible — if you're writing paragraphs, you're over-thinking it.*

### [Subscription name]

| Field | Value |
|---|---|
| **Monthly cost** | `$___` |
| **Annual cost equivalent** | `$___` |
| **Billing cycle** | monthly / annual |
| **Renewal date** | `YYYY-MM-DD` |
| **Primary use case** | *One sentence — what is this sub for?* |

**What I actually used it for this month** *(3-5 bullets — concrete, not aspirational):*
-
-
-

**The cancellation gut check:**
- *Would I notice within 7 days if this disappeared tomorrow?* `Yes / No / Maybe`
- *If cancelled, what would I replace it with?* `___`
- *What would I lose?* `___`

**Capacity / limits** *(skip if the sub doesn't expose usage data):*
- Rate limit headroom at end of month: `__%` (healthy / tight / over)
- Typical weekly utilization: `___`
- Any throttling / cap hits this month? `Y / N — details`

**Overlap scan:** *Does this sub do work that another sub in my stack could also do?*
- Overlapping sub: `___`
- Why I keep both: `___`
- *Am I paying twice for the same capability?* `Y / N`

**Decision:** `KEEP / CUT / CONSOLIDATE / UPGRADE / DOWNGRADE`

**Reason (one sentence):** `___`

**Action required before next review:** `___`

---

## Aggregate Summary

### Spend

| Metric | This month | Last month | Δ |
|---|---|---|---|
| Total monthly spend | `$___` | `$___` | `±$___` |
| Decisions: keep | `__` | | |
| Decisions: cut | `__` | | |
| Decisions: consolidate | `__` | | |
| Decisions: upgrade/downgrade | `__` | | |
| Projected spend next month | `$___` | | |

### Patterns

*One-sentence observations. Only write a line if the pattern is real.*

- **Underused subs:** `___`
- **Oversaturated subs:** `___`
- **Overlap hotspots:** `___`
- **New sub candidates to trial:** `___`

### Decisions log

| Sub | Decision | Action | Due | Status |
|---|---|---|---|---|
|  |  |  |  |  |
|  |  |  |  |  |

---

## Next Review

- **Scheduled:** `YYYY-MM-DD` (first weekday of next month)
- **Calendar reminder set?** `Y / N`

---

## How to run this review (first-time instructions)

1. **List every sub you pay for.** Include: AI tools, SaaS, dev tools, hosting, storage, productivity apps. If you don't know what you're paying for, check your credit card statement — you're almost certainly paying for more than you remember.
2. **Fill one block per sub.** Keep answers terse. The gut check is more important than exact usage numbers.
3. **Resist the "I might need it someday" trap.** "Might need it" without a concrete use case in the last 30 days is a Cut candidate.
4. **For the overlap scan:** two subs that *can* do the same thing aren't necessarily redundant — if you actively use both for different reasons, that's fine. The question is whether you're *paying for the same capability twice without using both.*
5. **At end of review, schedule the next one.** This is a monthly ritual, not a one-time audit.

## Anti-patterns to avoid

- **Over-measurement.** You don't need exact API usage numbers for web subscriptions that don't expose them. Gut check > spreadsheet.
- **Emotional attachment.** "I've had this sub for 3 years" isn't a Keep reason.
- **Bundling bias.** "It comes with X that I also use" — fine, but evaluate the bundled product on its own merits. If you cut the sub, would you pay separately for the bundled piece?
- **Cut-then-re-subscribe churn.** If you're cutting and re-upping the same sub every 2-3 months, that's a signal the sub is seasonal for your workflow — keep it, or find a pay-as-you-go alternative.
- **Perfection paralysis.** A messy review with real decisions > a perfect review you never finish.

## When to escalate this from monthly review to automation

Run monthly reviews for **3 months minimum** before considering building tooling. You need that baseline to know:
- Which friction is repetitive (worth automating)
- Which data is actually available (many web subs expose nothing)
- Which decisions you make consistently (that's the automation opportunity)

If after 3 reviews you find yourself making the same decisions in the same way using the same data, then a simple dashboard (not an app) is probably justified. Before then, every hour spent building automation is premature.
