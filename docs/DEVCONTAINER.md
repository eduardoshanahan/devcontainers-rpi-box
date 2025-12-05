# DevContainer Setup and Configuration

## Overview

The DevContainer provides a standardized development environment for Ansible playbook development. It includes all necessary tools pre-configured and ready to use.

## Prerequisites

- Docker installed and running
- VS Code with Remote-Containers extension OR Cursor editor
- Git installed
- SSH keys configured (for accessing Raspberry Pi devices)

## Initial Setup

### 1. Create Environment Configuration

Create `.devcontainer/config/.env` file with the following variables:

```bash
# User configuration
HOST_USERNAME=your_username
HOST_UID=1000
HOST_GID=1000

# Git configuration
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"

# Editor choice
EDITOR_CHOICE=cursor  # or 'code' for VS Code

# Docker configuration
DOCKER_IMAGE_NAME=devcontainers-rpi-box
DOCKER_IMAGE_TAG=latest

# Optional: Container resource limits
CONTAINER_MEMORY=4g
CONTAINER_CPUS=2
CONTAINER_SHM_SIZE=2g
CONTAINER_HOSTNAME=devcontainers-rpi-box

# Optional: Version overrides
PYTHON_VERSION=3.11
ANSIBLE_VERSION=9.2.0
ANSIBLE_LINT_VERSION=25.1.3

# Optional: Git remote URL
GIT_REMOTE_URL=https://github.com/yourusername/yourrepo.git
```

### 2. Launch the Container

Run the launch script:

```bash
./launch.sh
```

This script will:

- Validate environment variables
- Check for required editor installation
- Clean up existing containers
- Launch the editor with DevContainer support

## Container Configuration

### Dockerfile

The Dockerfile builds an Ubuntu 22.04 image with:

- System packages: curl, git, build-essential, openssh-client, jq, python3, python3-pip, sshpass
- Starship prompt
- Ansible and ansible-lint (specific versions)
- User account matching host user UID/GID
- Sudo access for the user

### devcontainer.json

Key configuration points:

- **Build arguments**: User credentials, Python/Ansible versions
- **VS Code extensions**: Ansible, YAML, Docker, Markdown linting
- **Mounts**: Workspace, .devcontainer config, SSH keys
- **Post-create command**: Runs setup scripts
- **Resource limits**: Configurable memory, CPU, shared memory

### Container Scripts

#### post-create.sh

Runs after container creation:

- Validates environment variables
- Configures Git user information
- Makes scripts executable
- Sets up bashrc with required sources

#### bash-prompt.sh

Configures shell environment:

- Initializes Starship prompt
- Sets up Git aliases (gs, ga, gc, gp, gl, gd, gco, gb, glog)
- Configures JSON processing aliases
- Sources SSH agent setup

#### ssh-agent-setup.sh

Manages SSH agent:

- Creates .ssh directory with proper permissions
- Starts SSH agent
- Adds private keys automatically
- Validates key permissions

#### validate-env.sh

Validates environment variables:

- Required: HOST_USERNAME, HOST_UID, HOST_GID
- Optional: CONTAINER_HOSTNAME, EDITOR_CHOICE, GIT_USER_NAME, etc.
- Uses regex patterns for validation
- Provides detailed error messages

## Container Features

### Starship Prompt

Custom Starship configuration provides:

- Username and hostname display
- Git branch and status
- Directory path
- Docker context (optional)
- Custom prompt characters

### Git Aliases

Pre-configured aliases:

- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git pull
- `gd` - git diff
- `gco` - git checkout
- `gb` - git branch
- `glog` - git log with graph

### JSON Tools

Aliases for JSON processing:

- `jsonlint` - Validate JSON
- `jsonformat` - Format JSON
- `jsonvalidate` - Validate JSON
- `jsonpretty` - Pretty print JSON

## Troubleshooting

### Container Won't Start

1. Check Docker is running: `docker ps`
2. Verify .env file exists and has correct values
3. Check editor is installed and in PATH
4. Review container logs: `docker logs <container-id>`

### SSH Keys Not Working

1. Verify SSH keys are in `~/.ssh` on host
2. Check key permissions: `chmod 600 ~/.ssh/id_rsa`
3. Verify SSH agent is running: `ssh-add -l`
4. Check container mounts in devcontainer.json

### Ansible Not Found

1. Verify Ansible version in .env matches installed version
2. Check Python version compatibility
3. Rebuild container: Remove and recreate

### Environment Variables Not Loading

1. Verify .env file location: `.devcontainer/config/.env`
2. Check file permissions
3. Validate variable names match expected format
4. Run validate-env.sh manually

## Customization

### Adding VS Code Extensions

Edit `.devcontainer/devcontainer.json`:

```json
"extensions": [
  "redhat.ansible",
  "your.extension-id"
]
```

### Modifying Container Resources

Update `.devcontainer/config/.env`:

```bash
CONTAINER_MEMORY=8g
CONTAINER_CPUS=4
CONTAINER_SHM_SIZE=4g
```

### Changing Ansible Version

Update `.devcontainer/config/.env`:

```bash
ANSIBLE_VERSION=9.3.0
ANSIBLE_LINT_VERSION=25.2.0
```

## Best Practices

1. Always validate environment variables before building
2. Keep .env file out of version control
3. Use specific version numbers for Ansible tools
4. Test container rebuild after configuration changes
5. Keep SSH keys secure and properly permissioned
