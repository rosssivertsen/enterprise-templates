#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# scaffold.sh — Interactive CLI for Enterprise Project Generation
# =============================================================================
# Generates new projects from enterprise templates with tier-based features.
# Usage: ./scaffold.sh                 (interactive)
#        ./scaffold.sh --name my-app --language python --tier lite --yes
#                                       (non-interactive, for agents and CI)
# Run ./scaffold.sh --help for all flags.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Repo ID Registry (Lex Immutabilis governance) ---------------------------
# Canonical source of truth for all REPO-CODE assignments. Set REPO_ID_REGISTRY
# env var to override (useful for CI or non-Ross machines).
REPO_ID_REGISTRY="${REPO_ID_REGISTRY:-$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/sherpa-vault/docs/repo-id-registry.md}"

# --- Colors -------------------------------------------------------------------
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${BLUE}→${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn()    { echo -e "${YELLOW}!${NC} $1"; }
lowercase() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
uppercase() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }

# --- Registry helpers --------------------------------------------------------
# Propose a 3-char REPO-CODE from a kebab-case project name.
# my-cool-app → MCA (initials), fallback to first 3 consonants uppercase.
propose_repo_code() {
    local name="$1"
    local proposal
    # Try initials of hyphen-separated parts (my-cool-app → MCA)
    proposal=$(echo "$name" | awk -F- '{for(i=1;i<=NF;i++) printf "%s", toupper(substr($i,1,1))}')
    # If we got fewer than 3 chars (e.g., single-word name), take first 3 uppercased
    if [[ ${#proposal} -lt 3 ]]; then
        proposal=$(uppercase "${name:0:3}" | tr -d '-')
    fi
    # Pad with 'X' if still short
    while [[ ${#proposal} -lt 3 ]]; do
        proposal="${proposal}X"
    done
    # Take only first 3 chars
    echo "${proposal:0:3}"
}

# Check whether a code already exists in the registry (active, reserved, or retired).
# Returns 0 if collision, 1 if free.
# Matches: | **CODE** | (active rows), | CODE | (some rows), | CODE- | (retired rows
# where the old code had a trailing hyphen), and prose mentions in reserved/retired.
code_has_collision() {
    local code="$1"
    if [[ ! -f "$REPO_ID_REGISTRY" ]]; then
        return 1  # no registry found, can't check
    fi
    grep -qE "\*\*${code}\*\*|^\| ${code}(-|\s)" "$REPO_ID_REGISTRY"
}

# --- Flags (non-interactive mode) --------------------------------------------
# Any value given as a flag skips its prompt. With --yes, values not given use
# their defaults, missing required values are an error, and an existing project
# directory aborts instead of being overwritten.
die() { echo -e "\033[0;31m✗\033[0m $1" >&2; exit 1; }
usage() {
    cat <<'USAGE'
Usage: scaffold.sh [flags]

  --name NAME           Project name, kebab-case (required with --yes)
  --code CODE           3-letter REPO-CODE (default: proposed from name)
  --language LANG       python | node | generic (required with --yes)
  --tier TIER           lite | standard | production (required with --yes)
  --output DIR          Parent directory (default: ~/dev)
  --provider NAME       AI provider for .enterprise.yml (standard/production)
  --model NAME          AI model for .enterprise.yml (standard/production)
  --api-key-env VAR     API key env var name (standard/production)
  --github [ORG]        Create a private GitHub repo (personal if ORG omitted)
  --no-github           Do not create a GitHub repo
  --yes, -y             Non-interactive: accept defaults, skip confirmation
  --help, -h            Show this help

Env: REPO_ID_REGISTRY overrides the registry path (use a copy for dry runs).
USAGE
}

PROJECT_NAME=""; REPO_CODE_FLAG=""; LANGUAGE=""; TIER=""; OUTPUT_DIR_FLAG=""
PROVIDER_FLAG=""; MODEL_FLAG=""; API_KEY_ENV_FLAG=""; GITHUB_FLAG=""; GH_ORG_FLAG=""
ASSUME_YES="no"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)        PROJECT_NAME="${2:-}"; shift 2 ;;
        --code)        REPO_CODE_FLAG="${2:-}"; shift 2 ;;
        --language)    LANGUAGE="${2:-}"; shift 2 ;;
        --tier)        TIER="${2:-}"; shift 2 ;;
        --output)      OUTPUT_DIR_FLAG="${2:-}"; shift 2 ;;
        --provider)    PROVIDER_FLAG="${2:-}"; shift 2 ;;
        --model)       MODEL_FLAG="${2:-}"; shift 2 ;;
        --api-key-env) API_KEY_ENV_FLAG="${2:-}"; shift 2 ;;
        --github)
            GITHUB_FLAG="yes"
            if [[ -n "${2:-}" && "${2:-}" != --* ]]; then GH_ORG_FLAG="$2"; shift 2; else shift; fi ;;
        --no-github)   GITHUB_FLAG="no"; shift ;;
        --yes|-y)      ASSUME_YES="yes"; shift ;;
        --help|-h)     usage; exit 0 ;;
        *)             usage; die "Unknown flag: $1" ;;
    esac
done
if [[ "$ASSUME_YES" == "yes" ]]; then
    [[ -n "$PROJECT_NAME" ]] || die "--name is required with --yes"
    [[ -n "$LANGUAGE" ]]     || die "--language is required with --yes"
    [[ -n "$TIER" ]]         || die "--tier is required with --yes"
fi
case "$LANGUAGE" in ""|python|node|generic) ;; *) die "Invalid --language: $LANGUAGE" ;; esac
case "$TIER" in ""|lite|standard|production) ;; *) die "Invalid --tier: $TIER" ;; esac
NONINTERACTIVE_CODE="no"
[[ -n "$REPO_CODE_FLAG" || "$ASSUME_YES" == "yes" ]] && NONINTERACTIVE_CODE="yes"

# --- Banner -------------------------------------------------------------------
echo ""
echo "=========================================="
echo "  Enterprise Project Scaffolding CLI"
echo "=========================================="
echo ""

# =============================================================================
# 1. Gather user input
# =============================================================================

# --- Project Name (kebab-case) ------------------------------------------------
while true; do
    [[ -n "$PROJECT_NAME" ]] || read -rp "Project name (kebab-case, e.g. my-cool-app): " PROJECT_NAME
    if [[ "$PROJECT_NAME" =~ ^[a-z][a-z0-9]*(-[a-z0-9]+)*$ ]]; then
        break
    fi
    [[ "$ASSUME_YES" == "yes" ]] && die "Invalid --name '$PROJECT_NAME'. Use kebab-case."
    warn "Invalid name. Use kebab-case (lowercase letters, numbers, hyphens). Must start with a letter."
    PROJECT_NAME=""
done

# --- REPO-CODE (Lex Immutabilis governance) ----------------------------------
# Every project owns a globally-unique 3-char code, registered in
# sherpa-vault/docs/repo-id-registry.md. Backlog IDs qualify to <CODE>-<N> on
# all cross-repo surfaces (Kanban, commit messages, PR titles).
echo ""
if [[ ! -f "$REPO_ID_REGISTRY" ]]; then
    warn "Registry not found at $REPO_ID_REGISTRY"
    warn "Collision check disabled. Proceed carefully — manually verify the code is globally unique."
fi

PROPOSED_CODE=$(propose_repo_code "$PROJECT_NAME")
info "Proposed REPO-CODE for '$PROJECT_NAME': $PROPOSED_CODE"

while true; do
    if [[ "$NONINTERACTIVE_CODE" == "yes" ]]; then
        REPO_CODE_INPUT="$REPO_CODE_FLAG"
    else
        read -rp "REPO-CODE (3 uppercase chars) [$PROPOSED_CODE]: " REPO_CODE_INPUT
    fi
    REPO_CODE="${REPO_CODE_INPUT:-$PROPOSED_CODE}"
    REPO_CODE=$(uppercase "$REPO_CODE")

    if [[ ! "$REPO_CODE" =~ ^[A-Z]{3}$ ]]; then
        [[ "$NONINTERACTIVE_CODE" == "yes" ]] && die "Invalid REPO-CODE '$REPO_CODE'. Must be exactly 3 letters."
        warn "Invalid code. Must be exactly 3 uppercase letters."
        continue
    fi

    if code_has_collision "$REPO_CODE"; then
        [[ "$NONINTERACTIVE_CODE" == "yes" ]] && die "REPO-CODE '$REPO_CODE' is already in the registry ($REPO_ID_REGISTRY). Pass a free code with --code."
        warn "Code '$REPO_CODE' collides with an active, reserved, or retired entry in the registry."
        warn "Pick another — see: $REPO_ID_REGISTRY"
        continue
    fi

    break
done
REPO_CODE_LOWER=$(lowercase "$REPO_CODE")
success "REPO-CODE: $REPO_CODE"

# --- Language -----------------------------------------------------------------
if [[ -z "$LANGUAGE" ]]; then
    echo ""
    info "Select language:"
    echo "  1) python"
    echo "  2) node"
    echo "  3) generic"
    read -rp "Language [1/2/3]: " LANG_CHOICE
    case "$LANG_CHOICE" in
        1|python)  LANGUAGE="python" ;;
        2|node)    LANGUAGE="node" ;;
        3|generic) LANGUAGE="generic" ;;
        *)         warn "Invalid choice, defaulting to generic."; LANGUAGE="generic" ;;
    esac
fi

# --- Tier ---------------------------------------------------------------------
if [[ -z "$TIER" ]]; then
    echo ""
    info "Select tier:"
    echo "  1) lite       — Minimal: .gitignore, README, lint config"
    echo "  2) standard   — CI/CD, tests, agent skills, .enterprise.yml"
    echo "  3) production — Full: Docker, deploy scripts, all gates"
    read -rp "Tier [1/2/3]: " TIER_CHOICE
    case "$TIER_CHOICE" in
        1|lite)       TIER="lite" ;;
        2|standard)   TIER="standard" ;;
        3|production) TIER="production" ;;
        *)            warn "Invalid choice, defaulting to lite."; TIER="lite" ;;
    esac
fi

# --- Output Directory ---------------------------------------------------------
OUTPUT_DIR="$OUTPUT_DIR_FLAG"
if [[ -z "$OUTPUT_DIR" && "$ASSUME_YES" != "yes" ]]; then
    echo ""
    read -rp "Output directory [~/dev/]: " OUTPUT_DIR
fi
OUTPUT_DIR="${OUTPUT_DIR:-~/dev/}"
# Handle tilde expansion
OUTPUT_DIR="${OUTPUT_DIR/#\~/$HOME}"
# Remove trailing slash
OUTPUT_DIR="${OUTPUT_DIR%/}"

# --- AI Provider & Model (standard/production only) ---------------------------
PROVIDER=""
MODEL=""
API_KEY_ENV="LLM_API_KEY"

if [[ "$TIER" == "standard" || "$TIER" == "production" ]]; then
    PROVIDER="$PROVIDER_FLAG"; MODEL="$MODEL_FLAG"; API_KEY_ENV="$API_KEY_ENV_FLAG"
    if [[ "$ASSUME_YES" != "yes" ]]; then
        echo ""
        info "AI Agent Configuration"
        [[ -n "$PROVIDER" ]]    || read -rp "AI provider [anthropic]: " PROVIDER
        [[ -n "$MODEL" ]]       || read -rp "AI model [claude-sonnet-4-20250514]: " MODEL
        [[ -n "$API_KEY_ENV" ]] || read -rp "API key env variable [LLM_API_KEY]: " API_KEY_ENV
    fi
    PROVIDER="${PROVIDER:-anthropic}"
    MODEL="${MODEL:-claude-sonnet-4-20250514}"
    API_KEY_ENV="${API_KEY_ENV:-LLM_API_KEY}"
fi

# --- GitHub Repo (standard/production only) -----------------------------------
CREATE_REPO="no"
GH_ORG=""

if [[ -n "$GITHUB_FLAG" ]]; then
    CREATE_REPO="$GITHUB_FLAG"; GH_ORG="$GH_ORG_FLAG"
elif [[ "$ASSUME_YES" != "yes" && ( "$TIER" == "standard" || "$TIER" == "production" ) ]]; then
    echo ""
    read -rp "Create GitHub repository? [y/N]: " CREATE_REPO_INPUT
    if [[ "$(lowercase "$CREATE_REPO_INPUT")" == "y" || "$(lowercase "$CREATE_REPO_INPUT")" == "yes" ]]; then
        CREATE_REPO="yes"
        read -rp "GitHub org (leave blank for personal): " GH_ORG
    fi
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "=========================================="
info "Project:    $PROJECT_NAME"
info "REPO-CODE:  $REPO_CODE"
info "Language:   $LANGUAGE"
info "Tier:       $TIER"
info "Output:     $OUTPUT_DIR/$PROJECT_NAME"
if [[ "$TIER" != "lite" ]]; then
    info "Provider:   $PROVIDER"
    info "Model:      $MODEL"
    info "API Key:    \$$API_KEY_ENV"
fi
info "GitHub:     $CREATE_REPO${GH_ORG:+ ($GH_ORG)}"
echo "=========================================="
echo ""
CONFIRM="y"
[[ "$ASSUME_YES" == "yes" ]] || read -rp "Proceed? [Y/n]: " CONFIRM
if [[ "$(lowercase "$CONFIRM")" == "n" || "$(lowercase "$CONFIRM")" == "no" ]]; then
    warn "Aborted."
    exit 0
fi

# =============================================================================
# 2. Create project directory
# =============================================================================
PROJECT_DIR="$OUTPUT_DIR/$PROJECT_NAME"

if [[ -d "$PROJECT_DIR" ]]; then
    warn "Directory $PROJECT_DIR already exists."
    [[ "$ASSUME_YES" == "yes" ]] && die "Refusing to overwrite $PROJECT_DIR in --yes mode. Remove it or pick another --output."
    read -rp "Overwrite? [y/N]: " OVERWRITE
    if [[ "$(lowercase "$OVERWRITE")" != "y" && "$(lowercase "$OVERWRITE")" != "yes" ]]; then
        warn "Aborted."
        exit 1
    fi
    rm -rf "$PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"
success "Created $PROJECT_DIR"

# =============================================================================
# 3. Copy starter files
# =============================================================================
STARTER_DIR="$SCRIPT_DIR/starters/$LANGUAGE"
if [[ -d "$STARTER_DIR" ]]; then
    cp -r "$STARTER_DIR"/. "$PROJECT_DIR"/
    success "Copied starter files from starters/$LANGUAGE/"
else
    warn "No starter directory found for $LANGUAGE, skipping starter files."
fi

# =============================================================================
# 4. Tier-based files
# =============================================================================

# --- Lite: .gitignore, README, lint config ------------------------------------

# .gitignore
GITIGNORE_SRC="$SCRIPT_DIR/core/docs/GITIGNORE-$LANGUAGE"
if [[ -f "$GITIGNORE_SRC" ]]; then
    cp "$GITIGNORE_SRC" "$PROJECT_DIR/.gitignore"
    success "Added .gitignore for $LANGUAGE"
else
    warn "No GITIGNORE-$LANGUAGE found, creating minimal .gitignore"
    echo -e "*.log\n.env\nnode_modules/\n__pycache__/\n.DS_Store" > "$PROJECT_DIR/.gitignore"
fi

# Lint config (from starters or testing configs)
case "$LANGUAGE" in
    python)
        if [[ -f "$SCRIPT_DIR/core/testing/test-config-python/.flake8" ]]; then
            cp "$SCRIPT_DIR/core/testing/test-config-python/.flake8" "$PROJECT_DIR/"
            success "Added .flake8 lint config"
        fi
        ;;
    node)
        if [[ -f "$SCRIPT_DIR/starters/node/.eslintrc.json" ]]; then
            # Already copied from starter, just confirm
            success "Lint config (.eslintrc.json) included from starter"
        elif [[ -f "$SCRIPT_DIR/core/testing/test-config-node/.eslintrc.json" ]]; then
            cp "$SCRIPT_DIR/core/testing/test-config-node/.eslintrc.json" "$PROJECT_DIR/"
            success "Added .eslintrc.json lint config"
        fi
        ;;
    generic)
        info "No language-specific lint config for generic projects"
        ;;
esac

# --- Standard: CI/CD, test configs, agent skills, .enterprise.yml ------------
if [[ "$TIER" == "standard" || "$TIER" == "production" ]]; then

    # CI/CD pipeline
    PIPELINE_SRC="$SCRIPT_DIR/core/ci-cd/pipeline-$LANGUAGE.yml"
    if [[ -f "$PIPELINE_SRC" ]]; then
        mkdir -p "$PROJECT_DIR/.github/workflows"
        cp "$PIPELINE_SRC" "$PROJECT_DIR/.github/workflows/ci-cd.yml"
        success "Added CI/CD pipeline (.github/workflows/ci-cd.yml)"
    else
        warn "No pipeline-$LANGUAGE.yml found, skipping CI/CD"
    fi

    # Test configs
    TEST_CONFIG_DIR="$SCRIPT_DIR/core/testing/test-config-$LANGUAGE"
    if [[ -d "$TEST_CONFIG_DIR" ]]; then
        for f in "$TEST_CONFIG_DIR"/*; do
            fname="$(basename "$f")"
            # Skip files already copied
            if [[ ! -f "$PROJECT_DIR/$fname" ]]; then
                cp "$f" "$PROJECT_DIR/$fname"
            fi
        done
        success "Added test configs for $LANGUAGE"
    fi

    # Also copy base testing standards
    TEST_BASE_DIR="$SCRIPT_DIR/core/testing/test-config-base"
    if [[ -d "$TEST_BASE_DIR" ]]; then
        for f in "$TEST_BASE_DIR"/*; do
            fname="$(basename "$f")"
            if [[ ! -f "$PROJECT_DIR/$fname" ]]; then
                cp "$f" "$PROJECT_DIR/$fname"
            fi
        done
        success "Added base testing standards"
    fi

    # Agent skills (local)
    LOCAL_SKILLS_DIR="$SCRIPT_DIR/core/agents/local"
    if [[ -d "$LOCAL_SKILLS_DIR" ]]; then
        mkdir -p "$PROJECT_DIR/.claude/skills"
        for f in "$LOCAL_SKILLS_DIR"/*.md; do
            [[ -f "$f" ]] && cp "$f" "$PROJECT_DIR/.claude/skills/"
        done
        success "Added local agent skills (.claude/skills/)"
    fi

    # CI agent workflows
    CI_AGENTS_DIR="$SCRIPT_DIR/core/agents/ci"
    if [[ -d "$CI_AGENTS_DIR" ]]; then
        mkdir -p "$PROJECT_DIR/.github/workflows"
        for f in "$CI_AGENTS_DIR"/*.yml; do
            [[ -f "$f" ]] && cp "$f" "$PROJECT_DIR/.github/workflows/"
        done
        success "Added CI agent workflows (.github/workflows/)"
    fi

    # .enterprise.yml (generated with substitutions)
    ENTERPRISE_TEMPLATE="$SCRIPT_DIR/core/enterprise-template.yml"
    if [[ -f "$ENTERPRISE_TEMPLATE" ]]; then
        sed \
            -e "s|name: \"my-project\"|name: \"$PROJECT_NAME\"|g" \
            -e "s|repo_code: \"XXX\"|repo_code: \"$REPO_CODE\"|g" \
            -e "s|language: \"python\"|language: \"$LANGUAGE\"|g" \
            -e "s|tier: \"standard\"|tier: \"$TIER\"|g" \
            -e "s|provider: \"anthropic\"|provider: \"$PROVIDER\"|g" \
            -e "s|model: \"claude-sonnet-4-20250514\"|model: \"$MODEL\"|g" \
            -e "s|api_key_env: \"LLM_API_KEY\"|api_key_env: \"$API_KEY_ENV\"|g" \
            "$ENTERPRISE_TEMPLATE" > "$PROJECT_DIR/.enterprise.yml"
        success "Generated .enterprise.yml"
    fi
fi

# --- Production: Dockerfile, .dockerignore, deploy script --------------------
if [[ "$TIER" == "production" ]]; then

    # Dockerfile
    DOCKERFILE_SRC="$SCRIPT_DIR/core/docker/Dockerfile.$LANGUAGE"
    if [[ -f "$DOCKERFILE_SRC" ]]; then
        cp "$DOCKERFILE_SRC" "$PROJECT_DIR/Dockerfile"
        success "Added Dockerfile"
    else
        warn "No Dockerfile.$LANGUAGE found"
    fi

    # .dockerignore
    DOCKERIGNORE_SRC="$SCRIPT_DIR/core/docker/.dockerignore"
    if [[ -f "$DOCKERIGNORE_SRC" ]]; then
        cp "$DOCKERIGNORE_SRC" "$PROJECT_DIR/.dockerignore"
        success "Added .dockerignore"
    fi

    # Deploy script
    DEPLOY_SRC="$SCRIPT_DIR/automation/deploy-template.sh"
    if [[ -f "$DEPLOY_SRC" ]]; then
        mkdir -p "$PROJECT_DIR/scripts"
        cp "$DEPLOY_SRC" "$PROJECT_DIR/scripts/deploy.sh"
        chmod +x "$PROJECT_DIR/scripts/deploy.sh"
        success "Added deploy script (scripts/deploy.sh)"
    fi
fi

# =============================================================================
# 5a. Language-specific commands and architecture (used by AGENTS.md + CLAUDE.md)
# =============================================================================
# Determine language-appropriate commands
case "$LANGUAGE" in
    python)
        COMMANDS_DEV="- \`make dev\` — Start the development server\n- \`pip install -r requirements.txt\` — Install dependencies\n- \`pip install -r requirements-dev.txt\` — Install dev dependencies"
        COMMANDS_TEST="- \`make test\` — Run all tests\n- \`pytest tests/unit\` — Run unit tests only\n- \`pytest tests/e2e\` — Run end-to-end tests\n- \`make lint\` — Run linter (ruff/flake8)"
        COMMANDS_DEPLOY="- \`make deploy\` — Deploy the application\n- \`bash scripts/deploy.sh staging\` — Deploy to staging\n- \`bash scripts/deploy.sh production\` — Deploy to production"
        ARCHITECTURE="Python project using standard src/ layout with pytest for testing."
        ;;
    node)
        COMMANDS_DEV="- \`npm install\` — Install dependencies\n- \`npm run dev\` — Start the development server\n- \`npm run build\` — Build for production"
        COMMANDS_TEST="- \`npm test\` — Run all tests\n- \`npm run test:unit\` — Run unit tests only\n- \`npm run test:e2e\` — Run end-to-end tests\n- \`npm run lint\` — Run ESLint"
        COMMANDS_DEPLOY="- \`npm run deploy\` — Deploy the application\n- \`bash scripts/deploy.sh staging\` — Deploy to staging\n- \`bash scripts/deploy.sh production\` — Deploy to production"
        ARCHITECTURE="Node.js/TypeScript project using src/ layout with Vitest for testing."
        ;;
    generic)
        COMMANDS_DEV="- \`make dev\` — Start the development environment\n- Refer to the project Makefile for available targets"
        COMMANDS_TEST="- \`make test\` — Run tests\n- Configure test commands in the Makefile"
        COMMANDS_DEPLOY="- \`make deploy\` — Deploy the application\n- Configure deployment commands in the Makefile"
        ARCHITECTURE="Generic project. Update this section with your project's architecture details."
        ;;
esac

# =============================================================================
# 5b. Generate AGENTS.md (all tiers — agent-agnostic standards)
# =============================================================================
AGENTS_TEMPLATE="$SCRIPT_DIR/core/docs/AGENTS-template.md"
if [[ -f "$AGENTS_TEMPLATE" ]]; then
    sed \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{LANGUAGE}}|$LANGUAGE|g" \
        -e "s|{{TIER}}|$TIER|g" \
        -e "s|{{COMMANDS_DEV}}|$COMMANDS_DEV|g" \
        -e "s|{{COMMANDS_TEST}}|$COMMANDS_TEST|g" \
        -e "s|{{COMMANDS_DEPLOY}}|$COMMANDS_DEPLOY|g" \
        -e "s|{{ARCHITECTURE}}|$ARCHITECTURE|g" \
        "$AGENTS_TEMPLATE" > "$PROJECT_DIR/AGENTS.md"
    success "Generated AGENTS.md (agent-agnostic standards)"
fi

# =============================================================================
# 5c. Generate docs/SESSION_LOG.md and docs/ directory
# =============================================================================
mkdir -p "$PROJECT_DIR/docs"
cat > "$PROJECT_DIR/docs/SESSION_LOG.md" << 'SESSIONEOF'
# Session Log

> This log tracks all working sessions, decisions, discoveries, and action items.
> Update with every meaningful progress point. Newest entries at the top.
> See AGENTS.md for the required entry format.
> Every entry heading ends with the agent that wrote it: `## YYYY-MM-DD — Title — Claude` (or Codex, Gemini, a person).

---

SESSIONEOF
success "Generated docs/SESSION_LOG.md"

# =============================================================================
# 5d. Generate docs/plans/BACKLOG.md (canonical, tier-differentiated)
# =============================================================================
mkdir -p "$PROJECT_DIR/docs/plans"
BACKLOG_TEMPLATE="$SCRIPT_DIR/core/docs/BACKLOG-$TIER-template.md"
if [[ -f "$BACKLOG_TEMPLATE" ]]; then
    SCAFFOLD_DATE="$(date +%Y-%m-%d)"
    sed \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{REPO_CODE}}|$REPO_CODE|g" \
        -e "s|{{REPO_CODE_LOWER}}|$REPO_CODE_LOWER|g" \
        -e "s|{{SCAFFOLD_DATE}}|$SCAFFOLD_DATE|g" \
        "$BACKLOG_TEMPLATE" > "$PROJECT_DIR/docs/plans/BACKLOG.md"
    success "Generated docs/plans/BACKLOG.md ($TIER tier, REPO-CODE $REPO_CODE)"
else
    warn "No BACKLOG-$TIER-template.md found; skipping canonical backlog generation"
fi

# =============================================================================
# 6. Generate CLAUDE.md
# =============================================================================
CLAUDE_TEMPLATE="$SCRIPT_DIR/core/docs/CLAUDE-template.md"
if [[ -f "$CLAUDE_TEMPLATE" ]]; then

    sed \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{LANGUAGE}}|$LANGUAGE|g" \
        -e "s|{{TIER}}|$TIER|g" \
        -e "s|{{COMMANDS_DEV}}|$COMMANDS_DEV|g" \
        -e "s|{{COMMANDS_TEST}}|$COMMANDS_TEST|g" \
        -e "s|{{COMMANDS_DEPLOY}}|$COMMANDS_DEPLOY|g" \
        -e "s|{{ARCHITECTURE}}|$ARCHITECTURE|g" \
        "$CLAUDE_TEMPLATE" > "$PROJECT_DIR/CLAUDE.md"
    success "Generated CLAUDE.md"
fi

# =============================================================================
# 6b. Generate GEMINI.md (thin shim that imports AGENTS.md; Codex reads AGENTS.md natively)
# =============================================================================
GEMINI_TEMPLATE="$SCRIPT_DIR/core/docs/GEMINI-template.md"
if [[ -f "$GEMINI_TEMPLATE" ]]; then
    cp "$GEMINI_TEMPLATE" "$PROJECT_DIR/GEMINI.md"
    success "Generated GEMINI.md (imports AGENTS.md)"
fi

# =============================================================================
# 7. Generate README.md
# =============================================================================
README_TEMPLATE="$SCRIPT_DIR/core/docs/README-template.md"
if [[ -f "$README_TEMPLATE" ]]; then
    # Determine language-appropriate README sections
    case "$LANGUAGE" in
        python)
            DESCRIPTION="A Python enterprise project scaffolded with enterprise-templates."
            PREREQUISITES="- Python 3.10+\n- pip\n- make (optional)"
            INSTALL_COMMANDS="\`\`\`bash\npip install -r requirements.txt\npip install -r requirements-dev.txt\n\`\`\`"
            DEV_COMMANDS="\`\`\`bash\nmake dev\n\`\`\`"
            TEST_COMMANDS="\`\`\`bash\nmake test\nmake lint\n\`\`\`"
            DEPLOY_COMMANDS="\`\`\`bash\nbash scripts/deploy.sh staging\nbash scripts/deploy.sh production\n\`\`\`"
            ARCHITECTURE="Standard Python src/ layout with pytest-based testing."
            LICENSE="MIT"
            ;;
        node)
            DESCRIPTION="A Node.js/TypeScript enterprise project scaffolded with enterprise-templates."
            PREREQUISITES="- Node.js 20+\n- npm"
            INSTALL_COMMANDS="\`\`\`bash\nnpm install\n\`\`\`"
            DEV_COMMANDS="\`\`\`bash\nnpm run dev\n\`\`\`"
            TEST_COMMANDS="\`\`\`bash\nnpm test\nnpm run lint\n\`\`\`"
            DEPLOY_COMMANDS="\`\`\`bash\nbash scripts/deploy.sh staging\nbash scripts/deploy.sh production\n\`\`\`"
            ARCHITECTURE="Node.js/TypeScript src/ layout with Vitest-based testing."
            LICENSE="MIT"
            ;;
        generic)
            DESCRIPTION="An enterprise project scaffolded with enterprise-templates."
            PREREQUISITES="- See Makefile for requirements"
            INSTALL_COMMANDS="\`\`\`bash\nmake install\n\`\`\`"
            DEV_COMMANDS="\`\`\`bash\nmake dev\n\`\`\`"
            TEST_COMMANDS="\`\`\`bash\nmake test\n\`\`\`"
            DEPLOY_COMMANDS="\`\`\`bash\nmake deploy\n\`\`\`"
            ARCHITECTURE="Update this section with your project's architecture."
            LICENSE="MIT"
            ;;
    esac

    sed \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{DESCRIPTION}}|$DESCRIPTION|g" \
        -e "s|{{PREREQUISITES}}|$PREREQUISITES|g" \
        -e "s|{{INSTALL_COMMANDS}}|$INSTALL_COMMANDS|g" \
        -e "s|{{DEV_COMMANDS}}|$DEV_COMMANDS|g" \
        -e "s|{{TEST_COMMANDS}}|$TEST_COMMANDS|g" \
        -e "s|{{DEPLOY_COMMANDS}}|$DEPLOY_COMMANDS|g" \
        -e "s|{{ARCHITECTURE}}|$ARCHITECTURE|g" \
        -e "s|{{LICENSE}}|$LICENSE|g" \
        "$README_TEMPLATE" > "$PROJECT_DIR/README.md"
    success "Generated README.md"
fi

# =============================================================================
# 8. Copy CHANGELOG
# =============================================================================
CHANGELOG_SRC="$SCRIPT_DIR/core/docs/CHANGELOG-template.md"
if [[ -f "$CHANGELOG_SRC" ]]; then
    cp "$CHANGELOG_SRC" "$PROJECT_DIR/CHANGELOG.md"
    success "Copied CHANGELOG.md"
else
    # Fallback to documentation directory
    CHANGELOG_SRC="$SCRIPT_DIR/documentation/CHANGELOG-template.md"
    if [[ -f "$CHANGELOG_SRC" ]]; then
        cp "$CHANGELOG_SRC" "$PROJECT_DIR/CHANGELOG.md"
        success "Copied CHANGELOG.md"
    fi
fi

# =============================================================================
# 9. Initialize git repo
# =============================================================================
info "Initializing git repository..."
cd "$PROJECT_DIR"
git init -b main --quiet
git add -A
git commit -m "Initial commit: $PROJECT_NAME ($LANGUAGE, $TIER tier)" --quiet
success "Git repository initialized with initial commit on main"

# Create staging and development branches (standard/production only)
if [[ "$TIER" == "standard" || "$TIER" == "production" ]]; then
    git branch staging
    git branch development
    success "Created staging and development branches"
fi

# =============================================================================
# 10. Optionally create GitHub repo
# =============================================================================
if [[ "$CREATE_REPO" == "yes" ]]; then
    if ! command -v gh &>/dev/null; then
        warn "GitHub CLI (gh) not found. Skipping repository creation."
        warn "Install it with: brew install gh"
    else
        info "Creating GitHub repository..."

        if [[ -n "$GH_ORG" ]]; then
            REPO_FULL="$GH_ORG/$PROJECT_NAME"
            gh repo create "$REPO_FULL" --private --source=. --push 2>/dev/null \
                && success "Created GitHub repo: $REPO_FULL" \
                || warn "Failed to create GitHub repo. You may need to run 'gh auth login' first."
        else
            gh repo create "$PROJECT_NAME" --private --source=. --push 2>/dev/null \
                && success "Created GitHub repo: $PROJECT_NAME" \
                || warn "Failed to create GitHub repo. You may need to run 'gh auth login' first."
        fi

        # Push additional branches
        if [[ "$TIER" == "standard" || "$TIER" == "production" ]]; then
            git push -u origin staging 2>/dev/null || warn "Could not push staging branch"
            git push -u origin development 2>/dev/null || warn "Could not push development branch"
            success "Pushed all branches to remote"
        fi
    fi
fi

# =============================================================================
# 11. Append REPO-CODE to the canonical ID registry (Lex Immutabilis)
# =============================================================================
if [[ -f "$REPO_ID_REGISTRY" ]]; then
    REGISTRY_ROW="| **${REPO_CODE}** | repo | \`${PROJECT_NAME}\` (${PROJECT_DIR/#$HOME/~}) | \`docs/plans/BACKLOG.md\` | — | TBD | TBD | TBD | $(date +%Y-%m-%d) |"
    MARKER="<!-- scaffold-append-repo —"
    if grep -q "$MARKER" "$REPO_ID_REGISTRY"; then
        # macOS sed -i requires empty string backup suffix
        sed -i '' "/${MARKER}/i\\
${REGISTRY_ROW}
" "$REPO_ID_REGISTRY"
        success "Registered ${REPO_CODE} → ${PROJECT_NAME} in $REPO_ID_REGISTRY"
    else
        warn "Registry append marker not found — append manually:"
        warn "  $REGISTRY_ROW"
    fi
else
    warn "Registry not found; skipping auto-registration."
    warn "Manually add row to the registry when you're back on the main machine:"
    warn "  | **${REPO_CODE}** | repo | \`${PROJECT_NAME}\` | \`docs/plans/BACKLOG.md\` | — | TBD | TBD | TBD | $(date +%Y-%m-%d) |"
fi

# =============================================================================
# Done
# =============================================================================
echo ""
echo "=========================================="
success "Project $PROJECT_NAME created successfully!"
echo ""
info "Location:   $PROJECT_DIR"
info "REPO-CODE:  $REPO_CODE (first backlog item will be ${REPO_CODE}-1)"
info "Language:   $LANGUAGE"
info "Tier:       $TIER"
echo ""
info "Next steps:"
echo "  cd $PROJECT_DIR"
if [[ "$LANGUAGE" == "python" ]]; then
    echo "  pip install -r requirements.txt"
    echo "  make dev"
elif [[ "$LANGUAGE" == "node" ]]; then
    echo "  npm install"
    echo "  npm run dev"
else
    echo "  make dev"
fi
echo "=========================================="
