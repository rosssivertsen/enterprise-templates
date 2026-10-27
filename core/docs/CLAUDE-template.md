# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

> **Important:** the import above loads `AGENTS.md` (agent-agnostic standards: session
> logging, ROI tracking, plus/delta, quality standards) into context. Keep it. Claude Code
> reads `AGENTS.md` on its own only when a repo has NO `CLAUDE.md` (v2.1.277), so a prose
> "also read AGENTS.md" line is a request the model may or may not act on, not a load.
> This file adds Claude-specific extensions.

## Project Overview

**Name:** {{PROJECT_NAME}}
**Language:** {{LANGUAGE}}
**Tier:** {{TIER}}

## Commands

### Development
{{COMMANDS_DEV}}

### Testing
{{COMMANDS_TEST}}

### Deployment
{{COMMANDS_DEPLOY}}

## Architecture

{{ARCHITECTURE}}

## Session Logging (Required)

Always update `docs/SESSION_LOG.md` at every meaningful progress point during a session.
Read it first when resuming work to restore context. See `AGENTS.md` for the full entry format.

## Project Configuration

This project uses `.enterprise.yml` for CI/CD, agent, and deployment configuration. See the file for all available settings.
