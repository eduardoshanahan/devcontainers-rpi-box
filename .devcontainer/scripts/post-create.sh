#!/bin/sh
set -eu

if [ -z "${WORKSPACE_FOLDER:-}" ]; then
    printf '%s\n' "Error: WORKSPACE_FOLDER is not set." >&2
    printf '%s\n' "Hint: start the devcontainer via ./devcontainer-launch.sh or ./editor-launch.sh." >&2
    exit 1
fi

workspace_dir="$WORKSPACE_FOLDER"

# Load environment variables via shared loader (project root .env is authoritative)
if [ -f "${workspace_dir}/.devcontainer/scripts/env-loader.sh" ]; then
    # shellcheck disable=SC1090
    . "${workspace_dir}/.devcontainer/scripts/env-loader.sh"
    load_project_env "$workspace_dir"
elif [ -f "$HOME/.devcontainer/scripts/env-loader.sh" ]; then
    # shellcheck disable=SC1090
    . "$HOME/.devcontainer/scripts/env-loader.sh"
    load_project_env "$workspace_dir"
else
    echo "Warning: env-loader.sh not found; skipping environment load"
fi

# Validate environment (including SSH agent forwarding).
VALIDATOR="${workspace_dir}/.devcontainer/scripts/validate-env.sh"
if [ -f "$VALIDATOR" ]; then
    echo "Validating environment variables..."
    if ! sh "$VALIDATOR"; then
        echo "Error: Environment validation failed." >&2
        exit 1
    fi
else
    echo "Error: validate-env.sh not found at $VALIDATOR" >&2
    exit 1
fi

# Configure Git if variables are set
if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
    REPO_DIR="$workspace_dir"
    if [ -d "$REPO_DIR/.git" ]; then
        echo "Configuring repo-local Git identity:"
        echo "  Name:  $GIT_USER_NAME"
        echo "  Email: $GIT_USER_EMAIL"
        git -C "$REPO_DIR" config user.name "$GIT_USER_NAME"
        git -C "$REPO_DIR" config user.email "$GIT_USER_EMAIL"
    else
        echo "Warning: No git repository found in $REPO_DIR. Skipping git identity setup."
    fi
else
    echo "Warning: GIT_USER_NAME or GIT_USER_EMAIL not set. Git identity not configured."
fi

# Add workspace to Git safe directories
echo "Configuring Git safe directories..."
git config --global --add safe.directory "$workspace_dir"
git config --global --add safe.directory /home/${USERNAME}/.devcontainer

# Make scripts executable
chmod +x "${workspace_dir}/.devcontainer/scripts/bash-prompt.sh"
chmod +x "${workspace_dir}/.devcontainer/scripts/ssh-agent-setup.sh"

# Bootstrap Ansible workspace (collections/roles + Galaxy requirements)
ANSIBLE_ROOT="${workspace_dir}/src"
ANSIBLE_REQUIREMENTS_FILE="${ANSIBLE_ROOT}/requirements.yml"

retry_galaxy_install() {
    description="$1"
    shift
    max_attempts=3
    attempt=1
    until "$@"; do
        if [ "$attempt" -ge "$max_attempts" ]; then
            echo "Warning: ${description} failed after ${max_attempts} attempts." >&2
            return 1
        fi
        echo "Retrying ${description} (attempt $((attempt + 1))/${max_attempts})..."
        attempt=$((attempt + 1))
        sleep 2
    done
}

if [ -d "$ANSIBLE_ROOT" ]; then
    mkdir -p "${ANSIBLE_ROOT}/collections" "${ANSIBLE_ROOT}/roles"
    if command -v ansible-galaxy >/dev/null 2>&1 && [ -f "$ANSIBLE_REQUIREMENTS_FILE" ]; then
        echo "Installing Ansible dependencies from ${ANSIBLE_REQUIREMENTS_FILE}..."
        retry_galaxy_install "ansible-galaxy collection install" ansible-galaxy collection install -r "$ANSIBLE_REQUIREMENTS_FILE" --force || true
        retry_galaxy_install "ansible-galaxy role install" ansible-galaxy role install -r "$ANSIBLE_REQUIREMENTS_FILE" --force || true
    else
        echo "No Ansible requirements file found at ${ANSIBLE_REQUIREMENTS_FILE}; skipping Galaxy install."
    fi
else
    echo "Ansible src directory (${ANSIBLE_ROOT}) missing; skipping Ansible bootstrap."
fi

# Ensure helper fixer is executable and run it to set permissions for helper scripts
if [ -f "${workspace_dir}/.devcontainer/scripts/fix-permissions.sh" ]; then
    chmod +x "${workspace_dir}/.devcontainer/scripts/fix-permissions.sh" 2>/dev/null || true
    # Run fixer (non-fatal)
    "${workspace_dir}/.devcontainer/scripts/fix-permissions.sh" "${workspace_dir}/.devcontainer/scripts" || true
fi

# Source scripts in bashrc if not already present
if ! grep -q "source.*bash-prompt.sh" "$HOME/.bashrc"; then
    printf '%s\n' ". ${workspace_dir}/.devcontainer/scripts/bash-prompt.sh" >> "$HOME/.bashrc"
fi

if ! grep -q "source.*ssh-agent-setup.sh" "$HOME/.bashrc"; then
    printf '%s\n' ". ${workspace_dir}/.devcontainer/scripts/ssh-agent-setup.sh" >> "$HOME/.bashrc"
fi

# Ensure VS Code shell integration variable is set early to avoid nounset errors.
ensure_bashrc_guard() {
    guard_start="# >>> devcontainer guard >>>"
    if ! grep -q "$guard_start" ~/.bashrc; then
        tmp_file="$(mktemp)"
        {
            cat <<'EOF'
# >>> devcontainer guard >>>
# Avoid nounset errors from VS Code shell integration.
export VSCODE_SHELL_LOGIN="${VSCODE_SHELL_LOGIN:-}"
# <<< devcontainer guard <<<
EOF
            cat ~/.bashrc
        } > "$tmp_file"
        mv "$tmp_file" ~/.bashrc
    fi
}

ensure_bashrc_guard

# Ensure login shells also inherit the alias setup by sourcing .bashrc
ensure_profile_sources_bashrc() {
    profile_file="$1"
    [ -f "$profile_file" ] || touch "$profile_file"
    if ! grep -q "source ~/.bashrc" "$profile_file"; then
        cat <<'EOF' >> "$profile_file"
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
EOF
    fi
}

ensure_profile_sources_bashrc ~/.bash_profile
ensure_profile_sources_bashrc ~/.profile
