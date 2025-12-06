# Raspberry Pi 4 – Ubuntu 22.04 Server Bootstrap  

## Static IP + SSH Key Only + Ansible Ready

This document describes how to bootstrap a Raspberry Pi 4 running **Ubuntu 22.04.5 Server (preinstalled image)** using **cloud-init**, with:

- A **static IPv4 address**: `192.0.2.58`
- Hostname: **`rpi-headless`**
- **SSH enabled**
- **Key-based authentication only** (no password logins)
- A non-root user: **`homelabadmin`** with passwordless `sudo`
- Ready to be managed by Ansible from your devcontainer

---

## 1. Prerequisites

- Hardware:
  - Raspberry Pi 4
  - SD card (e.g. 32 GB)
  - Ethernet connection to your LAN
- Network assumptions:
  - Static IP: `192.0.2.58`
  - Gateway: `192.0.2.1`
  - DNS: `192.0.2.1` and `1.1.1.1` (adjust if needed)
- Workstation:
  - Linux (or WSL) with `ssh`, `ssh-keygen`
  - Ability to mount the SD card partitions
- Ansible project:
  - Lives in `/workspace/src` inside a devcontainer
  - Contains `ansible.cfg`, `inventory/hosts.yml`, `site.yml`, `roles/…`

---

## 2. Create a dedicated SSH key for the home lab

On your workstation (not in the devcontainer):

```bash
ssh-keygen -t ed25519 -C "homelab-lan"
```

When prompted for the file, use:

```text
~/.ssh/homelab-rpi
```

You should now have:

- `~/.ssh/homelab-rpi`
- `~/.ssh/homelab-rpi.pub`

Public key used in this guide:

```bash
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAExampleKeyStringGoesHere====== homelab-lan
```

---

## 3. Flash Ubuntu 22.04.5 Server image to the SD card

Flash using Raspberry Pi Imager or `dd`. After flashing, reinsert the SD card.

You should see:

- `/media/$USER/system-boot`
- `/media/$USER/writable`

We only modify `system-boot`.

---

## 4. Configure cloud-init – `user-data`

Replace `/media/$USER/system-boot/user-data` with:

```yaml
#cloud-config
hostname: rpi-headless
manage_etc_hosts: true

users:
  - name: homelabadmin
    gecos: "Raspberry Pi Admin"
    groups: [users, adm, dialout, audio, netdev, video, plugdev, cdrom, games, input, gpio, spi, i2c, render, sudo]
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: true
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAExampleKeyStringGoesHere====== homelab-lan

ssh_pwauth: false
disable_root: true

timezone: UTC

write_files:
  - path: /etc/ssh/sshd_config.d/99-disable-passwords.conf
    owner: root:root
    permissions: '0644'
    content: |
      PasswordAuthentication no
      ChallengeResponseAuthentication no
      UsePAM yes

runcmd:
  - [ systemctl, restart, ssh ]
```

---

## 5. Configure cloud-init – `meta-data`

```yaml
instance-id: rpi-headless
local-hostname: rpi-headless
```

---

## 6. Configure static IP – `network-config`

Replace `/media/$USER/system-boot/network-config` with:

```yaml
version: 2
ethernets:
  eth0:
    dhcp4: false
    addresses:
      - 192.0.2.58/24
    gateway4: 192.0.2.1
    nameservers:
      addresses: [192.0.2.1, 1.1.1.1]
    optional: true
```

---

## 7. Enable SSH

```bash
touch /media/$USER/system-boot/ssh
```

---

## 8. Boot and SSH test

```bash
ssh -i ~/.ssh/homelab-rpi homelabadmin@192.0.2.58
```

Prompt should be:

```bash
homelabadmin@rpi-headless:~$
```

---

## 9. Ansible inventory setup

```yaml
all:
  children:
    rpi:
      hosts:
        rpi-headless:
          ansible_host: 192.0.2.58
          ansible_user: homelabadmin
          ansible_ssh_private_key_file: ~/.ssh/homelab-rpi
          ansible_ssh_common_args: "-o IdentitiesOnly=yes"
```

---

## 10. Test Ansible

```bash
ansible rpi -m ping
```

Expected:

```bash
"ping": "pong"
```

---

## 11. Apply full configuration

```bash
ansible-playbook site.yml
```

---

## 12. Rebuild checklist

1. Flash SD card  
2. Edit `user-data`, `meta-data`, `network-config`  
3. Add empty `ssh` file  
4. Boot Pi  
5. SSH with key  
6. Run Ansible  



``` bash
ansible-playbook site.yml -k -K
```

```bash
ansible rpi -m ping -k
```

```bash
ssh -o PubkeyAuthentication=no homelabadmin@192.0.2.58
```
