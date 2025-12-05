# Project Architecture

## Overview

This project provides a development container environment for creating and managing Ansible playbooks to configure and maintain Raspberry Pi devices. The project combines DevContainer technology with Ansible automation to create a streamlined development workflow.

## Project Structure

```text
devcontainers-rpi/
├── .devcontainer/          # DevContainer configuration
│   ├── config/             # Configuration files
│   │   ├── .env            # Environment variables (not in repo)
│   │   └── starship.toml   # Starship prompt configuration
│   ├── scripts/            # Container setup scripts
│   │   ├── bash-prompt.sh  # Shell prompt and aliases setup
│   │   ├── colors.sh       # Color definitions
│   │   ├── launch.sh       # Container launch script
│   │   ├── load-env.sh     # Environment variable loader
│   │   ├── post-create.sh  # Post-creation setup
│   │   ├── ssh-agent-setup.sh # SSH agent configuration
│   │   └── validate-env.sh # Environment validation
│   ├── Dockerfile          # Container image definition
│   └── devcontainer.json   # DevContainer configuration
├── src/                    # Ansible source code
│   ├── inventory/          # Ansible inventory
│   │   ├── hosts.yml       # Host definitions (not in repo)
│   │   ├── hosts.example.yml # Example host configuration
│   │   └── group_vars/     # Group variables
│   │       ├── all/        # Variables for all hosts
│   │       │   └── local-secrets.yml # Secrets (not in repo)
│   │       └── rpi.yml     # Raspberry Pi specific variables
│   ├── roles/              # Ansible roles
│   │   ├── common/         # Common system setup
│   │   ├── common_tools/   # Administration tools
│   │   ├── daily_report/   # Daily system reports
│   │   ├── docker/         # Docker installation
│   │   ├── system_update/  # System updates
│   │   └── unattended_upgrades/ # Automatic updates
│   ├── ansible.cfg         # Ansible configuration
│   ├── site.yml            # Main playbook
│   └── test-ansible.sh     # Ansible installation test
├── scripts/                # Project scripts
│   ├── error-handling.sh   # Error handling utilities
│   └── sync_git.sh         # Git synchronization script
├── launch.sh               # Project launcher
└── docs/                   # Documentation (this directory)
```

## Components

### DevContainer

The DevContainer provides a consistent development environment with:

- Ubuntu 22.04 base image
- Ansible and ansible-lint pre-installed
- Git configuration
- SSH agent setup
- Custom shell prompt (Starship)
- VS Code/Cursor extensions

### Ansible Roles

The project includes six Ansible roles for managing Raspberry Pi systems:

1. **common** - Basic system setup and baseline packages
2. **common_tools** - Administration and monitoring tools
3. **daily_report** - Automated daily system status reports via email
4. **docker** - Docker engine installation and configuration
5. **system_update** - Manual system updates with reboot handling
6. **unattended_upgrades** - Automatic security updates

### Scripts

Shell scripts handle:

- Container initialization and setup
- Environment validation
- Git synchronization
- SSH agent management
- Error handling

## Workflow

1. Developer launches the DevContainer using `launch.sh`
2. Container builds with required tools (Ansible, Git, etc.)
3. Developer edits Ansible playbooks and roles
4. Developer tests playbooks against Raspberry Pi devices
5. Changes are committed and synchronized via Git

## Technology Stack

- **Container**: Docker with Ubuntu 22.04
- **Automation**: Ansible 9.2.0
- **Linting**: ansible-lint 25.1.3
- **Shell**: Bash with Starship prompt
- **Version Control**: Git
- **Editor**: VS Code or Cursor
