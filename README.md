# Raspberry Pi Automation (Ansible)

This repo provides a devcontainer-backed Ansible workflow to provision and
maintain Raspberry Pi hosts (Ubuntu Server). All playbooks, inventory, and
roles live under `src/`.

## Quick Start

1. Copy `.env.example` to `.env`, then run `./launch.sh`.
2. Reopen in container (VS Code/Cursor) to use the preconfigured Ansible tools.
3. Configure host vars and cloud-init seed files.
4. Run the base playbook: `ansible-playbook src/playbooks/pi-base.yml`.

## Key Docs

- Usage and cloud-init SD steps: [how to use this project.md](how%20to%20use%20this%20project.md)
- Validation and smoke tests: [how to test.md](how%20to%20test.md)
- Current state and history: [recap.md](recap.md)
- Roadmap and decisions: [plans and execution.md](plans%20and%20execution.md)

## Helpful Scripts

- Lint + idempotence + checks: `scripts/ansible-smoke.sh`
- Devcontainer launcher: `launch.sh`

## Notes

- Cloud-init seed examples live in `non_comitted_files/system-boot/*.example`.
- Real seed files are gitignored; copy the examples before flashing.
