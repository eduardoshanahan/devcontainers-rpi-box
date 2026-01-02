# Raspberry Pi Automation (Ansible)

This repo provides a devcontainer-backed Ansible workflow to provision and
maintain Raspberry Pi hosts (Ubuntu Server). It is ready to use as a template
for Docker-based app deployments after the base OS/infra setup completes. All
playbooks, inventory, and roles live under `src/`.

## Quick Start

1. Copy `.env.example` to `.env`, then run `./launch.sh`.
2. Reopen in container (VS Code/Cursor/Antigravity) to use the preconfigured Ansible tools.
3. Configure host vars and cloud-init seed files.
4. Run the base playbook: `ansible-playbook src/playbooks/pi-base.yml`.

## Key Docs

- Setup of environment variables: [working with environment variables](working%20with%20environment%20variables.md)
- Usage and cloud-init SD steps: [how to use this project.md](how%20to%20use%20this%20project.md)
- Validation and smoke tests: [how to test.md](how%20to%20test.md)
- Daily timeline + summaries: [lm/recap](lm/recap) and [lm/recaps](lm/recaps)
- Current state: [lm/state](lm/state)
- Roadmap and decisions: [lm/plans](lm/plans)

## Helpful Scripts

- Lint + idempotence + checks: `scripts/ansible-smoke.sh`
- Devcontainer launcher: `launch.sh`

## Notes

- Cloud-init seed examples live in `sd_card_files/system-boot/*.example`.
- Real seed files are gitignored; copy the examples before flashing.
