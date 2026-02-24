# Enterprise Templates — Scaffolding Platform

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![Status](https://img.shields.io/badge/status-production--ready-success.svg)

## Overview

Enterprise Templates is a language-agnostic project scaffolding platform that generates
production-ready repositories with tiered CI/CD pipelines, testing infrastructure,
Docker support, and AI coding agents — all configured through an interactive CLI and
a single `.enterprise.yml` manifest.

## Quick Start

```bash
./scaffold.sh my-project
```

The interactive CLI walks you through language, tier, and feature selection, then
generates a fully configured project directory.

## Tiers

| Feature | Lite | Standard | Production |
|---|---|---|---|
| CI/CD pipeline | Basic (lint + test) | Full (lint, test, build, deploy) | Full + environment gates |
| Testing config | Minimal | Unit + integration | Unit, integration, e2e |
| Docker | — | Dockerfile | Dockerfile + compose |
| AI agents | Local skills only | Local + CI agents | Local + CI + review agents |
| Branch strategy | main only | main + development | main + staging + development |
| Documentation | README | README + CHANGELOG | README + CHANGELOG + ADRs |

## Supported Languages

- **Python** — Makefile-driven, pytest, pip/venv
- **Node / TypeScript** — npm scripts, Vitest, ESLint
- **Generic** — Makefile-driven, shell-based tests, language-agnostic

## Repository Structure

```
enterprise-templates/
├── scaffold.sh               # Interactive scaffolding CLI
├── core/                     # Shared templates and configs
│   ├── ci-cd/                # Pipeline templates (base + per-language)
│   ├── testing/              # Test configuration templates
│   ├── docker/               # Dockerfiles per language
│   ├── docs/                 # Documentation templates
│   ├── agents/               # AI agent definitions (local, CI, LLM abstraction)
│   ├── enterprise-template.yml  # Default .enterprise.yml
│   └── enterprise-schema.md  # Full configuration reference
├── starters/                 # Language-specific starter projects
│   ├── python/
│   ├── node/
│   └── generic/
├── automation/               # Project configuration scripts
├── change-control/           # (Legacy) pipeline templates — see core/ci-cd/
├── documentation/            # (Legacy) doc templates — see core/docs/
├── project-starter/          # (Legacy) starter project — see starters/
└── test-project/             # Validation test suite
```

## Agent System

The platform includes an AI agent layer with two components:

- **Local skills** — file-scoped helpers for code generation, refactoring, and
  documentation that run inside your editor (Claude, Cursor, Copilot).
- **CI agents** — GitHub Actions steps that run automated code review, test
  generation, and changelog drafting on pull requests.

Agent configuration lives in `core/agents/`. Set `LLM_API_KEY` in your environment
or CI secrets to enable agent features. The LLM abstraction layer supports multiple
providers (Anthropic, OpenAI, local models).

## Detailed Usage

See **[USAGE.md](USAGE.md)** for the full walkthrough: scaffolding options, tier
selection guide, configuration reference, upgrade paths, and common workflows.

## Version

**2.0.0** — Scaffolding platform with tiered project generation, multi-language
support, Docker templates, and AI agent integration.

---

Enterprise Templates is maintained by Ross Sivertsen.
