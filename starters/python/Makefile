.PHONY: help install dev lint type-check security test test-e2e coverage build run clean

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install:  ## Install production dependencies
	pip install -r requirements.txt

dev:  ## Install all dependencies (production + dev)
	pip install -r requirements.txt -r requirements-dev.txt

lint:  ## Run linters (flake8 + ruff)
	flake8 src/ --max-line-length=120
	ruff check src/

type-check:  ## Run type checking (mypy)
	mypy src/

security:  ## Run security audit
	pip-audit
	bandit -r src/ -ll

test:  ## Run unit tests
	pytest tests/unit/ -v

test-e2e:  ## Run E2E integration tests
	pytest tests/e2e/ -v

coverage:  ## Run tests with coverage
	pytest tests/unit/ -v --cov=src --cov-report=term-missing --cov-fail-under=80

build:  ## Build Docker image
	docker build -t $$(basename $$(pwd)) .

run:  ## Run the application
	python -m uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload

clean:  ## Remove build artifacts
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	rm -rf .mypy_cache .pytest_cache .ruff_cache htmlcov .coverage
