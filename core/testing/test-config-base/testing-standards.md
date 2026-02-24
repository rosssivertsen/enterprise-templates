# Testing Standards

This document defines the testing conventions and requirements for all projects using the enterprise templates.

## Test Directory Structure

All test files live under a top-level `tests/` directory with the following layout:

```
tests/
├── unit/       # Unit tests — fast, no external dependencies
└── e2e/        # End-to-end integration tests — require running services
```

- **tests/unit/** — Isolated tests that exercise individual functions, classes, or modules. They must not depend on databases, APIs, or other external services.
- **tests/e2e/** — Integration and end-to-end tests that verify behavior across service boundaries. These require a running environment (local Docker Compose, staging, etc.).

## Naming Conventions

| Language | Pattern | Example |
|----------|---------|---------|
| Python   | `test_<module>.py` | `test_auth.py`, `test_user_service.py` |
| Node/TS  | `<module>.test.ts`  | `auth.test.ts`, `userService.test.ts` |

## Markers / Tags

Tests must be tagged so they can be run selectively:

| Marker | Purpose |
|--------|---------|
| `unit` | Unit tests — fast, no external dependencies |
| `e2e`  | End-to-end integration tests — require running services |
| `slow` | Slow tests — skipped during quick iteration cycles |

In Python, use `@pytest.mark.<marker>`. In Node/Vitest, use `describe.tag` or file-path conventions (`tests/unit/`, `tests/e2e/`).

## Coverage Requirements

- **80% threshold** (lines, branches, functions, statements) is required before a staging deploy is permitted.
- **E2E tests must pass** before a production deploy is permitted.

Coverage reports are generated automatically in CI. Failures block the deploy pipeline.

## How to Run Tests

### Python

```bash
# Run unit tests only
make test

# Run end-to-end tests
make test-e2e

# Run all tests
make test-all
```

### Node / TypeScript

```bash
# Run unit tests only
npm test

# Run end-to-end tests
npm run test:e2e

# Run all tests
npm run test:all
```
