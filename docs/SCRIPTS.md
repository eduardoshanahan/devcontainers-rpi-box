# Scripts Documentation

## Overview

This project includes several shell scripts that handle container setup, Git synchronization, and error handling.

## Project Scripts

### launch.sh

**Location**: `/launch.sh`

**Purpose**: Launches the development container with the configured editor

**Features**:

- Validates environment variables from `.devcontainer/config/.env`
- Checks for required editor installation (VS Code or Cursor)
- Cleans up existing containers using the same image
- Launches the editor with DevContainer support

**Usage**:

```bash
./launch.sh
```

**Required Environment Variables**:

- `HOST_USERNAME` - System username
- `HOST_UID` - User ID
- `HOST_GID` - Group ID
- `GIT_USER_NAME` - Git user name
- `GIT_USER_EMAIL` - Git user email
- `EDITOR_CHOICE` - Either "code" or "cursor"
- `DOCKER_IMAGE_NAME` - Docker image name
- `DOCKER_IMAGE_TAG` - Docker image tag

**Error Handling**:

- Exits with error if .env file is missing
- Validates all required variables are set
- Checks editor is installed before launching
- Provides colored output for errors, warnings, and success

---

### sync_git.sh

**Location**: `/scripts/sync_git.sh`

**Purpose**: Synchronizes local Git repository with remote

**Features**:

- Initializes Git repository if it doesn't exist
- Configures Git user from environment variables
- Syncs with remote repository
- Handles local changes (backup or error)
- Supports force pull to overwrite local changes

**Usage**:

```bash
# Normal sync (fails if local changes exist)
./scripts/sync_git.sh

# Force pull (overwrites local changes)
FORCE_PULL=true ./scripts/sync_git.sh

# Sync specific branch
BRANCH=develop ./scripts/sync_git.sh
```

**Environment Variables**:

- `GIT_REMOTE_URL` - Remote repository URL (required for new repos)
- `GIT_USER_NAME` - Git user name
- `GIT_USER_EMAIL` - Git user email
- `BRANCH` - Branch to sync (default: main)
- `FORCE_PULL` - Force pull and overwrite local changes (default: false)

**Behavior**:

1. **New Repository**:
   - Initializes Git if .git doesn't exist
   - Configures Git user
   - Adds remote from `GIT_REMOTE_URL`
   - Fetches and checks out branch
   - Creates initial commit if files exist

2. **Existing Repository**:
   - Validates remote URL exists
   - Configures Git user
   - Checks for local changes
   - Pulls from remote (or errors if local changes exist)
   - Handles detached HEAD state

3. **Force Pull Mode**:
   - Creates backup of local changes
   - Resets to remote branch
   - Cleans untracked files

**Backup**:
When using `FORCE_PULL=true`, local changes are backed up to:

```text
backup_YYYYMMDD_HHMMSS/
├── local_changes.patch
└── [untracked files]
```

**Error Handling**:

- Exits if remote URL is not configured
- Errors if local changes exist (unless FORCE_PULL=true)
- Validates Git user configuration
- Provides colored output

---

### error-handling.sh

**Location**: `/scripts/error-handling.sh`

**Purpose**: Provides error handling utilities and functions

**Note**: This file appears to be filtered by .cursorignore. Refer to the source code for implementation details.

---

## DevContainer Scripts

### post-create.sh

**Location**: `.devcontainer/scripts/post-create.sh`

**Purpose**: Runs after container creation to set up the environment

**Tasks**:

- Sources environment variables from `.devcontainer/config/.env`
- Validates environment variables
- Configures Git user information
- Makes scripts executable
- Sets up bashrc to source required scripts

**Execution**: Automatically runs via `postCreateCommand` in devcontainer.json

---

### bash-prompt.sh

**Location**: `.devcontainer/scripts/bash-prompt.sh`

**Purpose**: Configures shell environment and prompt

**Features**:

- Initializes Starship prompt if available
- Sources environment variables
- Sources SSH agent setup
- Sources color definitions
- Sets up Git aliases
- Configures JSON processing aliases
- Sets bash as default shell

**Git Aliases**:

- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gd` - git diff
- `gco` - git checkout
- `gb` - git branch
- `glog` - git log --oneline --graph --decorate

**JSON Aliases**:

- `jsonlint` - Validate JSON (jq ".")
- `jsonformat` - Format JSON (jq ".")
- `jsonvalidate` - Validate JSON (jq empty)
- `jsonpretty` - Pretty print JSON (jq ".")

**Execution**: Automatically sourced in bashrc for interactive shells

---

### ssh-agent-setup.sh

**Location**: `.devcontainer/scripts/ssh-agent-setup.sh`

**Purpose**: Manages SSH agent and key loading

**Features**:

- Creates .ssh directory with proper permissions (700)
- Starts new SSH agent
- Saves agent environment variables to `~/.ssh/agent_env`
- Automatically adds all private keys from `~/.ssh/`
- Validates key permissions (must be 600)
- Shows currently loaded keys

**Security**:

- Validates file permissions before adding keys
- Uses umask 077 for agent_env file
- Skips public keys, known_hosts, and agent_env files
- Only runs in interactive shells

**Usage**: Automatically sourced in bashrc

**Manual Execution**:

```bash
source ~/.devcontainer/scripts/ssh-agent-setup.sh
```

---

### validate-env.sh

**Location**: `.devcontainer/scripts/validate-env.sh`

**Purpose**: Validates environment variables

**Required Variables**:

- `HOST_USERNAME` - Must match pattern: `^[a-z_][a-z0-9_-]*[$]?$`
- `HOST_UID` - Must be numeric
- `HOST_GID` - Must be numeric

**Optional Variables** (with defaults and validation):

- `CONTAINER_HOSTNAME` - Default: "dev", pattern: `^[a-zA-Z][a-zA-Z0-9-]*$`
- `EDITOR_CHOICE` - Default: "cursor", must be "code" or "cursor"
- `GIT_USER_NAME` - Default: "Dev User", pattern: `^[a-zA-Z0-9 ._-]+$`
- `GIT_USER_EMAIL` - Default: "<dev@example.com>", must be valid email
- `DOCKER_IMAGE_NAME` - Default: "dev-container", pattern: `^[a-z0-9][a-z0-9._-]+$`
- `DOCKER_IMAGE_TAG` - Default: "latest", pattern: `^[a-zA-Z0-9][a-zA-Z0-9._-]+$`

**Validation**:

- Uses regex patterns for validation
- Provides detailed error messages with descriptions
- Returns non-zero exit code on failure
- Shows current value and expected pattern on error

**Usage**:

```bash
source .devcontainer/scripts/validate-env.sh
```

---

### load-env.sh

**Location**: `.devcontainer/scripts/load-env.sh`

**Purpose**: Loads environment variables from .env file

**Features**:

- Loads variables from `.devcontainer/config/.env`
- Sets defaults for container resource limits
- Sets defaults for version numbers
- Exports all variables

**Default Values**:

- `CONTAINER_MEMORY=4g`
- `CONTAINER_CPUS=2`
- `CONTAINER_SHM_SIZE=2g`
- `CONTAINER_HOSTNAME=devcontainers-ansible`
- `PYTHON_VERSION=3.11`
- `ANSIBLE_VERSION=9.2.0`
- `ANSIBLE_LINT_VERSION=25.1.3`

**Usage**:

```bash
source .devcontainer/scripts/load-env.sh
```

---

### launch.sh script

**Location**: `.devcontainer/scripts/launch.sh`

**Purpose**: Container launch script with colored output

**Features**:

- Sources color definitions
- Sources and validates environment variables
- Configures Git user information
- Makes scripts executable
- Sets up bashrc

**Note**: This is a container-internal script, different from the project root `launch.sh`

---

### colors.sh

**Location**: `.devcontainer/scripts/colors.sh`

**Purpose**: Defines color variables for terminal output

**Colors Defined**:

- Basic: RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE
- Bold: BOLD_RED, BOLD_GREEN, BOLD_YELLOW, BOLD_BLUE, BOLD_MAGENTA, BOLD_CYAN, BOLD_WHITE
- Utility: COLOR_RESET, COLOR_BOLD, COLOR_DIM

**Usage**: Sourced by other scripts for consistent colored output

---

## Test Scripts

### test-ansible.sh

**Location**: `src/test-ansible.sh`

**Purpose**: Tests Ansible installation and configuration

**Tests**:

1. Checks Ansible version
2. Checks ansible-lint version
3. Creates and runs a test playbook
4. Runs ansible-lint on the test playbook

**Usage**:

```bash
cd src
./test-ansible.sh
```

**Cleanup**: Automatically removes test playbook on exit

---

## Script Best Practices

1. **Error Handling**: All scripts use `set -euo pipefail` for strict error handling
2. **Colors**: Use color functions for consistent output
3. **Validation**: Validate inputs and environment variables
4. **Permissions**: Ensure scripts are executable
5. **Documentation**: Include usage and purpose comments
6. **Security**: Validate file permissions for sensitive operations
7. **Idempotency**: Scripts should be safe to run multiple times

## Troubleshooting

### Script Not Executable

```bash
chmod +x script-name.sh
```

### Environment Variables Not Loading

1. Check .env file exists and is readable
2. Verify variable names match expected format
3. Run validate-env.sh to check for errors

### SSH Agent Not Working

1. Check ssh-agent-setup.sh is sourced in bashrc
2. Verify SSH keys have correct permissions (600)
3. Check .ssh directory permissions (700)
4. Manually run: `source ~/.devcontainer/scripts/ssh-agent-setup.sh`

### Git Sync Failing

1. Verify GIT_REMOTE_URL is set
2. Check Git user is configured
3. Ensure you have network access
4. Check for local changes that need committing
