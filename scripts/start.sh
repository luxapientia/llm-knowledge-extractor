#!/bin/bash

# LLM Knowledge Extractor - Development Server Starter
# Starts the development server with hot reload

set -e

# Source shared utilities
source "$(dirname "$0")/utils.sh"

echo "Starting LLM Knowledge Extractor development server..."
echo "=================================================="

# Check if .env exists
if ! check_env_file; then
    exit 1
fi

# Check if uvicorn is installed
if ! command_exists uvicorn; then
    print_error "uvicorn not found. Please install dependencies:"
    echo "  pip3 install -r requirements.txt"
    exit 1
fi

print_status "Starting development server with hot reload..."
echo ""
echo "Server: http://localhost:8000"
echo "API Docs: http://localhost:8000/docs"
echo "Health Check: http://localhost:8000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server with hot reload
uvicorn app.api:app --host 0.0.0.0 --port 8000 --reload