# How to Use This Project

This living document captures the workflow for operating the Raspberry Pi automation repo. Update it whenever new capabilities (Docker setup, application roles, etc.) land so future you can reproduce the steps quickly.

## 0. Configure the Devcontainer Environment

1. Copy the root `.env.example` to `.env` so the devcontainer picks up the required environment variables:

   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and set your host username/UID/GID plus the Ansible-related paths:
   - `ANSIBLE_CONFIG=/workspace/src/ansible.cfg`
   - `ANSIBLE_INVENTORY=/workspace/src/inventory/hosts.ini`
   - `ANSIBLE_COLLECTIONS_PATH=/workspace/src/collections:/home/<your-username>/.ansible/collections`
   - `ANSIBLE_ROLES_PATH=/workspace/src/roles`
   - `ANSIBLE_USER`, `ANSIBLE_SSH_PRIVATE_KEY_FILE`
  - `PI_BASE_ADMIN_USER`, `PI_BASE_ADMIN_SSH_PUBLIC_KEY_FILE`, `PI_BASE_DISABLE_RESOLVED_STUB`
  - `DAILY_REPORT_EMAIL`, `DAILY_REPORT_SENDER`, `DAILY_REPORT_SMTP_HOST`, `DAILY_REPORT_SMTP_PORT`
  - `DAILY_REPORT_SMTP_USER`, `DAILY_REPORT_SMTP_PASSWORD`, `DAILY_REPORT_USER`
  - `BACKUP_RESTIC_REPO`, `BACKUP_RESTIC_SRC`, `BACKUP_RESTIC_PASSWORD`
  - `BACKUP_RESTIC_RETENTION_DAYS`, `BACKUP_RESTIC_RETENTION_WEEKS`, `BACKUP_RESTIC_RETENTION_MONTHS`
  - `BACKUP_RESTIC_TIMER_SCHEDULE`

The devcontainer loads these variables from `.env`, so keeping them here makes the configuration obvious and versioned via `.env.example`.

## 1. Prerequisites

- Run inside the provided devcontainer (or any shell with the repo checked out) so Ansible tooling and environment variables are pre-configured.
- Launch options:
  - `./editor-launch.sh` for VS Code/Cursor/Antigravity.
  - `./devcontainer-launch.sh` for a CLI shell.
  - `./claude-launch.sh` to start Claude Code inside the container.
- Ensure the SSH key that can reach the Pi is accessible on the host; the devcontainer forwards your host SSH agent so keys never need to be copied into the repo.
  - To rebuild the container from the launcher, use `REBUILD_CONTAINER=1` (e.g., `REBUILD_CONTAINER=1 ./claude-launch.sh`).
  - To keep the container running after exit, use `KEEP_CONTAINER=1`.
  - To skip Claude install, set `SKIP_CLAUDE_INSTALL=1` before launching (Claude install runs in post-create).

## 2. Configure Raspberry Pi Credentials

### 2.1 Create the cloud-init seed files

1. Copy the example files into the real cloud-init seed paths (keep them out of git):

   ```bash
   cp sd_card_files/system-boot/meta-data.example sd_card_files/system-boot/meta-data
   cp sd_card_files/system-boot/network-config.example sd_card_files/system-boot/network-config
   cp sd_card_files/system-boot/user-data.example sd_card_files/system-boot/user-data
   cp sd_card_files/system-boot/ssh.example sd_card_files/system-boot/ssh
   ```

2. Edit `sd_card_files/system-boot/meta-data` with the desired hostname and instance id.
3. Edit `sd_card_files/system-boot/network-config` with the correct static IP and DNS.
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

### 2.3 Configure inventory host vars

1. Copy the example host vars file and keep the real one out of git (replace `rpi_box_01` with your host name):

   ```bash
   cp src/inventory/host_vars/rpi_box.example.yml src/inventory/host_vars/rpi_box_01.yml
   ```

2. Edit `src/inventory/host_vars/rpi_box_01.yml` with the correct `ansible_host` and `ansible_port`. The remaining values are read from `.env` via `lookup('env', ...)` so the file can stay minimal and local-only.
3. Add the required `pi_base` variables so the base role can lock down access safely:
   - `pi_base_admin_user` (same as `ansible_user`)
   - `pi_base_admin_ssh_public_key_file` (path to the admin public key)
   - `pi_base_hostname`, `pi_base_timezone`, `pi_base_locale`
4. Add the required `daily_report` variables if you want the daily status email (set them in `.env` or `host_vars`):
   - `daily_report_time`, `daily_report_email`, `daily_report_sender`
   - `daily_report_smtp_host`, `daily_report_smtp_port`, `daily_report_smtp_user`, `daily_report_smtp_password`
   - `daily_report_user`, `daily_report_script_path`, `daily_report_service_name`, `daily_report_msmtp_log_path`
5. Required role variables (no defaults; set in `host_vars` or `group_vars`):
   - `pi_base_disable_resolved_stub`, `pi_base_resolv_conf_target`
   - `fail2ban_base_bantime`, `fail2ban_base_findtime`, `fail2ban_base_maxretry`
   - `fail2ban_base_ignoreip`, `fail2ban_base_backend`
   - `time_sync_ntp_servers`, `time_sync_fallback_servers`
   - `log_hygiene_journald_max_use`, `log_hygiene_journald_keep_free`
   - `log_hygiene_journald_max_file_sec`, `log_hygiene_logrotate_rotate`, `log_hygiene_logrotate_frequency`
   - `node_exporter_listen_address`
   - `storage_layout_directories` (list of directories with owner/group/mode)
   - `docker_engine_data_root`, `docker_engine_log_max_size`, `docker_engine_log_max_file`
   - `docker_engine_users`, `docker_engine_apt_release`
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

## 3. Verify Ansible Connectivity

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

## 4. Update the Raspberry Pi Base OS

1. Run the base playbook to refresh the apt cache, upgrade all packages, enable
   fail2ban + time sync + log hygiene + node exporter, prepare `/srv`, and
   install Docker Engine + Compose V2:

   ```bash
   cd src
   ansible-playbook playbooks/pi-base.yml
   ```

2. The play targets the `[raspberry_pi_boxes]` inventory group. Limit to a single host (e.g., `-l rpi_box_01`) if you add more Pis later.
3. Docker packages are installed from Docker's apt repo. If a transient repo mismatch occurs (for example, a containerd.io candidate is missing), the playbook will fall back to the next available version and you can re-run later to converge.
4. The `docker_smoke_test` role requires the Docker service running and the
   Compose V2 plugin (`docker-compose-plugin`) installed. Confirm both before
   running if you are applying roles individually.
5. After the base playbook completes, run the verification playbook to confirm
   services and config files are in place:

   ```bash
   cd src
   ansible-playbook playbooks/deployment-verify.yml -l rpi_box_01
   ```

## 5. Upgrade to the latest Ubuntu LTS (manual playbook)

1. The daily report email includes an "LTS Upgrade Check" line that mirrors `do-release-upgrade -c`. When it shows a new release, run the manual upgrade playbook:

   ```bash
   cd src
   ansible-playbook playbooks/ubuntu-lts-upgrade.yml -l rpi_box_01 -e lts_upgrade_confirm=true
   ```

2. Expect the SSH session to disconnect during the upgrade and for the host to reboot. Reconnect once it comes back.

As new functionality (e.g., OS hardening, Docker install, application deployments) is added, document the invocation steps and required variables here so end-to-end usage stays discoverable.
