#!/bin/bash

# Set strict bash options
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging helpers (renamed to avoid conflicts with /usr/bin/info)
log_error() {
  echo -e "${RED}ERROR: $1${NC}" >&2
}

log_success() {
  echo -e "${GREEN}$1${NC}"
}

log_info() {
  echo -e "${YELLOW}$1${NC}"
}

# Function to check if a variable is set
check_var() {
  local var_name="$1"
  local var_value="$2"
  if [ -z "${var_value:-}" ]; then
    log_error "$var_name is not set (in .devcontainer/config/.env or .env)"
    return 1
  fi
  log_info "$var_name: $var_value"
}

ENV_FILE=".devcontainer/config/.env"

# Check if .devcontainer/config/.env file exists
if [ ! -f "$ENV_FILE" ]; then
  log_error "$ENV_FILE file not found!"
  log_error "Please create it with the following variables:"
  cat <<EOF
# User configuration
HOST_USERNAME=your_username
HOST_UID=your_uid
HOST_GID=your_gid

# Git configuration
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"

# Editor configuration
# EDITOR_CHOICE can be set here OR in the project root .env
# EDITOR_CHOICE=code  # Use 'code' for VS Code or 'cursor' for Cursor

# Docker configuration
DOCKER_IMAGE_NAME=your-image-name
DOCKER_IMAGE_TAG=your-tag
EOF
  exit 1
fi

# 1) Load base environment variables from .devcontainer/config/.env
log_info "Loading environment variables from $ENV_FILE..."
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

# 2) Optionally override (e.g. EDITOR_CHOICE) from root .env
if [ -f .env ]; then
  log_info "Loading overrides from .env (if set)..."
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

# Export variables explicitly for devcontainer / scripts
export HOST_USERNAME
export HOST_UID
export HOST_GID
export GIT_USER_NAME
export GIT_USER_EMAIL
export EDITOR_CHOICE
export DOCKER_IMAGE_NAME
export DOCKER_IMAGE_TAG

# Verify required variables
required_vars=(
  "HOST_USERNAME"
  "HOST_UID"
  "HOST_GID"
  "GIT_USER_NAME"
  "GIT_USER_EMAIL"
  "EDITOR_CHOICE"
  "DOCKER_IMAGE_NAME"
  "DOCKER_IMAGE_TAG"
)

log_info "Validating required environment variables..."
for var in "${required_vars[@]}"; do
  check_var "$var" "${!var:-}" || exit 1
done

log_info "EDITOR_CHOICE resolved to: ${EDITOR_CHOICE}"

# Validate editor choice
if [ "${EDITOR_CHOICE}" != "code" ] && [ "${EDITOR_CHOICE}" != "cursor" ]; then
  log_error "EDITOR_CHOICE must be set to either 'code' or 'cursor' (current: '${EDITOR_CHOICE}')"
  exit 1
fi

# Check if the chosen editor is installed
if ! command -v "${EDITOR_CHOICE}" &>/dev/null; then
  log_error "${EDITOR_CHOICE} is not installed!"
  if [ "${EDITOR_CHOICE}" = "code" ]; then
    log_error "Please install VS Code from https://code.visualstudio.com/"
  else
    log_error "Please install Cursor from https://cursor.sh"
  fi
  exit 1
fi

# Clean up any existing containers using our image
if docker ps -a | grep -q "${DOCKER_IMAGE_NAME}" >/dev/null 2>&1; then
  log_info "Cleaning up existing containers..."
  docker ps -a | grep "${DOCKER_IMAGE_NAME}" | awk '{print $1}' | xargs -r docker stop
  docker ps -a | grep "${DOCKER_IMAGE_NAME}" | awk '{print $1}' | xargs -r docker rm
fi

# Launch the editor
log_info "Launching ${EDITOR_CHOICE}..."
if [ "${EDITOR_CHOICE}" = "code" ]; then
  code "${PWD}" >/dev/null 2>&1 &
else
  cursor "${PWD}" --no-sandbox >/dev/null 2>&1 &
fi

log_success "${EDITOR_CHOICE} launched successfully!"
disown || true
