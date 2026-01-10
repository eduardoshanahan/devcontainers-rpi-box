# Raspberry Pi Automation (Ansible)

This repo provides a devcontainer-backed Ansible workflow to provision and
maintain Raspberry Pi hosts (Ubuntu Server). It is ready to use as a template
for Docker-based app deployments after the base OS/infra setup completes. All
playbooks, inventory, and roles live under `src/`.

## Quick Start

1. Copy `.env.example` to `.env`, then run `./editor-launch.sh` (GUI) or `./devcontainer-launch.sh` (CLI).
2. Optional: start the standard tmux workspace with `make workspace`.
3. Reopen in container (VS Code/Cursor/Antigravity) to use the preconfigured Ansible tools.
4. Configure host vars and cloud-init seed files.
5. Run the base playbook: `ansible-playbook src/playbooks/pi-base.yml`.

## Key Docs

- Documentation index: [documentation/README.md](documentation/README.md)
- Setup of environment variables: [working with environment variables](documentation/working%20with%20environment%20variables.md)
- Usage and cloud-init SD steps: [how to use this project.md](documentation/how%20to%20use%20this%20project.md)
- Validation and smoke tests: [how to test.md](documentation/how%20to%20test.md)
- Troubleshooting: [troubleshooting.md](documentation/troubleshooting.md)
- Git sync helper: [how to use sync-git.md](documentation/how%20to%20use%20sync-git.md)
- Devcontainer CLI: [how to use devcontainer cli.md](documentation/how%20to%20use%20devcontainer%20cli.md)
- Claude Code: [how to use claude.md](documentation/how%20to%20use%20claude.md)
- File sync and ownership: [file sync and ownership.md](documentation/file%20sync%20and%20ownership.md)
- Daily timeline + summaries: [documentation/diary/recaps](documentation/diary/recaps)
- Current state: [documentation/diary/state](documentation/diary/state)
- Roadmap and decisions: [documentation/diary/plans](documentation/diary/plans)

## Helpful Scripts

- Lint + idempotence + checks: `scripts/ansible-smoke.sh`
- Devcontainer launchers:
- `editor-launch.sh` (GUI)
  - `devcontainer-launch.sh` (CLI shell)
  - `claude-launch.sh` (CLI, launches Claude Code)

## Notes

- Cloud-init seed examples live in `sd_card_files/system-boot/*.example`.
- Real seed files under `sd_card_files/system-boot/` are gitignored; copy the examples before flashing.
