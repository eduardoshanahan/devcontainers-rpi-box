# Configuration Guide

## Overview

This guide covers all configuration files and settings in the project.

## Environment Configuration

### .devcontainer/config/.env

The main environment configuration file. This file is not tracked in version control.

**Required Variables**:

```bash
HOST_USERNAME=your_username
HOST_UID=1000
HOST_GID=1000
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"
EDITOR_CHOICE=cursor
DOCKER_IMAGE_NAME=devcontainers-rpi-box
DOCKER_IMAGE_TAG=latest
```

**Optional Variables**:

```bash
# Container resources
CONTAINER_MEMORY=4g
CONTAINER_CPUS=2
CONTAINER_SHM_SIZE=2g
CONTAINER_HOSTNAME=devcontainers-rpi-box

# Version overrides
PYTHON_VERSION=3.11
ANSIBLE_VERSION=9.2.0
ANSIBLE_LINT_VERSION=25.1.3

# Git configuration
GIT_REMOTE_URL=https://github.com/yourusername/yourrepo.git
```

**Validation**: Run `validate-env.sh` to verify configuration.

---

## Ansible Configuration

### ansible.cfg

Located in `src/ansible.cfg`:

```ini
[defaults]
inventory = ./inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
interpreter_python = auto_silent
```

**Settings**:

- `inventory`: Path to inventory file
- `host_key_checking`: Disables SSH host key checking (useful for dynamic IPs)
- `retry_files_enabled`: Disables retry file creation
- `interpreter_python`: Auto-detects Python interpreter

---

## Inventory Configuration

### hosts.yml

Located in `src/inventory/hosts.yml` (not in version control).

**Example**:

```yaml
all:
  children:
    rpi:
      hosts:
        rpi1:
          ansible_host: 192.0.2.10
          ansible_user: pi
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
        rpi2:
          ansible_host: 192.0.2.11
          ansible_user: pi
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

**Variables**:

- `ansible_host`: IP address or hostname
- `ansible_user`: SSH username
- `ansible_ssh_private_key_file`: Path to SSH private key

### hosts.example.yml

Template for creating `hosts.yml`. Copy and customize:

```bash
cp src/inventory/hosts.example.yml src/inventory/hosts.yml
```

---

## Group Variables

### group_vars/rpi.yml

Variables applied to all Raspberry Pi hosts.

**Example**:

```yaml
---
# Timezone
timezone: "America/New_York"

# APT cache validity
apt_cache_valid_time: 3600

# Common tools configuration
common_tools_node_exporter_install: true
common_tools_node_exporter_listen_address: "0.0.0.0:9100"

# Daily report configuration
daily_report_time: "07:00"
daily_report_email: "admin@example.com"
daily_report_sender: "rpi@example.com"
daily_report_smtp_user: "rpi@example.com"
```

---

## Secrets Configuration

### group_vars/all/local-secrets.yml

Stores sensitive data (not in version control).

**Example**:

```yaml
---
# Daily report SMTP password
daily_report_smtp_password: "your-smtp-password"

# Other secrets
vault_daily_report_password: "encrypted-password"
```

**Security**:

- Never commit this file
- Use Ansible Vault for encryption
- Restrict file permissions: `chmod 600 local-secrets.yml`

**Using Ansible Vault**:

```bash
# Create encrypted file
ansible-vault create src/inventory/group_vars/all/local-secrets.yml

# Edit encrypted file
ansible-vault edit src/inventory/group_vars/all/local-secrets.yml

# View encrypted file
ansible-vault view src/inventory/group_vars/all/local-secrets.yml
```

---

## DevContainer Configuration

### devcontainer.json

Main DevContainer configuration file.

**Key Settings**:

- Build arguments for user and versions
- VS Code extensions
- Mount points for workspace and SSH keys
- Post-create command
- Container resource limits
- Environment variables

**Customization**:

- Add extensions in `customizations.vscode.extensions`
- Modify resource limits in `runArgs`
- Add additional mounts as needed

### Dockerfile

Container image definition.

**Base**: Ubuntu 22.04

**Installed Packages**:

- curl, git, build-essential
- openssh-client, jq
- python3, python3-pip
- sshpass

**Tools**:

- Starship prompt
- Ansible (configurable version)
- ansible-lint (configurable version)
- yamllint, jmespath

**User Setup**:

- Creates user matching host UID/GID
- Grants sudo access
- Sets bash as default shell

---

## Starship Prompt Configuration

### .devcontainer/config/starship.toml

Custom Starship prompt configuration.

**Features**:

- Custom format with username, hostname, directory, git status
- Disabled package module
- Custom prompt characters
- SSH-only hostname display
- Truncated directory paths

**Customization**:
Edit the format string and module configurations as needed.

---

## Git Configuration

Git is configured via environment variables in `.devcontainer/config/.env`:

```bash
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"
```

These are automatically set in the container via `post-create.sh`.

**Manual Configuration**:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## SSH Configuration

### SSH Keys

SSH keys should be in `~/.ssh/` on the host machine. They are automatically mounted into the container.

**Required Permissions**:

- `~/.ssh/` directory: 700
- Private keys: 600
- Public keys: 644

**Setup**:

```bash
# Generate SSH key if needed
ssh-keygen -t ed25519 -C "your.email@example.com"

# Copy to Raspberry Pi
ssh-copy-id pi@192.0.2.10
```

### SSH Agent

The SSH agent is automatically configured in the container via `ssh-agent-setup.sh`.

**Manual Setup**:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

---

## Ansible Vault

### Creating Encrypted Files

```bash
# Create new encrypted file
ansible-vault create path/to/file.yml

# Edit existing encrypted file
ansible-vault edit path/to/file.yml

# View encrypted file
ansible-vault view path/to/file.yml

# Encrypt existing file
ansible-vault encrypt path/to/file.yml

# Decrypt file
ansible-vault decrypt path/to/file.yml
```

### Using Vault in Playbooks

Reference encrypted variables:

```yaml
daily_report_smtp_password: "{{ vault_daily_report_password }}"
```

Run playbooks with vault:

```bash
ansible-playbook site.yml --ask-vault-pass
# or
ansible-playbook site.yml --vault-password-file ~/.vault_pass
```

---

## Configuration Files Summary

| File | Location | Purpose | In Git? |
|------|----------|---------|---------|
| .env | `.devcontainer/config/.env` | Environment variables | No |
| ansible.cfg | `src/ansible.cfg` | Ansible configuration | Yes |
| hosts.yml | `src/inventory/hosts.yml` | Host inventory | No |
| hosts.example.yml | `src/inventory/hosts.example.yml` | Inventory template | Yes |
| rpi.yml | `src/inventory/group_vars/rpi.yml` | Group variables | Yes |
| local-secrets.yml | `src/inventory/group_vars/all/local-secrets.yml` | Secrets | No |
| devcontainer.json | `.devcontainer/devcontainer.json` | DevContainer config | Yes |
| Dockerfile | `.devcontainer/Dockerfile` | Container image | Yes |
| starship.toml | `.devcontainer/config/starship.toml` | Prompt config | Yes |

---

## Best Practices

1. **Never commit secrets**: Use `.gitignore` and Ansible Vault
2. **Use templates**: Copy example files and customize
3. **Validate configuration**: Run validation scripts before use
4. **Version control**: Keep configuration templates in Git
5. **Documentation**: Document custom variables and settings
6. **Backup**: Keep backups of important configuration files
7. **Permissions**: Set correct file permissions for sensitive files
