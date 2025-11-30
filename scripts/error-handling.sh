#!/bin/bash

# Error Handling Module
# This module provides robust error handling for all scripts

# Enable strict mode with enhanced error handling
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling variables
SCRIPT_NAME="${0##*/}"
ERROR_COUNT=0
WARNING_COUNT=0

# Function to print error messages with enhanced formatting
error() {
    local message="$1"
    local line_number="${BASH_LINENO[0]}"
    echo -e "${RED}ERROR [${SCRIPT_NAME}:${line_number}]: $message${NC}" >&2
    ((ERROR_COUNT++))
}

# Function to print warning messages
warning() {
    local message="$1"
    local line_number="${BASH_LINENO[0]}"
    echo -e "${YELLOW}WARNING [${SCRIPT_NAME}:${line_number}]: $message${NC}" >&2
    ((WARNING_COUNT++))
}

# Function to print success messages
success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

# Function to print info messages
info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

# Function to print debug messages (only when DEBUG is set)
debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        local line_number="${BASH_LINENO[0]}"
        echo -e "${YELLOW}DEBUG [${SCRIPT_NAME}:${line_number}]: $1${NC}" >&2
    fi
}

# Function to check if a command exists
command_exists() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to validate required commands
validate_commands() {
    local missing_commands=()
    
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        error "Missing required commands: ${missing_commands[*]}"
        return 1
    fi
    
    return 0
}

# Function to check if a file exists and is readable
file_exists_and_readable() {
    local file="$1"
    if [[ -f "$file" && -r "$file" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if a directory exists and is accessible
directory_exists_and_accessible() {
    local dir="$1"
    if [[ -d "$dir" && -r "$dir" && -x "$dir" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate environment variable
validate_env_var() {
    local var_name="$1"
    local var_value="${!var_name:-}"
    
    if [[ -z "$var_value" ]]; then
        error "Environment variable $var_name is not set"
        return 1
    fi
    
    debug "Environment variable $var_name is set to: $var_value"
    return 0
}

# Function to create backup with error handling
create_backup() {
    local source="$1"
    local backup_dir="$2"
    
    if [[ ! -e "$source" ]]; then
        error "Source '$source' does not exist"
        return 1
    fi
    
    if [[ ! -d "$backup_dir" ]]; then
        if ! mkdir -p "$backup_dir"; then
            error "Failed to create backup directory: $backup_dir"
            return 1
        fi
    fi
    
    local backup_name="$(basename "$source")_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$backup_dir/$backup_name"
    
    if cp -r "$source" "$backup_path" 2>/dev/null; then
        success "Backup created: $backup_path"
        return 0
    else
        error "Failed to create backup of: $source"
        return 1
    fi
}

# Function to cleanup on exit
cleanup() {
    local exit_code=$?
    
    debug "Cleanup function called with exit code: $exit_code"
    
    # Remove temporary files if they exist
    if [[ -n "${TEMP_FILES:-}" ]]; then
        for temp_file in "${TEMP_FILES[@]}"; do
            if [[ -f "$temp_file" ]]; then
                rm -f "$temp_file"
                debug "Removed temporary file: $temp_file"
            fi
        done
    fi
    
    # Print summary
    if [[ $ERROR_COUNT -gt 0 ]]; then
        echo -e "${RED}Script completed with $ERROR_COUNT error(s)${NC}" >&2
    fi
    
    if [[ $WARNING_COUNT -gt 0 ]]; then
        echo -e "${YELLOW}Script completed with $WARNING_COUNT warning(s)${NC}" >&2
    fi
    
    if [[ $ERROR_COUNT -eq 0 && $WARNING_COUNT -eq 0 ]]; then
        success "Script completed successfully"
    fi
    
    exit $exit_code
}

# Function to handle script interruption
interrupt_handler() {
    echo -e "\n${YELLOW}Script interrupted by user${NC}" >&2
    cleanup
}

# Set up traps for error handling
trap cleanup EXIT
trap interrupt_handler INT TERM

# Function to log errors with timestamp
log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ERROR: $message" >> "${LOG_FILE:-/tmp/script_errors.log}" 2>/dev/null || true
}

# Function to validate script prerequisites
validate_prerequisites() {
    local script_name="$1"
    local required_commands=("${@:2}")
    
    info "Validating prerequisites for $script_name..."
    
    if ! validate_commands "${required_commands[@]}"; then
        error "Prerequisites validation failed for $script_name"
        return 1
    fi
    
    success "Prerequisites validation passed for $script_name"
    return 0
}

# Function to retry a command with exponential backoff
retry_command() {
    local max_attempts="${1:-3}"
    local delay="${2:-1}"
    local command="${3:-}"
    
    if [[ -z "$command" ]]; then
        error "No command provided to retry"
        return 1
    fi
    
    local attempt=1
    local current_delay="$delay"
    
    while [[ $attempt -le $max_attempts ]]; do
        debug "Attempt $attempt/$max_attempts: $command"
        
        if eval "$command"; then
            success "Command succeeded on attempt $attempt"
            return 0
        else
            if [[ $attempt -eq $max_attempts ]]; then
                error "Command failed after $max_attempts attempts: $command"
                return 1
            fi
            
            warning "Command failed on attempt $attempt, retrying in ${current_delay}s..."
            sleep "$current_delay"
            ((attempt++))
            current_delay=$((current_delay * 2))
        fi
    done
}
