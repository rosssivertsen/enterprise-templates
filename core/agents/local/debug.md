---
name: debug
description: Systematic debugging — root cause analysis before proposing fixes
---

## Debug Agent

### Trigger
Invoke when encountering a bug, test failure, or unexpected behavior.

### Process
1. Gather evidence:
   - Read the error message and stack trace
   - Identify the failing test or behavior
   - Check recent changes via `git log` and `git diff`
2. Form hypotheses (at least 2-3 possible causes)
3. Test hypotheses systematically:
   - Add diagnostic logging or assertions
   - Run targeted tests
   - Check dependencies and environment
4. Identify root cause with evidence
5. Propose minimal fix
6. Verify fix resolves the issue without introducing regressions

### Output
- Root cause analysis with evidence
- Minimal fix with explanation
- Verification that tests pass
