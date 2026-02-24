#!/bin/bash

# Scaffold Output Validation Script
# Validates that all required template files exist and are valid
# without running scaffold.sh (which requires interactive input)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "======================================"
echo "Scaffold Template Validator"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"

    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${BLUE}TEST $TESTS_TOTAL: $test_name${NC}"

    if eval "$test_command"; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo ""
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo ""
        return 1
    fi
}

# =========================================================================
# Phase 1: Template Existence (9 tests)
# =========================================================================
echo -e "${YELLOW}=== Phase 1: Template Existence ===${NC}"
echo ""

run_test "core/ci-cd/pipeline-python.yml exists" \
    "test -f '$ROOT_DIR/core/ci-cd/pipeline-python.yml'"

run_test "core/ci-cd/pipeline-node.yml exists" \
    "test -f '$ROOT_DIR/core/ci-cd/pipeline-node.yml'"

run_test "core/ci-cd/pipeline-generic.yml exists" \
    "test -f '$ROOT_DIR/core/ci-cd/pipeline-generic.yml'"

run_test "core/docker/Dockerfile.python exists" \
    "test -f '$ROOT_DIR/core/docker/Dockerfile.python'"

run_test "core/docker/Dockerfile.node exists" \
    "test -f '$ROOT_DIR/core/docker/Dockerfile.node'"

run_test "core/docker/Dockerfile.generic exists" \
    "test -f '$ROOT_DIR/core/docker/Dockerfile.generic'"

run_test "core/enterprise-template.yml exists" \
    "test -f '$ROOT_DIR/core/enterprise-template.yml'"

run_test "scaffold.sh exists and is executable" \
    "test -x '$ROOT_DIR/scaffold.sh'"

run_test "core/docs/ templates exist (README, CHANGELOG, CLAUDE)" \
    "test -f '$ROOT_DIR/core/docs/README-template.md' && test -f '$ROOT_DIR/core/docs/CHANGELOG-template.md' && test -f '$ROOT_DIR/core/docs/CLAUDE-template.md'"

# =========================================================================
# Phase 2: Starter Validation (6 tests)
# =========================================================================
echo -e "${YELLOW}=== Phase 2: Starter Validation ===${NC}"
echo ""

run_test "Python starter has pyproject.toml, Makefile, src/main.py" \
    "test -f '$ROOT_DIR/starters/python/pyproject.toml' && test -f '$ROOT_DIR/starters/python/Makefile' && test -f '$ROOT_DIR/starters/python/src/main.py'"

run_test "Python starter has tests/unit/test_main.py" \
    "test -f '$ROOT_DIR/starters/python/tests/unit/test_main.py'"

run_test "Python starter has requirements.txt" \
    "test -f '$ROOT_DIR/starters/python/requirements.txt'"

run_test "Node starter has package.json, tsconfig.json, src/main.ts" \
    "test -f '$ROOT_DIR/starters/node/package.json' && test -f '$ROOT_DIR/starters/node/tsconfig.json' && test -f '$ROOT_DIR/starters/node/src/main.ts'"

run_test "Node starter has tests/unit/main.test.ts" \
    "test -f '$ROOT_DIR/starters/node/tests/unit/main.test.ts'"

run_test "Generic starter has Makefile" \
    "test -f '$ROOT_DIR/starters/generic/Makefile'"

# =========================================================================
# Phase 3: Agent Validation (4 tests)
# =========================================================================
echo -e "${YELLOW}=== Phase 3: Agent Validation ===${NC}"
echo ""

run_test "core/agents/local/ has at least 6 skill .md files" \
    "[ \$(find '$ROOT_DIR/core/agents/local' -name '*.md' | wc -l) -ge 6 ]"

run_test "core/agents/ci/ has at least 4 .yml workflow files" \
    "[ \$(find '$ROOT_DIR/core/agents/ci' -name '*.yml' | wc -l) -ge 4 ]"

run_test "core/agents/llm-abstraction/python/llm_client.py exists" \
    "test -f '$ROOT_DIR/core/agents/llm-abstraction/python/llm_client.py'"

run_test "core/agents/llm-abstraction/node/llm-client.ts exists" \
    "test -f '$ROOT_DIR/core/agents/llm-abstraction/node/llm-client.ts'"

# =========================================================================
# Phase 4: Config Validation (3 tests)
# =========================================================================
echo -e "${YELLOW}=== Phase 4: Config Validation ===${NC}"
echo ""

run_test ".enterprise.yml template contains all required sections (project, branches, quality, agents, docker)" \
    "grep -q '^project:' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q '^branches:' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q '^quality:' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q '^agents:' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q '^docker:' '$ROOT_DIR/core/enterprise-template.yml'"

run_test ".enterprise.yml template contains all three tiers in comments" \
    "grep -q 'lite' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q 'standard' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q 'production' '$ROOT_DIR/core/enterprise-template.yml'"

run_test ".enterprise.yml template contains all three language options" \
    "grep -q 'python' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q 'node' '$ROOT_DIR/core/enterprise-template.yml' && \
     grep -q 'generic' '$ROOT_DIR/core/enterprise-template.yml'"

# =========================================================================
# Phase 5: Tier Validation (3 tests)
# =========================================================================
echo -e "${YELLOW}=== Phase 5: Tier Validation ===${NC}"
echo ""

run_test "Lite tier files exist (GITIGNORE templates, README template)" \
    "test -f '$ROOT_DIR/core/docs/GITIGNORE-python' && \
     test -f '$ROOT_DIR/core/docs/GITIGNORE-node' && \
     test -f '$ROOT_DIR/core/docs/GITIGNORE-generic' && \
     test -f '$ROOT_DIR/core/docs/README-template.md'"

run_test "Standard tier files exist (CI/CD pipelines, agent skills, test configs)" \
    "test -f '$ROOT_DIR/core/ci-cd/pipeline-python.yml' && \
     test -f '$ROOT_DIR/core/ci-cd/pipeline-node.yml' && \
     test -f '$ROOT_DIR/core/ci-cd/pipeline-generic.yml' && \
     test -d '$ROOT_DIR/core/agents/local' && \
     test -d '$ROOT_DIR/core/testing'"

run_test "Production tier files exist (Dockerfiles, deploy script)" \
    "test -f '$ROOT_DIR/core/docker/Dockerfile.python' && \
     test -f '$ROOT_DIR/core/docker/Dockerfile.node' && \
     test -f '$ROOT_DIR/core/docker/Dockerfile.generic' && \
     test -f '$ROOT_DIR/automation/deploy-template.sh'"

# =========================================================================
# Summary
# =========================================================================
echo "======================================"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo "======================================"
echo -e "Total Tests:  $TESTS_TOTAL"
echo -e "${GREEN}Passed:       $TESTS_PASSED${NC}"
echo -e "${RED}Failed:       $TESTS_FAILED${NC}"
echo "======================================"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}All scaffold templates are present and valid.${NC}"
    exit 0
else
    echo -e "${RED}SOME TESTS FAILED!${NC}"
    echo -e "${RED}Please review the failures above and fix the templates.${NC}"
    exit 1
fi
