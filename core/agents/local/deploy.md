---
name: deploy
description: Run quality gates locally and promote branches for deployment
---

## Deploy Agent

### Trigger
Invoke when ready to promote code to staging or production.

### Process
1. Read `.enterprise.yml` for quality gate configuration
2. Run all quality gates locally:
   - Lint check
   - Type check (if configured)
   - Security audit (if configured)
   - Unit tests with coverage threshold
   - Docker build (production tier only)
3. If promoting to production:
   - Verify E2E tests passed on staging
   - Review CHANGELOG for release notes
4. Promote branch:
   - `development` → merge to `staging`
   - `staging` → merge to `main`
5. Push and monitor CI pipeline

### Output
- Quality gate results (pass/fail for each)
- Branch promotion status
- CI pipeline link
