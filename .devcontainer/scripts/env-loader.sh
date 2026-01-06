#!/bin/sh
# Shared env loader: load project-root .env (authoritative)
# Usage:
#   # from inside container: . /workspace/.devcontainer/scripts/env-loader.sh && load_project_env /workspace [debug]
#   # from host script: . "$PROJECT_DIR/.devcontainer/scripts/env-loader.sh" && load_project_env "$PROJECT_DIR" [debug]
#
# Debug mode:
#   - Set ENV_LOADER_DEBUG=1 (exported) or pass second param as 1 to load_project_env to print newly loaded vars.

load_project_env() {
    env_loader_workspace_dir="$1"
    env_loader_debug=""

    if [ -z "$env_loader_workspace_dir" ]; then
        echo "Error: load_project_env requires a workspace directory"
        return 1
    fi

    if [ $# -ge 2 ]; then
        env_loader_debug="$2"
    elif [ "${ENV_LOADER_DEBUG+x}" = "x" ]; then
        env_loader_debug="$ENV_LOADER_DEBUG"
    fi

    project_env="$env_loader_workspace_dir/.env"
    # Capture current variables
    before_file="$(mktemp)"
    env | cut -d= -f1 | sort > "$before_file"

    # Load project root .env first (authoritative); preserve quoting
    if [ -f "$project_env" ]; then
        set -a
        # shellcheck disable=SC1090
        . "$project_env"
        set +a
    fi

    # Capture after state and compute newly added variables
    after_file="$(mktemp)"
    env | cut -d= -f1 | sort > "$after_file"

    if [ "$env_loader_debug" = "1" ] || [ "$env_loader_debug" = "true" ]; then
        echo "env-loader: debug enabled — listing variables added by load_project_env (workspace: $env_loader_workspace_dir)"
        # comm -13 shows lines present in after_file but not before_file
        if command -v comm >/dev/null 2>&1; then
            comm -13 "$before_file" "$after_file" | while IFS= read -r var; do
                # Skip empty var names (defensive)
                [ -z "$var" ] && continue
                eval "var_value=\${$var-}"
                printf '%s=%s\n' "$var" "$var_value"
            done
        else
            # Fallback: simple list approach
            echo "env-loader: comm not available; showing all variables (best-effort)"
            while IFS= read -r var; do
                [ -z "$var" ] && continue
                eval "var_value=\${$var-}"
                printf '%s=%s\n' "$var" "$var_value"
            done < "$after_file"
        fi
    fi

    # Clean up
    rm -f "$before_file" "$after_file" 2>/dev/null || true
}
