#!/bin/bash

# LLM Knowledge Extractor - Database Migration Script
# Handles database migrations

set -e

# Source shared utilities
source "$(dirname "$0")/utils.sh"

echo "LLM Knowledge Extractor - Database Migration"
echo "============================================"

# Check if alembic is installed
if ! command_exists alembic; then
    print_error "alembic not found. Please install dependencies:"
    echo "  pip3 install -r requirements.txt"
    exit 1
fi

# Check if .env exists
if ! check_env_file; then
    exit 1
fi

# Parse command line arguments
COMMAND="upgrade"
MESSAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        upgrade)
            COMMAND="upgrade"
            shift
            ;;
        downgrade)
            COMMAND="downgrade"
            shift
            ;;
        create)
            COMMAND="create"
            MESSAGE="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  upgrade           Apply all pending migrations (default)"
            echo "  downgrade         Rollback last migration"
            echo "  create MESSAGE    Create new migration with message"
            echo "  --help            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Apply all migrations"
            echo "  $0 upgrade                   # Apply all migrations"
            echo "  $0 downgrade                 # Rollback last migration"
            echo "  $0 create \"Add user table\"   # Create new migration"
            exit 0
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Execute migration command
case $COMMAND in
    upgrade)
        print_status "Applying database migrations..."
        if alembic upgrade head; then
            print_success "Database migrations applied successfully"
        else
            print_error "Failed to apply migrations"
            exit 1
        fi
        ;;
    downgrade)
        print_warning "Rolling back last migration..."
        if alembic downgrade -1; then
            print_success "Migration rolled back successfully"
        else
            print_error "Failed to rollback migration"
            exit 1
        fi
        ;;
    create)
        if [ -z "$MESSAGE" ]; then
            print_error "Migration message is required"
            echo "Usage: $0 create \"Your migration message\""
            exit 1
        fi
        print_status "Creating new migration: $MESSAGE"
        if alembic revision --autogenerate -m "$MESSAGE"; then
            print_success "Migration created successfully"
            print_warning "Please review the generated migration file before applying"
        else
            print_error "Failed to create migration"
            exit 1
        fi
        ;;
esac