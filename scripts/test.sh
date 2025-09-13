#!/bin/bash

# LLM Knowledge Extractor - Test Runner
# Runs the test suite with various options

set -e

# Source shared utilities
source "$(dirname "$0")/utils.sh"

echo "LLM Knowledge Extractor - Test Runner"
echo "===================================="

# Check if pytest is installed
if ! command_exists pytest; then
    print_error "pytest not found. Please install dependencies:"
    echo "  pip3 install -r requirements.txt"
    exit 1
fi

# Default test command
TEST_CMD="python3 -m pytest tests/ -v"

# Parse command line arguments
COVERAGE=false
VERBOSE=false
SPECIFIC_TEST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --coverage)
            COVERAGE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --file)
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --coverage    Run tests with coverage report"
            echo "  --verbose     Extra verbose output"
            echo "  --file FILE   Run specific test file"
            echo "  --help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                           # Run all tests"
            echo "  $0 --coverage               # Run with coverage"
            echo "  $0 --file test_api.py        # Run specific test file"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Build test command
if [ "$COVERAGE" = true ]; then
    TEST_CMD="$TEST_CMD --cov=app --cov-report=html --cov-report=term"
fi

if [ "$VERBOSE" = true ]; then
    TEST_CMD="$TEST_CMD -s"
fi

if [ -n "$SPECIFIC_TEST" ]; then
    TEST_CMD="python3 -m pytest tests/$SPECIFIC_TEST -v"
fi

print_status "Running tests..."
echo "Command: $TEST_CMD"
echo ""

# Run tests
if $TEST_CMD; then
    print_success "All tests passed!"

    if [ "$COVERAGE" = true ]; then
        echo ""
        print_status "Coverage report generated in htmlcov/index.html"
    fi
else
    print_error "Some tests failed"
    exit 1
fi