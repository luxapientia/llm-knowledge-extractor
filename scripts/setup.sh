#!/bin/bash

# LLM Knowledge Extractor - Local Development Setup Script
# This script sets up the local development environment

set -e

# Source shared utilities
source "$(dirname "$0")/utils.sh"

echo "LLM Knowledge Extractor - Local Development Setup"
echo "================================================="

# Check if we're in the right directory
if ! check_project_root; then
    exit 1
fi

# Check system dependencies
print_status "Checking system dependencies..."

# Check Python 3
if ! command_exists python3; then
    print_error "Python 3 not found. Please install Python 3.8+"
    exit 1
else
    PYTHON_VERSION=$(python3 --version)
    print_success "Python: $PYTHON_VERSION"
fi

# Check PostgreSQL
if ! command_exists psql; then
    print_error "PostgreSQL not found. Please install PostgreSQL:"
    echo "  Ubuntu/Debian: sudo apt install postgresql postgresql-contrib"
    echo "  macOS: brew install postgresql"
    exit 1
else
    PSQL_VERSION=$(psql --version)
    print_success "PostgreSQL: $PSQL_VERSION"
fi

# Setup environment
print_status "Setting up environment configuration..."

if [ ! -f ".env" ]; then
    if [ -f "env.example" ]; then
        cp env.example .env
        print_success "Created .env file from template"
    else
        print_error "env.example not found"
        exit 1
    fi
else
    print_success ".env file already exists"
fi

# Check if OpenAI API key is set
if grep -q "your_openai_api_key_here" .env; then
    print_warning "Please edit .env file and add your OpenAI API key"
    echo "  Set OPENAI_API_KEY=your_actual_api_key"
    echo ""
    read -p "Press Enter after you've updated the .env file..."
fi

# Setup database
print_status "Setting up PostgreSQL database..."

DB_NAME="llm_extractor"
DB_USER="postgres"
DB_PASSWORD="postgres"

# Create database and user (ignore errors if they already exist)
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || true
sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || true
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;" 2>/dev/null || true

print_success "Database setup completed"

# Install Python dependencies
print_status "Installing Python dependencies..."

if ! pip3 install -r requirements.txt; then
    print_error "Failed to install Python dependencies"
    exit 1
fi

print_success "Python dependencies installed"

# Download spaCy model
print_status "Downloading spaCy model..."

if ! python3 -m spacy download en_core_web_sm; then
    print_error "Failed to download spaCy model"
    exit 1
fi

print_success "spaCy model downloaded"

# Run migrations
print_status "Running database migrations..."

if ! alembic upgrade head; then
    print_error "Failed to run database migrations"
    exit 1
fi

print_success "Database migrations completed"

# Run tests
print_status "Running tests..."

if python3 -m pytest tests/ -v; then
    print_success "All tests passed"
else
    print_warning "Some tests failed, but continuing with setup"
fi

echo ""
echo "Setup completed successfully!"
echo ""
echo "Next steps:"
echo "   1. Run: ./scripts/start.sh"
echo "   2. Visit http://localhost:8000/docs for API documentation"
echo ""
echo "Development commands:"
echo "   Start server:     ./scripts/start.sh"
echo "   Run tests:        ./scripts/test.sh"
echo "   Run migrations:   ./scripts/migrate.sh"
echo "   Clean database:   ./scripts/reset_db.sh"