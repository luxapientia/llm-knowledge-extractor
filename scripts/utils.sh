#!/bin/bash

# LLM Knowledge Extractor - Shared Utility Functions
# Common functions used across all scripts

# Function to print output
print_status() {
    echo "[INFO] $1"
}

print_success() {
    echo "[SUCCESS] $1"
}

print_warning() {
    echo "[WARNING] $1"
}

print_error() {
    echo "[ERROR] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if .env file exists and is properly configured
check_env_file() {
    if [ ! -f ".env" ]; then
        print_error ".env file not found. Please run setup first:"
        echo "  ./scripts/setup.sh"
        return 1
    fi
    
    if grep -q "your_openai_api_key_here" .env; then
        print_error "Please edit .env file and add your OpenAI API key"
        echo "  Set OPENAI_API_KEY=your_actual_api_key"
        return 1
    fi
    
    return 0
}

# Function to check if we're in the project root
check_project_root() {
    if [ ! -f "requirements.txt" ]; then
        print_error "Please run this script from the project root directory"
        return 1
    fi
    return 0
}