# LLM Knowledge Extractor - Makefile
# Provides convenient shortcuts for common development tasks

.PHONY: help setup start test migrate reset-db deploy clean

# Default target
help:
	@echo "LLM Knowledge Extractor - Available Commands"
	@echo "============================================="
	@echo ""
	@echo "Development:"
	@echo "  make setup      - Set up local development environment"
	@echo "  make start      - Start development server"
	@echo "  make test       - Run test suite"
	@echo "  make test-cov   - Run tests with coverage"
	@echo ""
	@echo "Database:"
	@echo "  make migrate    - Apply database migrations"
	@echo "  make migrate-create MSG='message' - Create new migration"
	@echo "  make reset-db   - Reset database (development only)"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy     - Deploy with Docker Compose"
	@echo "  make deploy-build - Deploy with rebuild"
	@echo "  make stop       - Stop application"
	@echo ""
	@echo "Utilities:"
	@echo "  make clean      - Clean up temporary files"
	@echo "  make help       - Show this help message"

# Development setup
setup:
	@./scripts/setup.sh

# Start development server
start:
	@./scripts/start.sh

# Testing
test:
	@./scripts/test.sh

test-cov:
	@./scripts/test.sh --coverage

# Database operations
migrate:
	@./scripts/migrate.sh

migrate-create:
	@./scripts/migrate.sh create "$(MSG)"

reset-db:
	@./scripts/reset_db.sh

# Deployment
deploy:
	@./scripts/deploy.sh

deploy-build:
	@./scripts/deploy.sh --build

stop:
	@./scripts/deploy.sh down

# Cleanup
clean:
	@echo "Cleaning up temporary files..."
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@find . -type d -name ".pytest_cache" -delete
	@find . -type d -name "htmlcov" -delete
	@rm -rf .coverage
	@echo "Cleanup completed"