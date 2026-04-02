# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **Important:** Also read `AGENTS.md` in this repo root. It contains agent-agnostic
> standards (session logging, ROI tracking, plus/delta, quality standards) that apply
> to all AI assistants including Claude. This file adds Claude-specific extensions.

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
