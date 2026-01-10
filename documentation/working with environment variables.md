# Working with environment variables (TL;DR)

1. **Copy the template:** `cp .env.example .env` (only needs to happen once per project).
2. **Fill in the values:** edit `.env` so that `PROJECT_NAME`, `HOST_USERNAME`, `HOST_UID`, `HOST_GID`, Git info, `EDITOR_CHOICE` (code/cursor/antigravity), `CONTAINER_HOSTNAME=${PROJECT_NAME}-${EDITOR_CHOICE}`, `DOCKER_IMAGE_NAME=${PROJECT_NAME}-${EDITOR_CHOICE}`, etc. match your machine. This file is the single source of truth.
3. **Host vars from env:** Ansible host vars read from `.env` via `lookup('env', ...)`. Populate `ANSIBLE_USER`, `ANSIBLE_SSH_PRIVATE_KEY_FILE`, `PI_BASE_ADMIN_USER`, `PI_BASE_ADMIN_SSH_PUBLIC_KEY_FILE`, `PI_BASE_ALLOW_PASSWORDLESS_SUDO`, the `DAILY_REPORT_*` fields, `BACKUP_RESTIC_*`, `BACKUP_RESTIC_TIMER_SCHEDULE`, and (if needed) `OPENAI_API_KEY` here.
4. **Validate & launch:** start with `./editor-launch.sh` (GUI), `./devcontainer-launch.sh` (CLI shell), or `./claude-launch.sh` (Claude Code inside the container). Each loads `.env`, runs `.devcontainer/scripts/validate-env.sh`, and exits early if something is wrong.
5. **Inside the container:** every helper script sources `.devcontainer/scripts/env-loader.sh`, so anything defined in `.env` automatically shows up in init/post-create hooks and in your shell.
6. **Adding new variables:** document them in `.env.example`, consume them via `env-loader.sh`, and (if they’re required) add a rule to `.devcontainer/scripts/validate-env.sh`. No other script needs to change. For multiple git remotes, set `GIT_SYNC_REMOTES`, `GIT_SYNC_PUSH_REMOTES`, and matching `GIT_REMOTE_URL_<REMOTE>` entries here as well.

Optional launcher flags:
- `REBUILD_CONTAINER=1` to rebuild and restart the devcontainer before launching.
- `KEEP_CONTAINER=1` to keep the CLI container running after exit.
- `SKIP_CLAUDE_INSTALL=1` to skip Claude Code install in post-create.

Keep `.env` out of version control (already covered by `.gitignore`) so each machine can store its own user-specific values without conflicts.
