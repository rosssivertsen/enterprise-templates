# Local Agent Skills

These are Claude Code skill templates that get installed into projects under `.claude/skills/`.

## Available Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `code-review` | Pre-PR code review | Before creating a pull request |
| `test-writer` | Generate unit tests | After writing new code |
| `e2e-test-writer` | Generate E2E tests | After completing a feature |
| `debug` | Root cause analysis | When encountering bugs or test failures |
| `deploy` | Quality gates + branch promotion | When ready to deploy |
| `doc-writer` | Update documentation | After completing features |

## Installation

These skills are automatically installed when scaffolding a Standard or Production tier project. They are placed in `.claude/skills/` in the project root.

## Configuration

Skills read from `.enterprise.yml` in the project root for:
- Quality gate thresholds
- LLM provider settings
- Enabled/disabled status per skill
