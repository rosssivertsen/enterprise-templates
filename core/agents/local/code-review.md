---
name: code-review
description: Review code changes against project standards before PR creation
---

## Code Review Agent

### Trigger
Invoke before creating a pull request or when you want a pre-commit review.

### Process
1. Read `.enterprise.yml` to load project config and quality standards
2. Run `git diff` against the target branch to identify all changes
3. For each changed file:
   - Check adherence to project lint rules
   - Identify potential security issues (OWASP top 10)
   - Check test coverage for new/changed code
   - Verify error handling at system boundaries
4. Check for:
   - Hardcoded secrets or credentials
   - Missing input validation at system boundaries
   - Breaking API changes
   - Missing or outdated documentation
5. Present findings organized by severity

### Output
Markdown summary with:
- **Blocking** — must fix before PR
- **Warnings** — should fix
- **Suggestions** — nice to have
- Coverage delta assessment
