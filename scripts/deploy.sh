#!/bin/bash

# LLM Knowledge Extractor - Production Deployment Script
# Deploys the application using Docker Compose

set -e

# Source shared utilities
source "$(dirname "$0")/utils.sh"

echo "LLM Knowledge Extractor - Production Deployment"
echo "============================================="

# Check if Docker is installed
if ! command_exists docker; then
    print_error "Docker not found. Please install Docker:"
    echo "  https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command_exists docker-compose; then
    print_error "Docker Compose not found. Please install Docker Compose:"
    echo "  https://docs.docker.com/compose/install/"
    exit 1
fi

# Check if .env exists and is properly configured
if ! check_env_file; then
    exit 1
fi

# Parse command line arguments
COMMAND="up"
BUILD=false
DETACHED=false

while [[ $# -gt 0 ]]; do
    case $1 in
        up)
            COMMAND="up"
            shift
            ;;
        down)
            COMMAND="down"
            shift
            ;;
        restart)
            COMMAND="restart"
            shift
            ;;
        --build)
            BUILD=true
            shift
            ;;
        --detached|-d)
            DETACHED=true
            shift
            ;;
        --help)
            echo "Usage: $0 [COMMAND] [OPTIONS]"
            echo ""
            echo "Commands:"
            echo "  up        Start the application (default)"
            echo "  down      Stop the application"
            echo "  restart   Restart the application"
            echo "  --help    Show this help message"
            echo ""
            echo "Options:"
            echo "  --build     Force rebuild of images"
            echo "  --detached  Run in background"
            echo ""
            echo "Examples:"
            echo "  $0                    # Start application"
            echo "  $0 up --build         # Start with rebuild"
            echo "  $0 up --detached      # Start in background"
            echo "  $0 down               # Stop application"
            exit 0
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Build docker-compose command
COMPOSE_CMD="docker-compose up"

if [ "$BUILD" = true ]; then
    COMPOSE_CMD="docker-compose up --build"
fi

if [ "$DETACHED" = true ]; then
    COMPOSE_CMD="$COMPOSE_CMD -d"
fi

# Execute deployment command
case $COMMAND in
    up)
        print_status "Starting application..."
        echo "Command: $COMPOSE_CMD"

        if $COMPOSE_CMD; then
            print_success "Application started successfully"
            echo ""
            echo "Application: http://localhost:8000"
            echo "API Docs: http://localhost:8000/docs"
            echo "Health Check: http://localhost:8000/health"
            echo ""
            if [ "$DETACHED" = false ]; then
                echo "Press Ctrl+C to stop the application"
            fi
        else
            print_error "Failed to start application"
            exit 1
        fi
        ;;
    down)
        print_status "Stopping application..."
        if docker-compose down; then
            print_success "Application stopped successfully"
        else
            print_error "Failed to stop application"
            exit 1
        fi
        ;;
    restart)
        print_status "Restarting application..."
        if docker-compose down && docker-compose up -d; then
            print_success "Application restarted successfully"
            echo ""
            echo "Application: http://localhost:8000"
            echo "API Docs: http://localhost:8000/docs"
        else
            print_error "Failed to restart application"
            exit 1
        fi
        ;;
esac