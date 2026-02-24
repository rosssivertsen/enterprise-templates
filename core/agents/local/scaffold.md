---
name: scaffold
description: Interactive project scaffolding — generates a complete project from enterprise templates
---

## Scaffold Agent

### Overview
Generates a new project from enterprise templates with full CI/CD, testing, Docker, and agent infrastructure based on the selected tier.

### Trigger
Invoke with `/scaffold` or when creating a new project.

### Interactive Prompts

Collect the following from the user (one at a time, use AskUserQuestion tool when available):

1. **Project name** (kebab-case, e.g. `xima-recording-extractor`)
2. **Language**: Python / Node (TypeScript) / Generic
3. **Project tier**:
   - **Lite** — git, lint, README (ad hoc / one-off work)
   - **Standard** — CI/CD, tests, agents (ongoing projects)
   - **Production** — Docker, E2E, deploy scripts (deployed services)
4. **Output directory** (default: `~/dev/`)
5. **AI provider** (Standard/Production only): Anthropic / OpenAI / Ollama / Custom
6. **Default model** for agents
7. **Customize per role?** — allow different providers for code-review, test-writer, etc.
8. **Create GitHub repo?** — Yes/No, and which org

### Scaffolding Process

After collecting inputs, execute scaffold.sh from the enterprise-templates repo:

```bash
# Locate enterprise-templates (check common locations)
TEMPLATE_DIR="$HOME/dev/enterprise-templates"
if [ ! -d "$TEMPLATE_DIR" ]; then
  TEMPLATE_DIR="$HOME/dev/enterprise-template"
fi

cd "$TEMPLATE_DIR"
# Run scaffold non-interactively by piping answers
# Or execute the steps directly using file creation tools
```

Alternatively, perform the scaffolding directly using Claude Code tools:
1. Create the project directory
2. Copy starter files for the selected language
3. Add tier-appropriate files (CI/CD, tests, agents, Docker)
4. Generate `.enterprise.yml` with collected values
5. Generate `CLAUDE.md`, `README.md`, `CHANGELOG.md`
6. Initialize git repo with branches
7. Optionally create GitHub repo

### Output

After scaffolding:
- Print the project directory path
- Show the generated file tree
- Print quick-start commands for the selected language
- Remind the user to set `LLM_API_KEY` if agents are enabled

### Tier Details

| Feature | Lite | Standard | Production |
|---------|------|----------|------------|
| Git repo | Yes | Yes | Yes |
| .gitignore | Yes | Yes | Yes |
| README + CHANGELOG | Yes | Yes | Yes |
| Lint config | Yes | Yes | Yes |
| CI/CD pipeline | No | Yes | Yes |
| Test infrastructure | No | Yes | Yes |
| Agent skills | No | Yes | Yes |
| CI agents | No | Yes | Yes |
| .enterprise.yml | No | Yes | Yes |
| Dockerfile | No | No | Yes |
| Deploy script | No | No | Yes |
| E2E test gate | No | No | Yes |
| Branch strategy | No | 3-tier | 3-tier |
