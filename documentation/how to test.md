# How to Test

This document lists lightweight validation checks for the Raspberry Pi base setup. Add to it as new capabilities are introduced.

## Base Playbook

- Re-run for idempotency:

  ```bash
  cd src
  ansible-playbook playbooks/pi-base.yml -l rpi_box_01
  ```

## Deployment Verification

- Run the verification playbook (requires sudo, use `-b` if running ad-hoc):

  ```bash
  cd src
  ansible-playbook playbooks/deployment-verify.yml -l rpi_box_01
  ```

## Smoke Script

- Run the smoke tests against all Raspberry Pi hosts:

  ```bash
  ./scripts/ansible-smoke.sh src/playbooks/pi-base.yml src/inventory/hosts.ini
  ```

  To run the smoke test against a single host, pass a limit as the third argument:

  ```bash
  ./scripts/ansible-smoke.sh src/playbooks/pi-base.yml src/inventory/hosts.ini rpi_box_03
  ```

## Lint Only

- Run only `ansible-lint` (no playbook execution):

  ```bash
  ./scripts/ansible-lint.sh src/playbooks/pi-base.yml
  ```

## SSH Hardening

- Confirm SSH settings (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m shell -a "sshd -T | egrep 'passwordauthentication|permitrootlogin|pubkeyauthentication'" -b
  ```

## Unattended Upgrades

- Confirm config files exist:

  ```bash
  ansible rpi_box_01 -m command -a "ls -l /etc/apt/apt.conf.d/20auto-upgrades /etc/apt/apt.conf.d/50unattended-upgrades"
  ```

## Daily Report

- Check the timer status (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl status daily-report.timer --no-pager" -b
  ```

- Trigger a one-off report run (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl start daily-report.service" -b
  ```

## Backup (Restic)

- Check the timer and last run status (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl status rpi-backup.timer --no-pager" -b
  ansible rpi_box_01 -m command -a "systemctl status rpi-backup.service --no-pager" -b
  ```

- Review recent backup logs (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "journalctl -u rpi-backup.service -n 20 --no-pager" -b
  ```

## Fail2ban

- Check the service status (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl status fail2ban --no-pager" -b
  ```

## Time Sync

- Confirm timesyncd is active (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl status systemd-timesyncd --no-pager" -b
  ```

## Log Hygiene

- Confirm journald limits are configured (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "cat /etc/systemd/journald.conf.d/99-log-hygiene.conf" -b
  ```

- Confirm logrotate policy is present (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "cat /etc/logrotate.d/rpi-base" -b
  ```

## Node Exporter

- Check the service status (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl status prometheus-node-exporter --no-pager" -b
  ```

## Storage Layout

- Confirm baseline directories exist (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "ls -ld /srv/apps /srv/docker" -b
  ```

## Docker Engine

- Confirm Docker is enabled and Compose V2 is available (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl status docker --no-pager" -b
  ansible rpi_box_01 -m command -a "docker compose version" -b
  ```

- Confirm installed versions (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "docker --version" -b
  ansible rpi_box_01 -m command -a "containerd --version" -b
  ```

## Docker Smoke Test

- The `docker_smoke_test` role requires the Docker service running and the
  Compose V2 plugin (`docker-compose-plugin`) installed. Validate both before
  running the playbook (requires sudo, use `-b`):

  ```bash
  ansible rpi_box_01 -m command -a "systemctl status docker --no-pager" -b
  ansible rpi_box_01 -m command -a "docker compose version" -b
  ```
