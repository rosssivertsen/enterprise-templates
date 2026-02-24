# `.enterprise.yml` Configuration Schema

> Complete reference for every field in the enterprise project configuration file.

## Tier Legend

| Tier | Description |
|------|-------------|
| **lite** | Minimal setup for single-developer or prototype projects. |
| **standard** | Team projects with CI/CD and basic quality gates. |
| **production** | Full enterprise pipeline with all gates enforced. |

---

## `project` — Project Metadata

Applies to: **lite, standard, production**

| Field | Type | Default | Tiers | Description |
|-------|------|---------|-------|-------------|
| `project.name` | `string` | `"my-project"` | lite, standard, production | Human-readable project name used in dashboards and generated documentation. |
| `project.description` | `string` | `"A new enterprise project"` | lite, standard, production | Short description of the project's purpose. |
| `project.language` | `enum` (`python` \| `node` \| `generic`) | `"python"` | lite, standard, production | Primary language of the project. Determines default linters, Docker base images, and test runners. |
| `project.tier` | `enum` (`lite` \| `standard` \| `production`) | `"standard"` | lite, standard, production | Enterprise tier governing which quality and automation features are enabled by default. |

---

## `branches` — Git Branching Strategy

Applies to: **lite, standard, production**

| Field | Type | Default | Tiers | Description |
|-------|------|---------|-------|-------------|
| `branches.production` | `string` | `"main"` | lite, standard, production | Branch representing the live / released state of the project. |
| `branches.staging` | `string` | `"staging"` | standard, production | Pre-production integration branch for QA and acceptance testing. |
| `branches.development` | `string` | `"develop"` | standard, production | Day-to-day development branch; pull requests target this branch. |
| `branches.sync` | `boolean` | `true` | production | When `true`, creates branch-protection rules and keeps branches synchronised via automated merge-forward PRs. |

---

## `quality` — Code Quality and Testing Gates

Applies to: **standard, production** (optional for lite)

| Field | Type | Default | Tiers | Description |
|-------|------|---------|-------|-------------|
| `quality.lint` | `boolean` | `true` | standard, production | Run the language-appropriate linter (e.g. `ruff` for Python, `eslint` for Node). |
| `quality.type_check` | `boolean` | `true` | standard, production | Run static type checking (e.g. `mypy` for Python, `tsc --noEmit` for Node). |
| `quality.security_audit` | `boolean` | `true` | standard, production | Run a security and dependency audit (e.g. `bandit`, `npm audit`). |
| `quality.unit_test_coverage` | `integer` (0–100) | `80` | standard, production | Minimum unit-test line-coverage percentage required to pass CI. |
| `quality.e2e_required_for_prod` | `boolean` | `true` | production | When `true`, end-to-end tests must pass before a production deploy is allowed. |

---

## `agents` — AI / LLM Agent Configuration

Applies to: **standard, production** (disabled for lite)

| Field | Type | Default | Tiers | Description |
|-------|------|---------|-------|-------------|
| `agents.enabled` | `boolean` | `true` | standard, production | Master switch to enable or disable all AI agent features. |
| `agents.default.provider` | `string` | `"anthropic"` | standard, production | LLM provider identifier used by all agent roles unless overridden. |
| `agents.default.model` | `string` | `"claude-sonnet-4-20250514"` | standard, production | Model used for agent tasks unless overridden per role. |
| `agents.default.api_key_env` | `string` | `"LLM_API_KEY"` | standard, production | Name of the environment variable holding the API key. The key itself is never stored in this file. |
| `agents.overrides.code_review` | `object` | *(commented out)* | production | Per-role model override for the code-review agent. Inherits from `default`. |
| `agents.overrides.test_writer` | `object` | *(commented out)* | production | Per-role model override for the test-writer agent. Inherits from `default`. |
| `agents.overrides.pr_review` | `object` | *(commented out)* | production | Per-role model override for the PR-review agent. Inherits from `default`. |
| `agents.local.code_review` | `boolean` | `true` | standard, production | Enable the code-review agent in the local development environment. |
| `agents.local.test_writer` | `boolean` | `true` | standard, production | Enable the test-writer agent in the local development environment. |
| `agents.local.e2e_test_writer` | `boolean` | `true` | standard, production | Enable the end-to-end test-writer agent in the local development environment. |
| `agents.local.debug` | `boolean` | `true` | standard, production | Enable the debug agent in the local development environment. |
| `agents.local.deploy` | `boolean` | `true` | standard, production | Enable the deploy agent in the local development environment. |
| `agents.local.doc_writer` | `boolean` | `true` | standard, production | Enable the documentation-writer agent in the local development environment. |
| `agents.ci.pr_review` | `boolean` | `true` | standard, production | Enable the PR-review agent in CI/CD pipelines. |
| `agents.ci.auto_test` | `boolean` | `true` | standard, production | Enable the automatic test-generation agent in CI/CD pipelines. |
| `agents.ci.deploy_gate` | `boolean` | `true` | production | Enable the deploy-gate agent that approves or blocks production deployments in CI/CD. |
| `agents.ci.incident` | `boolean` | `true` | production | Enable the incident-response agent in CI/CD pipelines. |

---

## `docker` — Container Packaging Settings

Applies to: **standard, production** (optional for lite)

| Field | Type | Default | Tiers | Description |
|-------|------|---------|-------|-------------|
| `docker.enabled` | `boolean` | `true` | standard, production | Whether to generate a Dockerfile and related artifacts during scaffolding. |
| `docker.base_image` | `string` | `"auto"` | standard, production | Base Docker image. `"auto"` selects an image based on the project language (e.g. `python:3.12-slim`, `node:20-alpine`). |
| `docker.port` | `integer` | `8000` | standard, production | Default port exposed by the container. |
| `docker.compose` | `boolean` | `false` | standard, production | Whether to generate a `docker-compose.yml` for local multi-service development. |
