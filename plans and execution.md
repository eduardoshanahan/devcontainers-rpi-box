# Plans and Execution

This document tracks what has been executed so far and a lightweight roadmap for next steps.

## What We Did So Far

- Reviewed `src/` and clarified the Ansible layout (roles, playbooks, inventory, host_vars).
- Added base hardening and identity tasks to `pi_base`:
  - Create/admin user with SSH key auth and passwordless sudo.
  - Disable SSH password auth and root login.
  - Set hostname, timezone, and locale.
- Required `pi_base_*` variables to be explicitly defined (no defaults).
- Updated host vars to derive:
  - `pi_base_admin_user` from `ansible_user`.
  - `pi_base_admin_ssh_public_key` from the `.pub` key next to `ansible_ssh_private_key_file`.
- Set timezone to `Europe/Dublin` and locale to `en_IE.UTF-8`.
- Adjusted hostname to a DNS-safe value (`rpi-box-01`) to avoid hostnamectl failures.
- Updated `how to use this project.md` with required `pi_base_*` variables.
- Updated `src/inventory/host_vars/rpi_box.example.yml` to be a complete example.
- Ran `ansible-playbook playbooks/pi-base.yml` successfully after hostname fix.
- Added unattended security upgrades via a dedicated role and wired it into the base playbook.
- Added a minimal UFW role (deny incoming, allow outgoing, allow SSH) and wired it into the base playbook.
- Added a `common_tools` role with baseline CLI utilities (nano, htop, jq, etc.) and wired it into the base playbook.
- Added a `how to test.md` checklist with validation commands for base, UFW, SSH hardening, and unattended upgrades.
- Added a `daily_report` role for msmtp-based daily status emails (script + systemd timer).
- Added a `fail2ban_base` role to protect SSH with a standard jail.
- Added a `time_sync` role to configure and enable systemd-timesyncd.
- Added a `log_hygiene` role to cap journald disk usage and manage log rotation.
- Added a `node_exporter` role for basic host metrics.
- Added a `storage_layout` role to enforce `/srv` conventions for apps and Docker data.
- Extended `scripts/ansible-smoke.sh` with idempotence checks and service validation.
- Normalized fail2ban role variables to the `fail2ban_base_` prefix for linting.
- Expanded daily report output with fail2ban, time sync, journald, and logrotate data.
- Expanded `common_tools` with vnstat, needrestart, ncdu, tcpdump, lsof, and strace.

## Next Minimal Steps (Candidate Options)

Pick one of these as the next small, safe increment:

1. **SSH + Access polish**
   - Ensure `/etc/ssh/sshd_config` includes any additional hardening (e.g., `AllowUsers`).
   - Optionally add a fail2ban role (if desired).

2. **Unattended security updates**
   - Add a small role to enable unattended upgrades and security patches.

3. **Baseline tooling (non-Docker)**
   - Expand tooling or make it configurable per host group.

4. **Network hygiene**
   - Add optional allowlist rules for future services (HTTP/HTTPS, metrics).

## Longer-Term (After Base Is Stable)

- Docker install role (upstream Docker CE, compose plugin, daemon config).
- Data directories in `/srv/docker` with secure permissions.
- First application (e.g., Pi-hole) as a compose stack.
- Add smoke tests / ansible lint checks for playbooks and roles.
