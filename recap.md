# Recap

## 2025-12-19

- Added `fail2ban_base` role (sshd jail + defaults) and wired it into `pi-base`.
- Added `time_sync` role for systemd-timesyncd configuration and enablement.
- Added `log_hygiene` role for journald retention and logrotate rules.
- Added `node_exporter` role for basic host metrics.
- Added `storage_layout` role to create `/srv/apps` and `/srv/docker`.
- Extended `scripts/ansible-smoke.sh` to validate fail2ban, timesyncd, log hygiene, node exporter, and storage layout.
- Renamed fail2ban role variables to the `fail2ban_base_` prefix for linting.
- Expanded the daily report to include fail2ban, time sync, journald usage, and logrotate status.
- Extended `common_tools` with vnstat, needrestart, ncdu, tcpdump, lsof, and strace.

## 2025-12-18

- Extended `pi_base` with admin access hardening (SSH key auth, passwordless sudo, disable password auth + root login) plus hostname/timezone/locale configuration.
- Enforced explicit `pi_base_*` variables (no defaults) and set host-specific values in `host_vars`.
- Added unattended upgrades role and wired it into the base playbook.
- Added UFW baseline role (deny incoming, allow outgoing, allow SSH).
- Added a common tools role (nano, curl, git, tmux, htop, jq, rsync, etc.).
- Added a daily report role (msmtp + systemd timer + report script) and documented required SMTP variables.
- Updated docs:
  - `how to use this project.md`
  - `how to test.md`
  - `plans and execution.md`
- Updated host_vars example and live host vars to reflect new required variables.
