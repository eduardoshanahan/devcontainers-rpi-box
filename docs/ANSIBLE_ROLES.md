# Ansible Roles Documentation

## Overview

This project includes six Ansible roles for managing Raspberry Pi systems. Each role is designed to be modular and reusable.

## Role Structure

Each role follows the standard Ansible role structure:

```text
role_name/
├── defaults/
│   └── main.yml      # Default variables
├── vars/
│   └── main.yml      # Role variables
├── tasks/
│   └── main.yml      # Main tasks
├── handlers/
│   └── main.yml      # Handlers
└── templates/        # Jinja2 templates (if needed)
```

## Roles

### common

**Purpose**: Basic system setup and baseline package installation

**Tasks**:

- Updates APT cache
- Sets system timezone (if configured)
- Installs baseline packages: htop, vim, git, curl, tmux, net-tools, python3-pip
- Ensures locales package is present

**Variables**:

- `timezone` (optional) - System timezone (e.g., "America/New_York")
- `apt_cache_valid_time` (default: 3600) - APT cache validity in seconds

**Usage**:

```yaml
- hosts: rpi
  roles:
    - role: common
      vars:
        timezone: "Europe/London"
```

**Tags**: None (runs by default)

---

### common_tools

**Purpose**: Install administration and monitoring tools

**Tasks**:

- Installs common tools: htop, iotop, iftop, nload, dnsutils, nmap, tcpdump, net-tools, usbutils
- Optionally installs Prometheus node_exporter
- Configures sudoers for privileged commands
- Creates bash aliases for common tools

**Default Variables**:

```yaml
common_tools_packages:
  - htop
  - iotop
  - iftop
  - nload
  - dnsutils
  - nmap
  - tcpdump
  - net-tools
  - usbutils

common_tools_privileged_user: "{{ ansible_user }}"

common_tools_privileged_commands:
  - /usr/sbin/iotop
  - /usr/sbin/tcpdump
  - /usr/sbin/iftop

common_tools_aliases:
  iotop: "sudo /usr/sbin/iotop"
  top: "htop"
  ls: "ls --color=auto"
  iftop: "sudo /usr/sbin/iftop"

common_tools_node_exporter_install: true
common_tools_node_exporter_listen_address: "0.0.0.0:9100"
```

**Features**:

- Node exporter for Prometheus monitoring (optional)
- Sudo configuration for tools requiring root access
- Shell aliases for easier command execution

**Usage**:

```yaml
- hosts: rpi
  roles:
    - role: common_tools
      vars:
        common_tools_node_exporter_install: true
        common_tools_node_exporter_listen_address: "127.0.0.1:9100"
```

**Tags**: `common_tools`, `node_exporter`, `monitoring`

**Handlers**:

- `Restart node_exporter` - Restarts Prometheus node_exporter service

---

### daily_report

**Purpose**: Automated daily system status reports via email

**Tasks**:

- Installs msmtp and mailx
- Configures msmtp for email sending (Zoho SMTP)
- Deploys daily report script
- Creates systemd service and timer
- Enables and starts the timer

**Default Variables**:

```yaml
daily_report_time: "07:00"
daily_report_email: "user@example.com"
daily_report_sender: "user@example.com"
daily_report_script_path: "/usr/local/bin/daily-report.sh"
daily_report_service_name: "daily-report"
daily_report_smtp_user: "user@example.com"
daily_report_smtp_password: "CHANGE_ME_IN_LOCAL_SECRETS"
daily_report_user: "{{ ansible_user }}"
```

**Report Contents**:

- Hostname and date
- System uptime
- Load average
- CPU temperature
- Disk usage (root and all mounts)
- Memory usage
- Network information
- Failed SSH login attempts (last 24h)
- Top CPU processes
- Docker container status

**Templates**:

- `daily-report.sh.j2` - Report generation script
- `daily-report.service.j2` - Systemd service unit
- `daily-report.timer.j2` - Systemd timer unit
- `msmtprc.j2` - msmtp configuration
- `msmtp.aliases.j2` - Email aliases

**Usage**:

```yaml
- hosts: rpi
  roles:
    - role: daily_report
      vars:
        daily_report_time: "08:00"
        daily_report_email: "admin@example.com"
        daily_report_sender: "rpi@example.com"
        daily_report_smtp_user: "rpi@example.com"
        daily_report_smtp_password: "{{ vault_daily_report_password }}"
```

**Security Note**: Store SMTP password in Ansible Vault or `local-secrets.yml`

**Tags**: `daily_report`

**Handlers**:

- `Restart daily report timer` - Restarts the systemd timer

---

### docker

**Purpose**: Install and configure Docker engine

**Tasks**:

- Installs docker.io and docker-compose
- Ensures Docker service is enabled and running
- Adds user to docker group
- Enables IPv4 forwarding (useful for Pi-hole/DNS)

**Usage**:

```yaml
- hosts: rpi
  roles:
    - role: docker
```

**Tags**: None (runs by default)

**Note**: User must log out and back in for docker group membership to take effect, or use `newgrp docker`

---

### system_update

**Purpose**: Manual system updates with automatic reboot if required

**Tasks**:

- Updates APT cache
- Upgrades all packages (dist-upgrade)
- Checks if reboot is required
- Reboots system if kernel/security updates require it

**Variables**:

- `apt_cache_valid_time` (default: 3600) - APT cache validity in seconds

**Usage**:

```yaml
- hosts: rpi
  roles:
    - role: system_update
```

**Tags**: `update`

**Note**: This role will reboot the system if required. Ensure playbook can handle reconnection.

---

### unattended_upgrades

**Purpose**: Configure automatic security and update installations

**Tasks**:

- Installs unattended-upgrades and apt-listchanges
- Enables automatic package list updates
- Enables automatic package downloads
- Configures automatic cleanup (7 days)
- Configures automatic upgrades for security and updates
- Enables automatic reboot at 03:30

**Configuration**:

- Updates package lists daily
- Downloads upgradeable packages daily
- Cleans package cache every 7 days
- Installs security and regular updates automatically
- Reboots automatically at 03:30 if required (even with users logged in)

**Usage**:

```yaml
- hosts: rpi
  roles:
    - role: unattended_upgrades
```

**Tags**: None (runs by default)

**Warning**: Automatic reboots may interrupt services. Consider scheduling during maintenance windows.

---

## Playbook Structure

The main playbook (`src/site.yml`) orchestrates all roles:

```yaml
---
- name: Configure Raspberry Pi systems
  hosts: rpi
  become: true
  roles:
    - common
    - common_tools
    - docker
    - daily_report
    - unattended_upgrades
```

## Running Playbooks

### Basic Execution

```bash
cd src
ansible-playbook site.yml
```

### With Tags

```bash
# Run only common_tools role
ansible-playbook site.yml --tags common_tools

# Run only update role
ansible-playbook site.yml --tags update

# Skip daily_report
ansible-playbook site.yml --skip-tags daily_report
```

### With Limit

```bash
# Run on specific host
ansible-playbook site.yml --limit rpi1
```

### With Check Mode

```bash
# Dry run
ansible-playbook site.yml --check
```

## Inventory Configuration

### Hosts File

Create `src/inventory/hosts.yml`:

```yaml
all:
  children:
    rpi:
      hosts:
        rpi1:
          ansible_host: 192.168.1.100
          ansible_user: pi
        rpi2:
          ansible_host: 192.168.1.101
          ansible_user: pi
```

### Group Variables

Group variables in `src/inventory/group_vars/rpi.yml` apply to all Raspberry Pi hosts.

### Secrets

Store sensitive data in `src/inventory/group_vars/all/local-secrets.yml` (not in version control).

## Best Practices

1. Use Ansible Vault for sensitive data
2. Test playbooks with `--check` first
3. Use tags to run specific roles
4. Keep inventory files out of version control
5. Document custom variables in role defaults
6. Use handlers for service restarts
7. Test on one host before applying to all
