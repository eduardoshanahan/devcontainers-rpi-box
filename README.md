# Development Container Template - Raspberry Pi

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Required-blue)](https://www.docker.com/)
[![VS Code](https://img.shields.io/badge/VS%20Code-Required-blue)](https://code.visualstudio.com/)

## Why do I have this project?

In the last few years I have been using Visual Studio Code, and I like to use as much containers as I can, instead of setting up environments for Python or things like that.

Devcontainers is pretty handy for that, and it is just a short step to move it into a deployment when I am done.

I found myself recreating a similar setup each time, with more or less features each time, and this is an attempt to simplify that step.

I am thinking of creating a few different devcontainers, each based on a previous iteration (although I don't like inheritance, in this case seems to be valuable).

This iteration extends the original Git-focused template with an Ansible-ready stack while keeping the UX identical: same UID/GID mirroring, SSH agent forwarding, and helper scripts—now plus linted playbooks that live under `src/`.

VS Code is also configured to use the validation tools by way of extensions, and they also hang as command line tools (although I don't use them regularly).

An extra situation is that I have also a Synology NAS where I synchronise my files. I commit to git when ready, but I like to be able to continue working in any of my machines and have them in sync automatically. Synology Drive is good for that.

However, there are some tricky cases around file ownership (I use Ubuntu 24.10 at the moment in my own machines). Depending on where the files are created (the workstation or inside the container), Synology gets confused and start to cause troubles around the synchronisation process.

A way around it is to use the same user inside the container as it is outside. A launch script takes care of that details passing activity, and all the files seems to be updated correctly now.

I want to be able to use Git inside and out of the container, then I also pass the ssh credentials to my Git remote repository to syncronise at will. That also seems to be working correctly.

## Overview

This project serves as a comprehensive template for setting up **Development Containers (Devcontainers)**. It is designed to provide a consistent, reproducible, and containerized development environment, primarily for use with Visual Studio Code, Cursor, or Antigravity.

## Core Problem Solved

The project addresses the challenge of maintaining consistent development environments across multiple machines. It specifically targets issues related to:

- **File Synchronization**: mitigating conflicts when using services like Synology Drive for syncing code between machines.
- **File Ownership**: handling UID/GID mapping to prevent permission issues between the host/container and the synchronization service.
- **Reproducibility**: eliminating "it works on my machine" problems by defining the environment in code.

## Key Features

### 1. Containerized Environment

- Provides a pre-configured `Dockerfile` based on Ubuntu.
- Includes essential development tools:
  - **Git** (with SSH support)
  - **Docker CLI** (for Docker-in-Docker capabilities)
  - **Starship** (for a modern shell prompt)
  - **JSON tools** (`jq`, linters)
  - **Ansible Core toolchain** (`ansible-core`, `ansible-lint`, `yamllint`)

### 2. Intelligent Launch System

- Includes a `launch.sh` script that:
  - Validates environment variables (`.env`).
  - Checks for required tools.
  - Launches the user's preferred editor (VS Code, Cursor, or Antigravity).
  - Ensures the local environment is correctly prepped before starting the container.

### 3. Git & SSH Integration

- Seamlessly forwards SSH agents to the container, allowing secure GitHub interactions without storing keys inside the image. When `SSH_AUTH_SOCK` is forwarded from the host we reuse it; only if it is missing do we start a fresh agent and manage keys locally.
- Automates Git configuration (user name, email) based on environment variables.

### 4. Custom Synchronization

- Features a `sync_git.sh` script to safely manage Git operations in environments where an external file syncer (like Synology Drive) is also active, preventing data corruption or conflicts.

### 5. Ansible-Ready Workflow

- `src/ansible.cfg` is exported as `ANSIBLE_CONFIG`, so every Ansible command automatically uses the repo-scoped configuration.
- `src/requirements.yml` captures Galaxy collections/roles; the post-create hook auto-installs them if the file is present.
- VS Code ships with the Red Hat Ansible & YAML extensions plus python tooling so linting and IntelliSense work out of the box.

## Quick Start

1. **Copy the env template:** `cp .env.example .env`
2. **Fill in required values:** edit `.env` so `PROJECT_NAME`, `HOST_USERNAME`, UID/GID, git identity, remotes, and editor choice match your machine (see the comments inside the file). `CONTAINER_HOSTNAME` and `DOCKER_IMAGE_NAME` already derive from `PROJECT_NAME` + `EDITOR_CHOICE`, so you only tweak them if you need a custom naming scheme.
3. **Launch your editor via the helper:** run `./launch.sh`. It loads `.env`, validates it, and then opens VS Code/Cursor/Antigravity pointing at this folder.
4. **Reopen in container:** inside the editor, use the Dev Containers extension’s “Reopen in Container” command; it reuses the values validated in step 3.
5. **Work normally:** run `./scripts/sync_git.sh` whenever you need to pull/push (configure `GIT_SYNC_REMOTES`/`GIT_SYNC_PUSH_REMOTES` if you use multiple remotes). SSH agent forwarding just works as long as your host exposes `SSH_AUTH_SOCK`.
6. **Run Ansible:** every playbook/inventory lives in `src/`; see the workflow section below for the common commands.

## Usage

Users clone this repository, configure a `.env` file with their specific user details (UID/GID, Git credentials), and use the provided scripts to launch their editor. The editor then reopens the project inside the defined Docker container, providing a fully featured development workspace.

### Keeping the repository in sync

Run `./scripts/sync_git.sh` whenever you want to fast-forward the local checkout or publish your current branch. Configure the remotes the script should touch via `.env`:

```env
# Pull from both GitHub and LAN mirrors (GitHub is the primary remote here)
GIT_SYNC_REMOTES="origin lan"

# Optionally push the current branch to both mirrors after syncing
GIT_SYNC_PUSH_REMOTES="origin lan"

# Provide a URL if the script needs to auto-add the LAN remote
GIT_REMOTE_URL_LAN="ssh://git@192.168.1.10:/volume1/git/${PROJECT_NAME}.git"
```

Once configured, you can run:

```bash
# standard update (requires a clean working tree)
./scripts/sync_git.sh

# overwrite local changes with the remote version
FORCE_PULL=true ./scripts/sync_git.sh
```

- The script only touches the current repository (no global git config, no backups).  
- It ensures every remote listed in `GIT_SYNC_REMOTES` exists (using `GIT_REMOTE_URL` or `GIT_REMOTE_URL_<REMOTE>` values if it needs to add one).  
- The first remote in `GIT_SYNC_REMOTES` is treated as the primary upstream for pulls/resets; additional remotes are rebased in sequence so they stay in sync.  
- Set `GIT_SYNC_PUSH_REMOTES` to automatically push the branch after syncing (leave empty to skip pushes).  
- If you have uncommitted changes it exits with an error unless you re-run it with `FORCE_PULL=true`.

### Ansible Workflow

All infrastructure code, inventories, and settings live under `src/`. The repo exports `ANSIBLE_CONFIG=/workspace/src/ansible.cfg`, so any Ansible command you run (inside or outside VS Code) automatically respects the repo settings without additional flags.

```
src/
├── ansible.cfg
├── requirements.yml
├── inventory/
│   └── hosts.ini
├── group_vars/
│   └── all.yml
├── inventory/host_vars/
├── playbooks/
│   └── sample.yml
├── roles/
└── collections/
```

Key conventions:

- Manage Galaxy dependencies via `src/requirements.yml`. The devcontainer’s post-create hook will automatically run `ansible-galaxy collection install -r src/requirements.yml --force` and `ansible-galaxy role install -r src/requirements.yml --force` (with a couple of automatic retries) if the file exists, keeping `src/collections` and `src/roles` in sync. To bump collection versions, edit `src/requirements.yml` and adjust the `<N` portion for the major version you want to track, then run `ansible-galaxy collection install -r src/requirements.yml --force`.
- Keep host-specific variables (IPs, SSH users, secrets) in `inventory/host_vars/<hostname>.yml`. Store sensitive data outside git (e.g., under `non_comitted_files/host_vars/`) or encrypt it with `ansible-vault` before committing so the repo stays shareable without leaking credentials.
- Use the provided sample inventory/playbook as a smoke test: `ansible-playbook src/playbooks/sample.yml -i src/inventory/hosts.ini`.
- `ansible-lint` and `yamllint` are preinstalled; the VS Code Ansible extension surfaces diagnostics automatically, or run them manually:

Run the smoke test helper anytime you want to confirm the toolchain (lint + sample playbook) is healthy inside the container:

```bash
./scripts/ansible-smoke.sh                # defaults to src/playbooks/sample.yml
./scripts/ansible-smoke.sh path/to.yml    # specify another playbook if desired
```

Feel free to replace the starter playbook/inventory with your real automation—keeping it all under `src/` means the repository stays tidy and portable.

### Vendored Galaxy collections and linting

- Galaxy installs land under `src/collections/ansible_collections/`, and that entire directory is gitignored on purpose. Regenerate its contents via `src/requirements.yml` rather than committing vendor code.
- `.yamllint` extends the default rules, disables noisy checks required by `ansible-lint`, and ignores any path matching `**/ansible_collections/**`. This keeps lint results focused on files we author while still letting `scripts/ansible-smoke.sh` validate the repository quickly.
