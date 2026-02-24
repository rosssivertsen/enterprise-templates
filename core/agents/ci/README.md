# CI Agent Workflows

GitHub Actions workflows that run autonomously in the CI/CD pipeline.

## Available Agents

| Agent | Trigger | Purpose |
|-------|---------|---------|
| `pr-review.yml` | PR opened/updated | Automated code review with LLM-powered comments |
| `auto-test.yml` | PR opened/updated | Coverage delta analysis, flags untested code |
| `deploy-gate.yml` | PR to main | Final validation before production deployment |
| `incident.yml` | Workflow failure on main | Failure analysis, auto-creates issues with suggested fixes |

## Setup

1. These workflows are copied into `.github/workflows/` when scaffolding a Standard or Production tier project
2. Set the `LLM_API_KEY` secret in your GitHub repository settings
3. Configure the LLM provider in `.enterprise.yml` under `agents.default` or per-role overrides

## How They Work

Each agent reads `.enterprise.yml` to determine which LLM provider to use, then:
- Gathers context (diffs, logs, coverage data)
- Sends a structured prompt to the LLM
- Takes action (posts comments, creates issues, approves/blocks deploys)

## Permissions

These workflows require specific GitHub token permissions:
- `pr-review`: `contents: read`, `pull-requests: write`
- `auto-test`: `contents: read`, `pull-requests: write`
- `deploy-gate`: `contents: read`, `pull-requests: write`, `checks: write`
- `incident`: `contents: read`, `issues: write`
