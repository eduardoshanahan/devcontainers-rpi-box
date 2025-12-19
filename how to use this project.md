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

The devcontainer loads these variables from `.env`, so keeping them here makes the configuration obvious and versioned via `.env.example`.

## 1. Prerequisites

- Run inside the provided devcontainer (or any shell with the repo checked out) so Ansible tooling and environment variables are pre-configured.
- Ensure the SSH key that can reach the Pi is accessible on the host; the devcontainer forwards your host SSH agent so keys never need to be copied into the repo.

## 2. Configure Raspberry Pi Credentials

### 2.1 Create the cloud-init seed files

1. Copy the example files into the real cloud-init seed paths (keep them out of git):

   ```bash
   cp non_comitted_files/system-boot/meta-data.example non_comitted_files/system-boot/meta-data
   cp non_comitted_files/system-boot/network-config.example non_comitted_files/system-boot/network-config
   cp non_comitted_files/system-boot/user-data.example non_comitted_files/system-boot/user-data
   cp non_comitted_files/system-boot/ssh.example non_comitted_files/system-boot/ssh
   ```

2. Edit `non_comitted_files/system-boot/meta-data` with the desired hostname and instance id.
3. Edit `non_comitted_files/system-boot/network-config` with the correct static IP and DNS.
4. Edit `non_comitted_files/system-boot/user-data` with the correct user name and SSH key.
5. Ensure `non_comitted_files/system-boot/ssh` is an empty file (this enables SSH on first boot).

### 2.2 Apply seed files to the SD card

1. Flash the Ubuntu Server image to the SD card (Raspberry Pi Imager or similar).
2. Mount the `system-boot` partition from the freshly flashed SD card.
3. Copy the seed files into the root of the `system-boot` partition:

   ```bash
   cp non_comitted_files/system-boot/meta-data /media/<user>/system-boot/
   cp non_comitted_files/system-boot/network-config /media/<user>/system-boot/
   cp non_comitted_files/system-boot/user-data /media/<user>/system-boot/
   cp non_comitted_files/system-boot/ssh /media/<user>/system-boot/
   sync
   ```

4. Eject the SD card safely, insert it into the Pi, and boot. SSH should be ready after the first boot.

1. Copy the example host vars file and keep the real one out of git (replace `rpi_box_01` with your host name):

   ```bash
   cp src/inventory/host_vars/rpi_box.example.yml src/inventory/host_vars/rpi_box_01.yml
   ```

2. Edit `src/inventory/host_vars/rpi_box_01.yml` with the correct `ansible_host`, `ansible_port`, `ansible_user`, and `ansible_ssh_private_key_file`. Because of the `.gitignore` in that directory, this file stays local-only.
3. Add the required `pi_base` variables so the base role can lock down access safely:
   - `pi_base_admin_user` (same as `ansible_user`)
   - `pi_base_admin_ssh_public_key` (public key for the admin user)
   - `pi_base_hostname`, `pi_base_timezone`, `pi_base_locale`
4. Add the required `daily_report` variables if you want the daily status email:
   - `daily_report_time`, `daily_report_email`, `daily_report_sender`
   - `daily_report_smtp_host`, `daily_report_smtp_port`, `daily_report_smtp_user`, `daily_report_smtp_password`
   - `daily_report_user`, `daily_report_script_path`, `daily_report_service_name`, `daily_report_msmtp_log_path`
5. Optional overrides for baseline hardening and time sync:
   - `fail2ban_base_bantime`, `fail2ban_base_findtime`, `fail2ban_base_maxretry`
   - `fail2ban_base_ignoreip`, `fail2ban_base_backend`
   - `time_sync_ntp_servers`, `time_sync_fallback_servers`
   - `log_hygiene_journald_max_use`, `log_hygiene_journald_keep_free`
   - `log_hygiene_journald_max_file_sec`, `log_hygiene_logrotate_rotate`
   - `log_hygiene_logrotate_frequency`
   - `node_exporter_listen_address`
   - `storage_layout_directories` (list of directories with owner/group/mode)
   - `docker_engine_data_root`, `docker_engine_log_max_size`, `docker_engine_log_max_file`
   - `docker_engine_users`

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

## 4. Update the Raspberry Pi Base OS

1. Run the base playbook to refresh the apt cache, upgrade all packages, enable
   fail2ban + time sync + log hygiene + node exporter, prepare `/srv`, and
   install Docker Engine + Compose V2:

   ```bash
   cd src
   ansible-playbook playbooks/pi-base.yml
   ```

2. The play targets the `[raspberry_pi]` inventory group. Limit to a single host (e.g., `-l rpi_box_01`) if you add more Pis later.

As new functionality (e.g., OS hardening, Docker install, application deployments) is added, document the invocation steps and required variables here so end-to-end usage stays discoverable.
