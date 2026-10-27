# Usage Guide

**Version:** 2.0.0
**Last Updated:** October 2026

---

## Scaffolding a New Project

`scaffold.sh` is the only supported way to create a project. Don't copy template
files by hand: hand-copied projects drift from the templates.

### Interactive

```bash
./scaffold.sh
```

It prompts for project name, REPO-CODE, language, tier, output directory and,
for Standard/Production, AI provider settings and GitHub repo creation.

### Non-interactive (agents and CI)

```bash
./scaffold.sh --name my-project --language python --tier standard \
              --output ~/dev --github --yes
```

| Flag | Meaning |
|---|---|
| `--name NAME` | Project name, kebab-case. Required with `--yes`. |
| `--code CODE` | 3-letter REPO-CODE. Default: proposed from the name. |
| `--language LANG` | `python`, `node` or `generic`. Required with `--yes`. |
| `--tier TIER` | `lite`, `standard` or `production`. Required with `--yes`. |
| `--output DIR` | Parent directory. Default `~/dev`. |
| `--provider`, `--model`, `--api-key-env` | `.enterprise.yml` agent settings (Standard/Production). |
| `--github [ORG]` / `--no-github` | Create a private GitHub repo (personal account if no ORG), or not. |
| `--yes`, `-y` | Accept defaults and skip confirmation. |

With `--yes`, a missing required value, an invalid value or a REPO-CODE that is
already registered stops the script with an error, and an existing project
directory is never overwritten.

Set `REPO_ID_REGISTRY` to point at a different registry file. For a dry run,
point it at an empty temp file so the real registry is not touched:

```bash
REPO_ID_REGISTRY="$(mktemp)" ./scaffold.sh --name my-project --code ZZZ \
  --language generic --tier lite --output /tmp/scaffold-dry-run --no-github --yes
```

The "Registry append marker not found" warning is expected in a dry run.

### Every project gets

| File | Purpose |
|---|---|
| `AGENTS.md` | Standards **and all project facts** (overview, commands, architecture, hard rules). Read by every agent. |
| `CLAUDE.md` | Imports `AGENTS.md` (`@AGENTS.md`); holds only Claude Code–specific extensions. |
| `GEMINI.md` | Imports `AGENTS.md` (`@./AGENTS.md`); holds only Gemini CLI–specific extensions. Codex reads `AGENTS.md` directly. |
| `README.md`, `CHANGELOG.md` | Human-facing overview and change history. |
| `docs/SESSION_LOG.md` | Progress journal; every entry names the agent that wrote it. |
| `docs/plans/BACKLOG.md` | Backlog using the project's REPO-CODE (`ABC-1`, `ABC-2`, ...). |

### For AI agents

Any agent (Claude, Codex, Gemini, ...) scaffolding a project follows these steps:

1. Work out name, language and tier from the request. Ask the owner only for what
   you can't infer. Propose a REPO-CODE and check it isn't already in the registry.
2. Run `scaffold.sh` with flags and `--yes` (see above). Don't hand-copy templates.
3. Fill in `AGENTS.md` → **Project Context**: Overview and Hard Rules, and adjust
   Commands and Architecture. Project facts go in `AGENTS.md` only, never in
   `CLAUDE.md` or `GEMINI.md`.
4. Fill in the README description and architecture.
5. Write the first `docs/SESSION_LOG.md` entry, ending its heading with your agent name.
6. Commit with a message starting with the REPO-CODE.

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

## Upgrading or Re-aligning an Existing Project

`scaffold.sh` has no upgrade mode. To move a project to a higher tier, or to bring an
older project in line with the current templates:

1. Scaffold a reference copy into a temp directory with the project's name, language
   and target tier. Use an empty temp registry, because the project's REPO-CODE is
   already registered:

   ```bash
   REPO_ID_REGISTRY="$(mktemp)" ./scaffold.sh --name my-project --code ABC \
     --language python --tier standard --output /tmp/realign --no-github --yes
   ```

   Ignore the "Registry append marker not found" warning: it is expected with a temp registry.

2. Copy the files the project lacks from `/tmp/realign/my-project/`.
3. For files the project already has (`AGENTS.md`, `CLAUDE.md`, `README.md`), take the
   new template version and move the project's own content into its slots. In
   particular, move project facts out of `CLAUDE.md` into `AGENTS.md` → Project Context.
4. Review the diff, then commit with the REPO-CODE prefix.

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
  model: claude-opus-5-5   # optional: override default model
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
