---
name: e2e-test-writer
description: Generate end-to-end integration tests for completed features
---

## E2E Test Writer Agent

### Trigger
Invoke after completing a feature, before creating a PR to main.

### Process
1. Read `.enterprise.yml` to confirm e2e_required_for_prod is true
2. Identify the feature's API endpoints or user-facing behavior
3. Generate E2E tests that:
   - Test the full request/response cycle against a running instance
   - Use environment variable for base URL (E2E_BASE_URL)
   - Cover happy path and key error scenarios
   - Verify response status codes, headers, and body
4. Place tests in `tests/e2e/` with appropriate markers/tags
5. Document how to run: `make test-e2e` or `npm run test:e2e`

### Output
- Generated E2E test files
- Instructions for running against staging
