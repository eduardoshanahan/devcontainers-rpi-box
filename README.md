# Development Container Template - Raspberry Pi

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue)](https://www.docker.com/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Required-blue)](https://code.visualstudio.com/)

## Why do I have this project?

This is a next step from [Development Container Template - Just Git](https://github.com/eduardoshanahan/devcontainers-git)

Based in similar lines as devcontainers-git, I want to have an environment already primed to work with Ansible.

The premises are again that I need to be able to synchronize the files in different machines using Synology Drive without permission issues.

I also want to be able to use the SSH keys stored in my workstation without copying them into Docker. The keys must stay also away from git.

I am currently using Ubuntu 25.04. I would expect this to work in other versions too, but I have not tested that.

### Development Tools

The development container comes with several pre-installed tools and features:

1. **Ansible Development Environment**
   - Ansible core (version 9.2.0)
   - Ansible-lint (version 25.1.3) for playbook validation
   - Python 3.11 with pip for package management
   - Pre-configured Ansible environment variables
   - Built-in testing capabilities with `test-playbook.yml`

2. **Docker Integration**
   - Microsoft Docker extension (`ms-azuretools.vscode-docker`)
   - Full Docker CLI support
   - Container management and debugging capabilities
   - Integrated Docker Desktop support

3. **Shell Experience**
   - Starship prompt
   - Custom-configured prompt with Git status
   - Configurable via `starship.toml` in the config directory

4. **JSON Tools**
   - `jq` command-line JSON processor
   - VS Code extensions for JSON:
     - Prettier (`esbenp.prettier-vscode`) for formatting
     - ESLint (`dbaeumer.vscode-eslint`) for linting
   - Helpful aliases:
     - `jsonlint`: Format and validate JSON
     - `jsonformat`: Pretty print JSON
     - `jsonvalidate`: Check JSON syntax
     - `jsonpretty`: Format JSON with nice output

5. **Additional VS Code Extensions**
   - Markdown linting (`DavidAnson.vscode-markdownlint`)
   - Remote Containers support (`ms-vscode-remote.remote-containers`)
   - YAML support for Ansible playbooks
   - Syntax highlighting for Ansible files

### Ansible Tools

The container includes a complete Ansible development environment:

#### Core Ansible

- **Ansible**: Latest stable version (9.2.0) for automation
- **Ansible-lint**: Playbook validation and best practices enforcement
- **Python 3.11**: Required runtime with all necessary dependencies

#### Development Features

- **Playbook Testing**: Built-in `test-playbook.yml` for validation
- **Linting Support**: Automatic playbook validation with ansible-lint
- **YAML Support**: Full YAML syntax highlighting and validation
- **Inventory Management**: Support for various inventory formats

#### Testing and Validation

```bash
# Test Ansible installation
ansible --version

# Validate playbook syntax
ansible-playbook --syntax-check test-playbook.yml

# Run ansible-lint on playbooks
ansible-lint test-playbook.yml

# Test playbook execution
ansible-playbook test-playbook.yml
```

## Table of Contents

- [Quick Start](#quick-start)
- [Setting Up a New GitHub Project](#setting-up-a-new-github-project)
- [Usage](#usage)
  - [Requirements](#requirements)
  - [Basic Usage](#basic-usage)

- [Development Container Setup](#development-container-setup)
- [Customization](#customization)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
- [Security Notes](#security-notes)
- [Contributing](#contributing)
- [License](#license)
- [SSH Agent Setup](#ssh-agent-setup)
- [Environment Variable Details](#environment-variable-details)
- [GitHub SSH Setup](#github-ssh-setup)
- [Git Synchronization](#git-synchronization)

## Quick Start

1. Clone this repository
2. Copy `.devcontainer/config/.env.example` to `.devcontainer/config/.env`
3. Update the environment variables in `.env` with your settings
4. From your local machine, launch the editor with `./launch.sh`
5. When prompted, click "Reopen in Container"

## Setting Up a New GitHub Project

1. **Create a New Repository**

   ```bash
   # Clone this template
   git clone https://github.com/eduardoshanahan/devcontainers-ansible your-new-project
   cd your-new-project

   # Remove the existing git history
   rm -rf .git

   # Initialize a new git repository
   git init

   # Create a new repository on GitHub (without README, .gitignore, or license)
   # Then add your new remote
   git remote add origin git@github.com:yourusername/your-new-project.git
   ```

2. **Update Project Information**

   ```bash
   # Update the README.md with your project details
   # Update the LICENSE file if needed
   # Update any other project-specific files
   ```

3. **Configure Environment**

   - Copy and configure the environment file

   ```bash
   cp .devcontainer/config/.env.example .devcontainer/config/.env
   ```

   - Edit .env with your project-specific settings. In particular update

   ```text
   CONTAINER_HOSTNAME=devcontainers-ansible

   DOCKER_IMAGE_NAME=devcontainers-ansible
   ```

   - Edit devcontainer.json. In particular update

   ```text
    "name": "Ubuntu Devcontainers Ansible",

   "DOCKER_IMAGE_NAME": "${localEnv:DOCKER_IMAGE_NAME:-devcontainers-ansible}",

    {localEnv:CONTAINER_HOSTNAME:-devcontainers-ansible}",

   "--hostname=${localEnv:CONTAINER_HOSTNAME:devcontainers-ansible}",
   ```

4. **Initial Commit**

   ```bash
   # Add all files
   git add .

   # Create initial commit
   git commit -m "Initial commit: Project setup with devcontainer template"

   # Push to GitHub
   git push -u origin main
   ```

5. **Verify Setup**
   - Start VS Code with `./launch.sh`
   - Click "Reopen in Container"
   - Verify that the container builds successfully
   - Check that your Git configuration is working:

     ```bash
     git config --list
     ```

## Usage

### Requirements

1. **Docker**
   - Installed and running
   - Proper permissions to run containers
   - Sufficient system resources allocated

2. **VS Code / Cursor**
   - Latest version installed
   - Remote - Containers extension installed
   - Git extension installed (recommended)

3. **Operating System**
   - Linux: I use it with Ubuntu, I would expect it to work with other distributions

### Basic Usage

1. **Initial Setup**

   ```bash
   cd <repository-name>
   ./launch.sh
   ```

2. **Starting the Container**
   - Click "Reopen in Container" when prompted
   - Wait for the container to build and start

3. **Working in the Container**
   - All development tools are pre-installed
   - Git is configured with your credentials
   - SSH agent forwarding is enabled
   - Your local files are mounted in the container

4. **Customizing the Environment**
   - Edit `.devcontainer/config/.env` to change settings
   - Modify `.devcontainer/Dockerfile` to add new tools
   - Update `.devcontainer/devcontainer.json` for VS Code settings

### Advanced Usage

#### SSH Agent Forwarding

The container automatically forwards your SSH agent:

```bash
# Test SSH connection
ssh -T git@github.com
```

#### Environment Variables

Key environment variables:

- `HOST_USERNAME`: Your host machine username
- `HOST_UID`: Your host user ID
- `HOST_GID`: Your host group ID
- `CONTAINER_HOSTNAME`: Container hostname (default: dev)
- `EDITOR_CHOICE`: Preferred editor (code/cursor)
- `GIT_USER_NAME`: Git commit author name
- `GIT_USER_EMAIL`: Git commit author email

## Environment Variable Details

The development container uses environment variables for configuration. These are defined in the `.env` file in `.devcontainer/config/`, which should be created by copying `.env.example`.

### Required Variables

| Variable | Description | Format | How to Get | Example |
|----------|-------------|--------|------------|---------|
| HOST_USERNAME | Your system username | Letters, numbers, underscore, hyphen | `echo $USER` | `eduardo` |
| HOST_UID | Your user ID | Positive integer | `id -u` | `1000` |
| HOST_GID | Your group ID | Positive integer | `id -g` | `1000` |
| GIT_USER_NAME | Git commit author name | Letters, numbers, spaces, dots | Your full name | `Eduardo Shanahan` |
| GIT_USER_EMAIL | Git commit author email | Valid email address | Your email | `eduardo@example.com` |

### Optional Variables

#### Container Configuration

| Variable | Description | Default | Format | Example |
|----------|-------------|---------|--------|---------|
| CONTAINER_HOSTNAME | Container hostname shown in prompt | dev | Letters, numbers, hyphens | `ansible-dev` |
| CONTAINER_USER | Container user name | Same as HOST_USERNAME | Letters, numbers, underscore | `vscode` |
| WORKSPACE_PATH | Workspace directory path | `/workspace` | Absolute path | `/workspace` |

#### Editor Configuration

| Variable | Description | Default | Format | Example |
|----------|-------------|---------|--------|---------|
| EDITOR_CHOICE | Preferred editor | cursor | 'code' or 'cursor' | `cursor` |

#### Git Configuration

| Variable | Description | Default | Format | Example |
|----------|-------------|---------|--------|---------|
| GIT_REMOTE_URL | Remote repository URL | None | Git URL | `git@github.com:username/repo.git` |
| GIT_DEFAULT_BRANCH | Default branch name | main | Branch name | `main` |

#### Docker Configuration

| Variable | Description | Default | Format | Example |
|----------|-------------|---------|--------|---------|
| DOCKER_IMAGE_NAME | Development container image name | dev-container | Lowercase letters, numbers, symbols | `ansible-dev` |
| DOCKER_IMAGE_TAG | Development container image tag | latest | Letters, numbers, symbols | `v1.0.0` |

#### SSH Configuration

| Variable | Description | Default | Format | Example |
|----------|-------------|---------|--------|---------|
| SSH_AUTH_SOCK | SSH agent socket path | Auto-detected | Socket path | `/tmp/ssh-XXXXXX/agent.XXXX` |
| SSH_AGENT_PID | SSH agent process ID | Auto-detected | Process ID | `12345` |

#### Development Tools Configuration

| Variable | Description | Default | Format | Example |
|----------|-------------|---------|--------|---------|
| PYTHON_VERSION | Python version to install | 3.11 | Version string | `3.11` |
| ANSIBLE_VERSION | Ansible version to install | 9.2.0 | Version string | `9.2.0` |
| ANSIBLE_LINT_VERSION | Ansible-lint version | 25.1.3 | Version string | `25.1.3` |

#### Performance and Resources

| Variable | Description | Default | Format | Example |
|----------|-------------|---------|--------|---------|
| CONTAINER_MEMORY | Container memory limit | 4g | Memory string | `4g` |
| CONTAINER_CPUS | Container CPU limit | 2 | Number | `2` |
| CONTAINER_SHM_SIZE | Shared memory size | 2g | Memory string | `2g` |

### Environment Validation

The development container includes automatic environment variable validation:

1. Copy `.env.example` to `.env` in `.devcontainer/config/` and update the values
2. The `validate-env.sh` script checks all variables during container creation
3. Required variables must be set with valid values
4. Optional variables will use defaults if not set
5. Validation errors will prevent container creation

### Variable Categories and Usage

#### Container Identity Variables

- `HOST_USERNAME`, `HOST_UID`, `HOST_GID`: Ensure proper file ownership and permissions
- `CONTAINER_HOSTNAME`: Customizes the terminal prompt
- `CONTAINER_USER`: Sets the user inside the container

#### Git Configuration Variables

- `GIT_USER_NAME`, `GIT_USER_EMAIL`: Used for commit authorship
- `GIT_REMOTE_URL`: Required for the `sync_git.sh` script (see [Git Synchronization](#git-synchronization))
- `GIT_DEFAULT_BRANCH`: Sets the default branch for new repositories

#### SSH and Security Variables

- `SSH_AUTH_SOCK`, `SSH_AGENT_PID`: Automatically managed by SSH agent forwarding
- These variables enable secure Git operations without copying SSH keys

#### Development Environment Variables

- `PYTHON_VERSION`, `ANSIBLE_VERSION`: Control tool versions for consistency
- `EDITOR_CHOICE`: Determines which editor to use for commit messages

#### Performance Variables

- `CONTAINER_MEMORY`, `CONTAINER_CPUS`: Control resource allocation
- `CONTAINER_SHM_SIZE`: Affects shared memory for certain operations

### Cross-References

- **SSH Setup**: See [SSH Agent Setup](#ssh-agent-setup) for SSH-related variables
- **Git Configuration**: See [Git Synchronization](#git-synchronization) for Git-related variables
- **Performance**: See [Performance Optimization](#performance-optimization) for resource variables

## Development Container Setup

This project is designed to be cloned and used as a starting point for setting up a development container environment. It provides:

1. A standardized container configuration
2. Automated environment setup
3. Built-in security features
4. VS Code and Cursor integration
5. Starship terminal
6. JSON processing tools and linters
7. Git available
8. Ansible available

## Customization

### Adding New Tools

To add new development tools, modify the Dockerfile:

```dockerfile
RUN apt-get update && apt-get install -y \
    your-package-name \
    another-package \
    && rm -rf /var/lib/apt/lists/*
```

### Modifying the Prompt

The prompt configuration is in `.devcontainer/scripts/bash-prompt.sh`. You can modify it to:

- Change colors
- Add/remove information
- Modify the layout

### Adding VS Code Extensions

Add extensions in the `devcontainer.json` file:

```json
"customizations": {
    "vscode": {
        "extensions": [
            "ms-azuretools.vscode-docker",
            "your.extension-id"
        ]
    }
}
```

## Project Structure

```text
/
├── .devcontainer/              # Development container configuration
│   ├── config/                # Configuration files
│   │   ├── .env              # Environment variables
│   │   ├── .env.example      # Example environment variables
│   │   └── starship.toml     # Starship prompt configuration
│   ├── scripts/              # Shell scripts
│   │   ├── README.md         # Scripts documentation
│   │   ├── bash-prompt.sh    # Shell prompt configuration
│   │   ├── colors.sh         # Color definitions
│   │   ├── launch.sh         # Container launch script
│   │   ├── post-create.sh    # Post-creation setup script
│   │   ├── ssh-agent-setup.sh # SSH agent configuration
│   │   └── validate-env.sh   # Environment validation script
│   ├── Dockerfile            # Container image definition
│   ├── devcontainer.json     # VS Code/Cursor container configuration
│   ├── .onCreateCommandMarker # Container creation marker
│   ├── .postCreateCommandMarker # Post-creation marker
│   └── .updateContentCommandMarker # Content update marker
├── .cursor/                   # Cursor-specific configuration
│   ├── rules/                # Cursor AI rules
│   │   ├── no-emojis-in-markdown.md
│   │   ├── rule-template.md
│   │   └── rules-storage.md
│   └── settings.json         # Cursor settings
├── scripts/                   # Utility scripts
│   └── sync_git.sh           # Git synchronization script
├── src/                       # Source code
│   └── test-ansible.sh       # Ansible testing script
├── .cursorignore              # Cursor ignore patterns
├── .dockerignore              # Docker ignore patterns
├── .gitignore                 # Git ignore patterns
├── .git/                      # Git repository data
├── launch.sh                  # Container launch script
├── test-playbook.yml          # Test Ansible playbook
├── README.md                  # This file
└── LICENSE                    # Project license
```

### Key Directories Explained

#### `.devcontainer/`

Contains all development container configuration:

- **`config/`**: Environment variables and Starship prompt configuration
- **`scripts/`**: Setup, initialization, and utility scripts
- **`Dockerfile`**: Container image definition
- **`devcontainer.json`**: VS Code/Cursor container configuration
- **Marker files**: Track container lifecycle events

#### `.cursor/`

Cursor-specific configurations:

- **`rules/`**: AI rules for code generation and formatting
- **`settings.json`**: Cursor editor settings

#### `scripts/`

Utility scripts for project management:

- **`sync_git.sh`**: Git repository synchronization

#### `src/`

Source code and testing:

- **`test-ansible.sh`**: Ansible testing script

### Configuration Files

#### Environment and Container

- **`.devcontainer/config/.env`**: Environment variables (create from `.env.example`)
- **`.devcontainer/config/.env.example`**: Example environment variables
- **`.devcontainer/config/starship.toml`**: Starship prompt configuration

#### Scripts and Automation

- **`launch.sh`**: Main entry point for starting the development environment
- **`.devcontainer/scripts/`**: Container setup and management scripts
- **`scripts/sync_git.sh`**: Git repository synchronization utility

#### Testing and Development

- **`test-playbook.yml`**: Basic Ansible playbook for testing
- **`src/test-ansible.sh`**: Ansible testing script

#### Cursor Editor Configuration

- **`.cursor/settings.json`**: Cursor editor settings
- **`.cursor/rules/`**: AI rules for code generation and formatting

#### Ignore Files

- **`.gitignore`**: Git ignore patterns
- **`.dockerignore`**: Docker ignore patterns
- **`.cursorignore`**: Cursor ignore patterns

### Container Lifecycle Markers

The `.devcontainer/` directory contains marker files that track container lifecycle events:

- **`.onCreateCommandMarker`**: Indicates container creation completed
- **`.postCreateCommandMarker`**: Indicates post-creation setup completed
- **`.updateContentCommandMarker`**: Indicates content updates completed

### File Purposes

- **`launch.sh`**: Main entry point for starting the development environment
- **`test-playbook.yml`**: Basic Ansible playbook for testing the setup
- **`src/test-ansible.sh`**: Script for testing Ansible functionality
- **`scripts/sync_git.sh`**: Utility for Git repository synchronization
- **`.devcontainer/scripts/`**: Various container setup and management scripts

## GitHub SSH Setup

The development container is configured to use SSH for GitHub operations. This provides several benefits:

- Secure authentication using SSH keys
- No need to enter credentials repeatedly
- Better integration with the container environment

### Verifying SSH Setup

1. Check if SSH keys are loaded:

   ```bash
   ssh-add -l
   ```

2. Test GitHub SSH connection:

   ```bash
   ssh -T git@github.com
   ```

   You should see: "Hi username! You've successfully authenticated..."

3. Verify Git remote URL:

   ```bash
   git remote -v
   ```

   Should show: `git@github.com:username/repository.git`

### Switching to SSH

If your repository is using HTTPS, switch to SSH:

```bash
git remote set-url origin git@github.com:username/repository.git
```

### Troubleshooting SSH

1. **Keys Not Loading**
   - Check SSH agent: `echo $SSH_AUTH_SOCK`
   - Verify key permissions: `ls -l ~/.ssh/`
   - Restart SSH agent: `eval "$(ssh-agent -s)"`

2. **GitHub Connection Issues**
   - Verify key is added to GitHub account
   - Check SSH connection: `ssh -vT git@github.com`
   - Ensure correct remote URL format

3. **Permission Issues**
   - SSH directory: `chmod 700 ~/.ssh`
   - Private keys: `chmod 600 ~/.ssh/id_*`
   - Public keys: `chmod 644 ~/.ssh/*.pub`

## Troubleshooting

### Common Issues

1. **Container Build Failures**
   - **Symptom**: Container fails to build with permission errors
   - **Solution**: Ensure your user has proper Docker permissions

   ```bash
   sudo usermod -aG docker $USER
   # Log out and back in for changes to take effect
   ```

2. **VS Code Connection Issues**
   - **Symptom**: VS Code cannot connect to the container
   - **Solution**:

     - Check Docker is running
     - Verify VS Code Remote - Containers extension is installed
     - Try rebuilding the container

3. **Git Authentication Problems**
   - **Symptom**: Git operations fail with authentication errors
   - **Solution**:

     - Verify SSH agent forwarding is working
     - Check your Git credentials are properly configured
     - Ensure your SSH key is added to the agent

4. **Performance Issues**
   - **Symptom**: Container is slow or unresponsive
   - **Solution**:

     - Check system resources (CPU, RAM, disk space)
     - Verify Docker resource limits
     - Consider using volume mounts instead of bind mounts

### Performance Optimization

1. **Docker Resource Management**

   Update .devcontainer/devcontainer.json:

   ```json
   {
     "runArgs": [
       "--memory=4g",
       "--cpus=2",
       "--shm-size=2g"
     ]
   }
   ```

2. **Volume Optimization**
   - Use named volumes for frequently accessed data
   - Exclude unnecessary files from mounting
   - Use `.dockerignore` to reduce build context

3. **Build Optimization**
   - Layer caching
   - Multi-stage builds
   - Minimal base images

4. **VS Code Performance**
   - Disable unnecessary extensions
   - Use workspace-specific settings
   - Configure file watching limits

### Getting Help

If you encounter issues:

1. Check the [GitHub Issues](https://github.com/eduardoshanahan/devcontainers-git/issues)
2. Review the [VS Code Remote Containers documentation](https://code.visualstudio.com/docs/remote/containers)
3. Consult the [Docker documentation](https://docs.docker.com/)
4. Create a new issue with:
   - Detailed error message
   - Steps to reproduce
   - System information
   - Relevant logs

## Backup and Data Persistence

### Container Data

1. **Volume Management**
   - Use named volumes for persistent data
   - Configure volume backups
   - Implement data retention policies

2. **Backup Strategies**

   ```bash
   # Backup a named volume
   docker run --rm -v your-volume:/source -v /backup:/backup alpine tar czf /backup/backup.tar.gz -C /source .
   
   # Restore from backup
   docker run --rm -v your-volume:/target -v /backup:/backup alpine sh -c "cd /target && tar xzf /backup/backup.tar.gz"
   ```

3. **Data Recovery**
   - Regular volume backups
   - Point-in-time recovery options
   - Disaster recovery procedures

### Configuration Backup

1. **Environment Variables**
   - Keep `.env` files outside of version control. This is to not leak details if you are keeping the project in a publig Git repository. If you are not using Synology, setup some other type of backup for private details.
   - Use environment-specific configurations
   - Document all configuration changes

2. **VS Code Settings**
   - Sync settings across devices
   - Backup workspace configurations
   - Maintain extension lists

3. **Git Configuration**
   - Backup SSH keys securely
   - Document Git credentials
   - Maintain access tokens

### Best Practices

1. **Regular Backups**
   - Schedule automated backups
   - Verify backup integrity
   - Test restoration procedures

2. **Security Considerations**
   - Encrypt sensitive data
   - Use secure backup locations
   - Implement access controls

3. **Documentation**
   - Document backup procedures
   - Maintain recovery guides
   - Update procedures regularly

## Security Notes

1. **SSH Key Security**
   - Private keys should have 600 permissions
   - Public keys should have 644 permissions
   - SSH directory should have 700 permissions
   - Never share private keys
   - Use different keys for different services

2. **Environment Variables**
   - Keep sensitive data in `.env` file
   - Never commit `.env` to version control
   - Use `.env.example` for documentation

3. **Container Security**
   - Regular updates of base image
   - Minimal installed packages
   - No root access in container
   - Secure file permissions

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## SSH Agent Setup

The SSH agent is configured automatically when you start the container:

1. **Automatic Configuration**
   - SSH agent starts automatically in new shell sessions
   - SSH keys are mounted from the host system
   - Keys are added to the agent automatically
   - Agent persists between terminal sessions

2. **Verification**

   ```bash
   # Check if SSH agent is running
   echo $SSH_AUTH_SOCK

   # List loaded keys
   ssh-add -l

   # Test GitHub connection
   ssh -T git@github.com
   ```

3. **Security Features**
   - Keys are mounted read-only from host
   - Strict permission enforcement (600 for keys, 700 for .ssh directory)
   - Keys are never stored in the container
   - Agent environment is persisted securely

### Manual SSH Setup (if needed)

1. **Start SSH Agent**

   ```bash
   eval "$(ssh-agent -s)"
   ```

2. **Add Keys**

   ```bash
   ssh-add ~/.ssh/your-key
   ```

3. **Verify Setup**

   ```bash
   ssh-add -l
   ssh -T git@github.com
   ```

## Git Synchronization

The project includes a `sync_git.sh` script that helps manage Git repository synchronization. This script is particularly useful for:

- Initializing new Git repositories
- Syncing with remote repositories
- Managing local changes
- Automatic backup of local changes when needed

### Using sync_git.sh

1. **Configuration**
   Add the following to your `.env` file:

   ```bash
   # Git repository URL (required for new repositories)
   GIT_REMOTE_URL="https://github.com/username/repo.git"
   # or
   GIT_REMOTE_URL="git@github.com:username/repo.git"
   ```

2. **Basic Usage**

   ```bash
   # Run the script
   ./scripts/sync_git.sh
   ```

3. **Force Pull Mode**
   To force pull and overwrite local changes:

   ```bash
   FORCE_PULL=true ./scripts/sync_git.sh
   ```

4. **Branch Selection**
   To specify a different branch:

   ```bash
   BRANCH=develop ./scripts/sync_git.sh
   ```

### Features

- **Automatic Repository Initialization**: If no `.git` directory exists, the script will:
  - Initialize a new repository
  - Configure the remote using `GIT_REMOTE_URL` from `.env`
  - Set up the initial branch

- **Safe Synchronization**: By default, the script:
  - Checks for local changes before pulling
  - Prevents accidental overwrites
  - Provides clear error messages

- **Force Pull Option**: When `FORCE_PULL=true`:
  - Creates a backup of local changes
  - Resets to remote state
  - Removes untracked files

- **Backup System**: When force pulling:
  - Creates timestamped backup directory
  - Saves local changes as patch
  - Preserves untracked files

### Keep in mind

1. Always commit or stash local changes before syncing
2. Use `FORCE_PULL=true` only when necessary
3. Keep your `GIT_REMOTE_URL` updated in `.env`
4. Check backup directory if force pull was used
