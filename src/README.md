# Raspberry Pi Ansible Bootstrap

This repository automates the provisioning and ongoing maintenance of Raspberry Pi hosts using Ansible. The playbook applies a secure baseline, installs operational tooling, sends daily health reports, and prepares each node for future services such as Pi-hole, Prometheus, and Grafana.

## Features

- Single entry point via `site.yml` that targets the `rpi` inventory group.
- Opinionated role set covering package prep (`apt_prep`), base config (`common`), troubleshooting utilities (`common_tools`), daily reporting, Docker, unattended upgrades, and system updates.
- Automated msmtp configuration and daily status email with node exporter state, Docker summary, network inventory, and security events.
- Strict separation of public defaults vs. private secrets through `group_vars/all/local-secrets.yml`.
- Devcontainer configuration (see repo root) for a repeatable Ansible authoring environment with linting and testing tools enabled.

## Repository Layout

```text
src/
├── ansible.cfg                # Points to inventory/hosts.yml, sets safe defaults
├── site.yml                   # Main playbook including all roles
├── inventory/
│   ├── hosts.yml              # Private inventory (ignored by git)
│   └── hosts.example.yml      # Public template
├── group_vars/
│   └── all/
│       ├── local-secrets.yml          # Real secrets (ignored)
│       └── local-secrets.example.yml  # Template to copy and edit
└── roles/
    ├── apt_prep/              # Ensures apt cache is warmed exactly once
    ├── common/                # Timezone, baseline packages, future hardening
    ├── common_tools/          # Admin tooling + node exporter management
    ├── daily_report/          # msmtp config, script, timer/service units
    ├── docker/
    ├── system_update/
    └── unattended_upgrades/
```

## Prerequisites

- Ansible 9.x (installed automatically inside the devcontainer, or manually on your control machine).
- `community.general` collection for the timezone module (`ansible-galaxy collection install community.general`).
- SSH key-based access to each Raspberry Pi host listed in `inventory/hosts.yml`.
- Copied and populated secrets file (`cp group_vars/all/local-secrets.example.yml group_vars/all/local-secrets.yml`).
- Optional: `ansible-lint` for local validation (`pip install ansible-lint` or use the devcontainer).

## Secrets Workflow

1. Copy `group_vars/all/local-secrets.example.yml` to `group_vars/all/local-secrets.yml`.
2. Populate SMTP credentials, report recipients, and any other sensitive values.
3. Never commit `local-secrets.yml`; it is already ignored through the repo `.gitignore`.
4. Store per-host overrides in inventory vars files as needed (e.g., `inventory/group_vars/rpi.yml`).

## Running the Playbook

```bash
cd src
ansible-playbook -i inventory/hosts.yml site.yml
```

- Use `--limit hostname` to target a specific Pi.
- Use `--tags daily_report` (or any role tag) to focus on part of the configuration.
- Run `ansible-playbook --syntax-check site.yml` before pushing changes.

## Role Overview

| Role | Purpose | Highlights |
|------|---------|------------|
| `apt_prep` | Preps apt cache | Runs once per play to avoid repeated `apt update`. |
| `common` | Baseline system config | Configures timezone via `community.general.timezone` and installs `common_packages`. |
| `common_tools` | Admin + monitoring tools | Installs troubleshooting packages, manages sudoers aliases, and configures `prometheus-node-exporter`. |
| `daily_report` | Health reporting | Deploys `/usr/local/bin/daily-report.sh`, systemd service/timer, msmtp configs, and logs to `/var/log/msmtp/msmtp.log`. |
| `unattended_upgrades` | Security patching | Enables unattended upgrades and daily updates. |
| `docker` | Container runtime | Installs Docker engine and prepares it for future workloads. |
| `system_update` | Periodic package refresh | Applies OS updates outside of unattended security patches. |

## Daily Report Details

- Script collects uptime, load, CPU temperature, disk usage, memory stats, SSH failures, Docker containers, node exporter status, and all IPv4 interfaces.
- Email is sent through msmtp + Zoho using credentials stored in `daily_report_smtp_user` / `daily_report_smtp_password`.
- Logging lives under `/var/log/msmtp/msmtp.log`, with directory/file permissions managed by Ansible.
- Triggered daily via `daily-report.timer`; you can start it immediately with `systemctl start daily-report.service`.

## Hardening Backlog

The `common` role is the right place to add:

- SSH hardening (disable password auth, restrict root login, enforce limited auth attempts).
- Consistent `/etc/motd` or `update-motd.d` banner with access guidance.
- Baseline firewall (ufw or nftables) seeded with allow rules for SSH, node exporter, and future monitoring endpoints.

Track these improvements in `todo.md` or a dedicated issue so future iterations can implement them without duplicating effort.

## Development Tips

- Use the provided devcontainer (`./launch.sh` from repo root) for a repeatable environment with ansible-lint, YAML validation, and helpful CLI tools.
- Keep roles idempotent and well-tagged so they can be re-run safely.
- When adding new roles, prefer defaults → vars → secrets separation: defaults for sane values, inventory vars for site-wide overrides, Vault/secret files for credentials.
- Run `ansible-lint` against `site.yml` before pushing or opening pull requests.
