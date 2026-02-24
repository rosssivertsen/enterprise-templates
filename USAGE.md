# Usage Guide

**Version:** 2.0.0
**Last Updated:** February 2026

---

## Scaffolding a New Project

Run the interactive CLI from the repository root:

```bash
./scaffold.sh my-project
```

The CLI prompts you for:

1. **Language** — Python, Node/TypeScript, or Generic
2. **Tier** — Lite, Standard, or Production
3. **Optional features** — Docker, AI agents, additional CI steps

When finished, your new project directory contains all selected files, a
pre-configured `.enterprise.yml` manifest, and a ready-to-use Git repository.

### Non-Interactive Mode

Pass flags to skip prompts:

```bash
./scaffold.sh my-project --lang python --tier production --docker --agents
```

---

## Tier Selection Guide

### Lite

Best for: personal projects, prototypes, internal tools with a single maintainer.

- Basic CI (lint + test on push)
- Single-branch workflow (main)
- README template only
- No Docker, no deployment steps

### Standard

Best for: team projects, client work, services that deploy to a single environment.

- Full CI/CD (lint, test, build, deploy)
- Two-branch workflow (main + development)
- README + CHANGELOG templates
- Dockerfile included
- Local + CI AI agents

### Production

Best for: critical services, multi-environment deployments, regulated projects.

- Full CI/CD with environment gates and approval steps
- Three-branch workflow (main + staging + development)
- Full documentation suite (README, CHANGELOG, ADRs)
- Dockerfile + docker-compose
- Full AI agent suite (local, CI, review)
- Branch protection rule suggestions

---

## .enterprise.yml Configuration

Every scaffolded project contains an `.enterprise.yml` file at its root. This
manifest drives CI/CD behavior, agent configuration, and documentation generation.

Key fields:

```yaml
project:
  name: my-project
  language: python          # python | node | generic
  tier: standard            # lite | standard | production

ci:
  provider: github-actions
  pipeline: core/ci-cd/pipeline-python.yml

agents:
  enabled: true
  provider: anthropic       # anthropic | openai | local

docker:
  enabled: true
  base_image: python:3.12-slim
```

For the complete schema with all fields and defaults, see
[core/enterprise-schema.md](core/enterprise-schema.md).

---

## Upgrading a Project's Tier

You can upgrade at any time by re-running the scaffolder:

```bash
./scaffold.sh my-project --tier production --upgrade
```

The `--upgrade` flag preserves your existing source code and configuration while
adding the new tier's files (additional CI steps, Docker compose, documentation
templates, etc.). It will not overwrite files you have modified.

You can also upgrade manually:

1. Update `tier:` in `.enterprise.yml`
2. Copy the additional template files from `core/` into your project
3. Update your CI workflow to reference the new pipeline template

---

## Language-Specific Notes

### Python

Scaffolded Python projects use a **Makefile** for common tasks:

```bash
make install          # pip install -r requirements.txt
make install-dev      # pip install -r requirements-dev.txt
make test             # pytest
make lint             # flake8 + mypy
make format           # black + isort
make clean            # remove __pycache__, .pytest_cache, etc.
```

The CI pipeline calls these same Makefile targets, so local and CI behavior match.

### Node / TypeScript

Scaffolded Node projects use **npm scripts** defined in `package.json`:

```bash
npm install           # install dependencies
npm test              # vitest
npm run lint          # eslint
npm run build         # tsc (TypeScript compilation)
npm run format        # prettier
```

TypeScript is configured by default via `tsconfig.json` and `vitest.config.ts`.

### Generic

Generic projects use a **Makefile** with placeholder targets. Fill in language-specific
commands as needed:

```bash
make build            # placeholder — add your build command
make test             # placeholder — add your test command
make lint             # placeholder — add your lint command
```

---

## Agent Setup

### Prerequisites

Set your LLM API key as an environment variable:

```bash
export LLM_API_KEY="your-api-key-here"
```

For CI agents, add `LLM_API_KEY` as a repository secret in GitHub.

### Configuring Providers

Edit the `agents:` section in `.enterprise.yml`:

```yaml
agents:
  enabled: true
  provider: anthropic       # anthropic | openai | local
  model: claude-sonnet-4-20250514   # optional: override default model
```

The LLM abstraction layer in `core/agents/llm-abstraction/` routes requests to
the configured provider. Local models (Ollama, LM Studio) are supported via the
`local` provider.

### Agent Capabilities

| Agent | Runs In | Purpose |
|---|---|---|
| Local skills | Editor / terminal | Code generation, refactoring, docs |
| CI review | GitHub Actions | Automated PR review comments |
| CI changelog | GitHub Actions | Draft changelog entries from commits |
| CI test-gen | GitHub Actions | Suggest missing test cases |

---

## CI/CD Pipeline Overview

All tiers use GitHub Actions. Pipeline templates live in `core/ci-cd/`.

| Stage | Lite | Standard | Production |
|---|---|---|---|
| Lint | Yes | Yes | Yes |
| Test | Yes | Yes | Yes |
| Build | — | Yes | Yes |
| Deploy to staging | — | Yes | Yes (with gate) |
| Deploy to production | — | On main push | On main push (with approval) |
| AI review | — | Optional | Yes |

Branch-to-environment mapping:

- `development` → staging deployment
- `staging` → staging UAT (Production tier only)
- `main` → production deployment

---

## Common Workflows

### Feature Development

```bash
git checkout -b feature/my-feature development
# ... make changes ...
git push -u origin feature/my-feature
# Open PR to development — CI runs lint + test
# Merge to development — deploys to staging
# Promote development → main (or via staging for Production tier)
```

### Hotfix

```bash
git checkout -b hotfix/critical-fix main
# ... fix the issue ...
git push -u origin hotfix/critical-fix
# Open PR to main — CI runs full pipeline
# Merge to main — deploys to production
# main auto-syncs back to staging/development
```

### Release (Production Tier)

```bash
# Ensure staging is verified
git checkout main
git merge staging
git tag v1.2.0
git push origin main --tags
# CI deploys to production and creates a GitHub release
```

---

## Further Reading

- [core/enterprise-schema.md](core/enterprise-schema.md) — Full `.enterprise.yml` reference
- [README.md](README.md) — Project overview and quick start
- [TESTING-SUMMARY.md](TESTING-SUMMARY.md) — Test suite status

---

**Maintained by:** Ross Sivertsen
