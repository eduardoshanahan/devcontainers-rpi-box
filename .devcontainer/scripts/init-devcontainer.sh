#!/bin/sh
set -eu

if [ -z "${WORKSPACE_FOLDER:-}" ]; then
    printf '%s\n' "Error: WORKSPACE_FOLDER is not set." >&2
    printf '%s\n' "Hint: start the devcontainer via ./devcontainer-launch.sh or ./editor-launch.sh." >&2
    exit 1
fi

workspace_dir="$WORKSPACE_FOLDER"

# Prefer workspace colors, then HOME; fallback to minimal colors
if [ -f "${workspace_dir}/.devcontainer/scripts/colors.sh" ]; then
    . "${workspace_dir}/.devcontainer/scripts/colors.sh"
elif [ -f "$HOME/.devcontainer/scripts/colors.sh" ]; then
    . "$HOME/.devcontainer/scripts/colors.sh"
else
    COLOR_RESET='\033[0m'
    COLOR_BOLD='\033[1m'
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
fi

# Load environment variables via shared loader (project root .env is authoritative)
loader_found=false
for loader in "${workspace_dir}/.devcontainer/scripts/env-loader.sh" "$HOME/.devcontainer/scripts/env-loader.sh"; do
    if [ -f "$loader" ]; then
        # shellcheck disable=SC1090
        . "$loader"
        load_project_env "$workspace_dir"
        loader_found=true
        break
    fi
done

if [ "$loader_found" = false ]; then
    printf '%b\n' "${YELLOW}Warning: env-loader.sh not found; environment variables may be missing${COLOR_RESET}"
fi

# Configure Git if variables are set
if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
    REPO_DIR="$workspace_dir"
    if [ -d "$REPO_DIR/.git" ]; then
        printf '%b\n' "${GREEN}Configuring Git (repo-local) with:${COLOR_RESET}"
        printf '%b\n' "  ${COLOR_BOLD}Name:${COLOR_RESET}  $GIT_USER_NAME"
        printf '%b\n' "  ${COLOR_BOLD}Email:${COLOR_RESET} $GIT_USER_EMAIL"
        git -C "$REPO_DIR" config user.name "$GIT_USER_NAME"
        git -C "$REPO_DIR" config user.email "$GIT_USER_EMAIL"
    else
        printf '%b\n' "${YELLOW}Warning:${COLOR_RESET} No git repository found in $REPO_DIR. Skipping git identity setup."
    fi
fi

# Make scripts executable (existing entries)
chmod +x "${workspace_dir}/.devcontainer/scripts/bash-prompt.sh" 2>/dev/null || true
chmod +x "${workspace_dir}/.devcontainer/scripts/ssh-agent-setup.sh" 2>/dev/null || true

# Ensure helper scripts are executable
chmod +x "${workspace_dir}/.devcontainer/scripts/verify-git-ssh.sh" 2>/dev/null || true
chmod +x "${workspace_dir}/.devcontainer/scripts/env-loader.sh" 2>/dev/null || true
chmod +x "${workspace_dir}/.devcontainer/scripts/fix-permissions.sh" 2>/dev/null || true

# Ensure bashrc sources helper scripts (avoid duplicates)
if ! grep -qF "${workspace_dir}/.devcontainer/scripts/bash-prompt.sh" "$HOME/.bashrc" 2>/dev/null; then
    printf '%s\n' ". ${workspace_dir}/.devcontainer/scripts/bash-prompt.sh" >> "$HOME/.bashrc"
fi

if ! grep -qF "${workspace_dir}/.devcontainer/scripts/ssh-agent-setup.sh" "$HOME/.bashrc" 2>/dev/null; then
    printf '%s\n' ". ${workspace_dir}/.devcontainer/scripts/ssh-agent-setup.sh" >> "$HOME/.bashrc"
fi

printf '%b\n' "${GREEN}Initialization complete.${COLOR_RESET}"
