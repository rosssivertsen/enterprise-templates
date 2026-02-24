.PHONY: help lint test build run clean

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint:  ## Run linters (configure for your language)
	@echo "Configure lint command for your project"

test:  ## Run tests (configure for your language)
	@echo "Configure test command for your project"

build:  ## Build project (configure for your language)
	@echo "Configure build command for your project"

run:  ## Run the application
	@echo "Configure run command for your project"

clean:  ## Remove build artifacts
	@echo "Configure clean command for your project"
