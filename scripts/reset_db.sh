#!/bin/bash

# LLM Knowledge Extractor - Database Reset Script
# Resets the database (useful for development)

set -e

# Source shared utilities
source "$(dirname "$0")/utils.sh"

echo "LLM Knowledge Extractor - Database Reset"
echo "======================================="

# Check if .env exists
if ! check_env_file; then
    exit 1
fi

# Confirmation prompt
print_warning "This will DROP and recreate the database!"
print_warning "All data will be lost!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    print_status "Database reset cancelled"
    exit 0
fi

# Database configuration
DB_NAME="llm_extractor"
DB_USER="user"

print_status "Dropping database..."

# Drop database (ignore errors if it doesn't exist)
sudo -u postgres psql -c "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null || true

print_status "Creating fresh database..."

# Create fresh database
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

print_success "Database recreated successfully"

print_status "Running migrations..."

if alembic upgrade head; then
    print_success "Database reset completed successfully"
else
    print_error "Failed to run migrations after reset"
    exit 1
fi

echo ""
print_success "Database has been reset and is ready for use!"