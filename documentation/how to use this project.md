# How to use this project

## Overview

This living document captures the workflow for operating the Raspberry Pi automation repo. Update it whenever new capabilities (Docker setup, application roles, etc.) land so future you can reproduce the steps quickly.

## Quick start

1. Copy `.env.example` to `.env`:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set the required values (host user/UID/GID, locale, Git identity, editor choice, resource limits, and Ansible vars like `ANSIBLE_USER` / `ANSIBLE_SSH_PRIVATE_KEY_FILE`).

## Launchers

- `./editor-launch.sh` for VS Code/Cursor/Antigravity.
- `./devcontainer-launch.sh` for a CLI shell.
- `./claude-launch.sh` to start Claude Code inside the container.
- `./workspace.sh` to open a tmux workspace on the host (optional).

## SSH agent forwarding

The devcontainer bind-mounts `SSH_AUTH_SOCK`, so the host must have a running
SSH agent before the container starts. Keys stay on the host; only the agent
socket is forwarded.

## Common scripts

- Validate config: `./scripts/validate-env.sh [editor|devcontainer|claude]`
- Clean old devcontainer images: `./scripts/clean-devcontainer-images.sh`
- Sync git remotes (optional): `./scripts/sync-git.sh`

## Project-specific workflow

### Configure Raspberry Pi credentials

### 2.0 Create local inventory from the example

1. Copy the example inventory file and keep the real one out of git:

   ```bash
   cp src/inventory/hosts.ini.example src/inventory/hosts.ini
   ```

### 2.1 Create the cloud-init seed files

1. Copy the example files into the real cloud-init seed paths (keep them out of git):

   ```bash
   cp sd_card_files/system-boot/meta-data.example sd_card_files/system-boot/meta-data
   cp sd_card_files/system-boot/network-config.example sd_card_files/system-boot/network-config
   cp sd_card_files/system-boot/user-data.example sd_card_files/system-boot/user-data
   cp sd_card_files/system-boot/ssh.example sd_card_files/system-boot/ssh
   ```

2. Edit `sd_card_files/system-boot/meta-data` with the desired hostname and instance id.
3. Edit `sd_card_files/system-boot/network-config` to use DHCP (no static IP and no public fallback DNS).
   - Use UniFi DHCP reservations (MAC → fixed IP) for stable addresses.
   - Set the client DNS servers via UniFi DHCP (for example Pi-hole primary/secondary), not in netplan.
4. Edit `sd_card_files/system-boot/user-data` with the correct user name and SSH key.
5. Ensure `sd_card_files/system-boot/ssh` is an empty file (this enables SSH on first boot).

### 2.2 Apply seed files to the SD card

1. Flash the Ubuntu Server image to the SD card (Raspberry Pi Imager or similar).
2. Mount the `system-boot` partition from the freshly flashed SD card.
3. Copy the seed files into the root of the `system-boot` partition:

   ```bash
   cp sd_card_files/system-boot/meta-data /media/<user>/system-boot/
   cp sd_card_files/system-boot/network-config /media/<user>/system-boot/
   cp sd_card_files/system-boot/user-data /media/<user>/system-boot/
   cp sd_card_files/system-boot/ssh /media/<user>/system-boot/
   sync
   ```

4. Eject the SD card safely, insert it into the Pi, and boot. SSH should be ready after the first boot.
5. After the box boots and pulls a DHCP lease, create a DHCP reservation in UniFi (router) so the IP becomes stable (MAC -> fixed IP). Use that reserved IP in inventory (`ansible_host`).

### 2.3 Configure inventory host vars

1. Copy the example host vars file and keep the real one out of git (replace `rpi_box_01` with your host name):

   ```bash
   cp src/inventory/host_vars/rpi_box.example.yml src/inventory/host_vars/rpi_box_01.yml
   ```

2. Edit `src/inventory/host_vars/rpi_box_01.yml` with the correct `ansible_host` and `ansible_port`. The remaining values are read from `.env` via `lookup('env', ...)` so the file can stay minimal and local-only.
3. Add the required `pi_base` variables so the base role can lock down access safely:
   - `pi_base_admin_user` (same as `ansible_user`)
   - `pi_base_admin_ssh_public_key_file` (path to the admin public key on the Ansible control machine)
   - `pi_base_hostname`, `pi_base_timezone`, `pi_base_locale`
4. Add the required `daily_report` variables if you want the daily status email (set them in `.env` or `host_vars`):
   - `daily_report_time`, `daily_report_email`, `daily_report_sender`
   - `daily_report_smtp_host`, `daily_report_smtp_port`, `daily_report_smtp_user`, `daily_report_smtp_password`
   - `daily_report_user`, `daily_report_script_path`, `daily_report_service_name`, `daily_report_msmtp_log_path`
5. Required role variables (no defaults; set in `host_vars` or `group_vars`):
   - `pi_base_disable_resolved_stub`, `pi_base_resolv_conf_target`
   - `pi_base_allow_passwordless_sudo` (set to `true` to create a `NOPASSWD` sudoers drop-in for the admin user)
   - `fail2ban_base_bantime`, `fail2ban_base_findtime`, `fail2ban_base_maxretry`
   - `fail2ban_base_ignoreip`, `fail2ban_base_backend`
   - `time_sync_ntp_servers`, `time_sync_fallback_servers`
   - `log_hygiene_journald_max_use`, `log_hygiene_journald_keep_free`
   - `log_hygiene_journald_max_file_sec`, `log_hygiene_logrotate_rotate`, `log_hygiene_logrotate_frequency`
   - `node_exporter_listen_address` (recommend `127.0.0.1:9100` until Prometheus is set up)
   - `storage_layout_directories` (list of directories with owner/group/mode)
   - `docker_engine_data_root`, `docker_engine_log_max_size`, `docker_engine_log_max_file`
   - `docker_engine_users`, `docker_engine_apt_release` (must match `ansible_distribution_release`; Docker repo OS auto-detects Debian vs Ubuntu, override with `docker_engine_apt_repo_os` if needed)
   - `docker_engine_version`, `docker_engine_compose_version` (set to empty string to install latest)
   - `docker_prune_schedule`, `docker_prune_command`, `docker_prune_service_name`
   - `common_tools_packages`
   - `backup_restic_retention_days`, `backup_restic_retention_weeks`, `backup_restic_retention_months`
   - `backup_restic_timer_schedule`
6. Configure Backup variables (Restic):
   - Set these in `.env` (recommended) or `host_vars`:
     - `BACKUP_RESTIC_REPO` / `backup_restic_repo`
     - `BACKUP_RESTIC_SRC` / `backup_restic_src`
     - `BACKUP_RESTIC_PASSWORD` / `backup_restic_password`
     - `BACKUP_RESTIC_RETENTION_DAYS` / `backup_restic_retention_days`
     - `BACKUP_RESTIC_RETENTION_WEEKS` / `backup_restic_retention_weeks`
     - `BACKUP_RESTIC_RETENTION_MONTHS` / `backup_restic_retention_months`
     - `BACKUP_RESTIC_TIMER_SCHEDULE` / `backup_restic_timer_schedule`
   - Ensure the backup destination is mounted and writable before running the playbook.

### Verify Ansible connectivity

1. From the devcontainer (or any shell with Ansible installed), run:

   ```bash
   cd src
   ansible rpi_box_01 -i inventory/hosts.ini -m ping
   ```

2. You should see `SUCCESS` along with `{"ping": "pong"}`. If the command fails:
   - Confirm the Pi is powered on and reachable at the IP defined in `inventory/hosts.ini`.
   - Re-check the `ansible_user`/SSH key path in `src/inventory/host_vars/rpi_box_01.yml`.
   - Ensure your SSH agent has the corresponding private key loaded (`ssh-add -l`).
3. If you change hostnames in `inventory/hosts.ini`, make sure the filename inside `src/inventory/host_vars/` matches (e.g., `rpi_box_01.yml` for `rpi_box_01`). Use `ansible all --list-hosts` to confirm inventory parsing before running a play.
4. SSH host key checking is enabled by default. If you are bootstrapping a new host
   or rotating keys, update `~/.ssh/known_hosts` on the control machine or set
   `ANSIBLE_HOST_KEY_CHECKING=False` for that session.

### Update the Raspberry Pi base OS

1. Run the base playbook to refresh the apt cache, upgrade all packages, enable
   fail2ban + time sync + log hygiene + node exporter, prepare `/srv`, and
   install Docker Engine + Compose V2:

   ```bash
   cd src
   ansible-playbook playbooks/pi-base.yml
   ```

2. The play targets the `[raspberry_pi_boxes]` inventory group. Limit to a single host (e.g., `-l rpi_box_01`) if you add more Pis later.
3. Docker packages are installed from Docker's apt repo. If a transient repo mismatch occurs (for example, a containerd.io candidate is missing), the playbook will fall back to the next available version and you can re-run later to converge.
4. Optional: configure and apply “service” roles that require extra variables (SMTP/restic):

   ```bash
   cd src
   ansible-playbook playbooks/pi-services.yml -l rpi_box_01
   ```

5. Optional: run the Docker smoke test (pulls `traefik/whoami`, requires outbound registry access):

   ```bash
   cd src
   ansible-playbook playbooks/pi-smoke.yml -l rpi_box_01
   ```

6. Optional: run a full apply (base + services + smoke):

   ```bash
   cd src
   ansible-playbook playbooks/pi-full.yml -l rpi_box_01
   ```

7. After the base playbook completes, run the verification playbook to confirm
   services and config files are in place:

   ```bash
   cd src
   ansible-playbook playbooks/deployment-verify.yml -l rpi_box_01
   ```

### Upgrade to the latest Ubuntu LTS (manual playbook)

1. The daily report email includes an "LTS Upgrade Check" line that mirrors `do-release-upgrade -c`. When it shows a new release, run the manual upgrade playbook:

   ```bash
   cd src
   ansible-playbook playbooks/ubuntu-lts-upgrade.yml -l rpi_box_01 -e lts_upgrade_confirm=true
   ```

2. Expect the SSH session to disconnect during the upgrade and for the host to reboot. Reconnect once it comes back.

As new functionality (e.g., OS hardening, Docker install, application deployments) is added, document the invocation steps and required variables here so end-to-end usage stays discoverable.
