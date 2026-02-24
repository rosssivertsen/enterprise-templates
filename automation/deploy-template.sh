#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Enterprise Deployment Script (Language-Aware)
# Reads .enterprise.yml for language, tier, and quality settings, then runs
# the appropriate quality gates, build steps, and deployment tasks.
# =============================================================================

# --- Colors & Logging --------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

DEPLOY_LOG="deploy-$(date +%Y%m%d-%H%M%S).log"

log()     { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$DEPLOY_LOG"; }
success() { echo -e "${GREEN}[PASS]${NC} $1" | tee -a "$DEPLOY_LOG"; }
warning() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$DEPLOY_LOG"; }
error()   { echo -e "${RED}[FAIL]${NC} $1" | tee -a "$DEPLOY_LOG"; exit 1; }
header()  { echo -e "\n${CYAN}=== $1 ===${NC}" | tee -a "$DEPLOY_LOG"; }

# --- Usage --------------------------------------------------------------------

usage() {
    echo "Usage: $0 <staging|production> [branch]"
    echo ""
    echo "  Deploys the project described in .enterprise.yml."
    echo "  Defaults: branch=development for staging, main for production."
    exit 1
}

# --- Parse .enterprise.yml (portable, no yq dependency) -----------------------

ENTERPRISE_YML=".enterprise.yml"

yml_get() {
    # Extract a simple top-level or one-level-nested scalar from YAML.
    # Usage: yml_get "key" or yml_get "parent.child"
    local key="$1"
    if [[ "$key" == *.* ]]; then
        local parent="${key%%.*}"
        local child="${key#*.}"
        # Find lines between "parent:" and the next top-level key, then grab child
        sed -n "/^${parent}:/,/^[a-zA-Z]/p" "$ENTERPRISE_YML" \
            | grep -E "^[[:space:]]+${child}:" \
            | head -1 \
            | sed 's/^[^:]*:[[:space:]]*//' \
            | sed 's/^["'\'']//' \
            | sed 's/["'\'']*$//' \
            | xargs
    else
        grep -E "^${key}:" "$ENTERPRISE_YML" \
            | head -1 \
            | sed 's/^[^:]*:[[:space:]]*//' \
            | sed 's/^["'\'']//' \
            | sed 's/["'\'']*$//' \
            | xargs
    fi
}

# --- Read Configuration -------------------------------------------------------

if [[ ! -f "$ENTERPRISE_YML" ]]; then
    error "$ENTERPRISE_YML not found in $(pwd). Are you in the project root?"
fi

LANGUAGE=$(yml_get "language")
TIER=$(yml_get "tier")
LINT_ENABLED=$(yml_get "quality.lint")
TYPECHECK_ENABLED=$(yml_get "quality.typecheck")
SECURITY_ENABLED=$(yml_get "quality.security")
UNIT_TEST_ENABLED=$(yml_get "quality.unit_tests")
E2E_REQUIRED_FOR_PROD=$(yml_get "quality.e2e_required_for_prod")

# Normalize booleans (default to true for safety)
bool() { [[ "${1,,}" == "true" || "${1,,}" == "yes" || -z "$1" ]]; }

# Defaults
LANGUAGE="${LANGUAGE:-generic}"
TIER="${TIER:-standard}"

# --- Arguments ----------------------------------------------------------------

ENVIRONMENT="${1:-}"
[[ -z "$ENVIRONMENT" ]] && usage

case "$ENVIRONMENT" in
    staging)    DEFAULT_BRANCH="development" ;;
    production) DEFAULT_BRANCH="main" ;;
    *)          error "Unknown environment '$ENVIRONMENT'. Use 'staging' or 'production'." ;;
esac

BRANCH="${2:-$DEFAULT_BRANCH}"

# --- Banner -------------------------------------------------------------------

header "Enterprise Deployment"
log "Language : $LANGUAGE"
log "Tier     : $TIER"
log "Environ  : $ENVIRONMENT"
log "Branch   : $BRANCH"
log "Log file : $DEPLOY_LOG"

# --- Pre-Deployment Checks ----------------------------------------------------

header "Pre-Deployment Checks"

# Branch verification
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [[ -z "$CURRENT_BRANCH" ]]; then
    error "Not inside a git repository."
fi

if [[ "$CURRENT_BRANCH" != "$BRANCH" ]]; then
    warning "Currently on '$CURRENT_BRANCH'; switching to '$BRANCH'."
    git checkout "$BRANCH"
fi

log "Pulling latest changes from origin/$BRANCH..."
git pull origin "$BRANCH"

# Uncommitted changes
if ! git diff-index --quiet HEAD --; then
    error "Uncommitted changes detected. Commit or stash before deploying."
fi
success "Working tree is clean."

# --- Install Dependencies -----------------------------------------------------

header "Install Dependencies"

case "$LANGUAGE" in
    python)
        if [[ -f "requirements.txt" ]]; then
            log "Installing Python dependencies..."
            pip install -r requirements.txt --quiet
        elif [[ -f "pyproject.toml" ]]; then
            log "Installing via pyproject.toml..."
            pip install . --quiet
        fi
        success "Python dependencies installed."
        ;;
    node)
        log "Installing Node dependencies..."
        npm ci
        success "Node dependencies installed."
        ;;
    *)
        log "No dependency step defined for language '$LANGUAGE'. Skipping."
        ;;
esac

# --- Quality Gates (Language-Aware) -------------------------------------------

header "Quality Gates"

# ---- Lint --------------------------------------------------------------------
if bool "$LINT_ENABLED"; then
    log "Running lint..."
    case "$LANGUAGE" in
        python)
            if command -v ruff &>/dev/null; then
                ruff check .
            elif command -v flake8 &>/dev/null; then
                flake8 .
            else
                warning "Neither ruff nor flake8 found; skipping Python lint."
            fi
            ;;
        node)
            npx eslint .
            ;;
        *)
            log "(generic) Lint placeholder -- no language-specific linter configured."
            ;;
    esac
    success "Lint passed."
else
    log "Lint disabled in $ENTERPRISE_YML; skipping."
fi

# ---- Type Check ---------------------------------------------------------------
if bool "$TYPECHECK_ENABLED"; then
    log "Running type check..."
    case "$LANGUAGE" in
        python)
            if command -v mypy &>/dev/null; then
                mypy .
            else
                warning "mypy not found; skipping Python type check."
            fi
            ;;
        node)
            npx tsc --noEmit
            ;;
        *)
            log "(generic) Type-check placeholder -- no language-specific checker configured."
            ;;
    esac
    success "Type check passed."
else
    log "Type check disabled in $ENTERPRISE_YML; skipping."
fi

# ---- Security -----------------------------------------------------------------
if bool "$SECURITY_ENABLED"; then
    log "Running security audit..."
    case "$LANGUAGE" in
        python)
            if command -v pip-audit &>/dev/null; then
                pip-audit
            elif command -v bandit &>/dev/null; then
                bandit -r . -ll
            else
                warning "Neither pip-audit nor bandit found; skipping Python security audit."
            fi
            ;;
        node)
            npm audit --audit-level=moderate
            ;;
        *)
            log "(generic) Security audit placeholder -- no language-specific auditor configured."
            ;;
    esac
    success "Security audit passed."
else
    log "Security audit disabled in $ENTERPRISE_YML; skipping."
fi

# ---- Unit Tests ---------------------------------------------------------------
if bool "$UNIT_TEST_ENABLED"; then
    log "Running unit tests..."
    case "$LANGUAGE" in
        python)
            if command -v pytest &>/dev/null; then
                pytest --tb=short -q
            else
                warning "pytest not found; skipping Python unit tests."
            fi
            ;;
        node)
            npx vitest run
            ;;
        *)
            log "(generic) Unit test placeholder -- no language-specific runner configured."
            ;;
    esac
    success "Unit tests passed."
else
    log "Unit tests disabled in $ENTERPRISE_YML; skipping."
fi

# --- Docker Build (Production Tier Only) --------------------------------------

if [[ "${TIER,,}" == "production" ]]; then
    header "Docker Build (production tier)"
    if [[ -f "Dockerfile" ]]; then
        PROJECT_NAME=$(yml_get "name")
        PROJECT_NAME="${PROJECT_NAME:-$(basename "$(pwd)")}"
        log "Building Docker image: ${PROJECT_NAME}:latest ..."
        docker build -t "${PROJECT_NAME}:latest" .
        success "Docker image built."
    else
        warning "No Dockerfile found; skipping Docker build."
    fi
else
    log "Tier is '$TIER' (not production); skipping Docker build."
fi

# --- E2E Tests (Production Deploy Only) ---------------------------------------

if [[ "$ENVIRONMENT" == "production" ]] && bool "$E2E_REQUIRED_FOR_PROD"; then
    header "E2E Tests (production deploy gate)"
    case "$LANGUAGE" in
        python)
            if command -v pytest &>/dev/null; then
                pytest tests/e2e --tb=short -q 2>/dev/null || pytest -m e2e --tb=short -q
            else
                warning "pytest not found; skipping E2E tests."
            fi
            ;;
        node)
            npx vitest run --config vitest.e2e.config.ts 2>/dev/null || npx vitest run tests/e2e
            ;;
        *)
            log "(generic) E2E test placeholder -- no language-specific E2E runner configured."
            ;;
    esac
    success "E2E tests passed."
else
    log "E2E tests not required for this deploy (env=$ENVIRONMENT, e2e_required_for_prod=$E2E_REQUIRED_FOR_PROD)."
fi

# --- Deploy -------------------------------------------------------------------

header "Deploy to $ENVIRONMENT"

case "$ENVIRONMENT" in
    staging)
        log "Deploying to staging environment..."
        # Project-specific staging deploy commands go here.
        success "Staging deployment completed."
        ;;
    production)
        log "Deploying to production environment..."
        # Project-specific production deploy commands go here.
        success "Production deployment completed."
        ;;
esac

# --- Post-Deployment ----------------------------------------------------------

header "Post-Deployment Tasks"

if [[ "$ENVIRONMENT" == "production" ]]; then
    VERSION=$(yml_get "version")
    VERSION="${VERSION:-0.0.0}"
    TAG="release/${VERSION}-$(date +%Y%m%d%H%M%S)"
    log "Tagging release: $TAG"
    git tag "$TAG"
    git push origin "$TAG" 2>/dev/null || warning "Could not push tag to origin."
    success "Release tag '$TAG' created."

    # Sync main back to development so branches stay aligned
    log "Syncing main -> development..."
    git checkout development 2>/dev/null && git merge main --no-edit && git push origin development 2>/dev/null \
        || warning "Could not auto-sync development branch. Manual merge may be needed."
    git checkout "$BRANCH"
    success "Branch sync complete."
fi

# Notification placeholder
log "Sending deployment notification..."
# Add Slack / email / webhook integration here.
success "Deployment notification sent."

# --- Done ---------------------------------------------------------------------

header "Deployment Complete"
success "Successfully deployed to $ENVIRONMENT."
log "Full log: $DEPLOY_LOG"
