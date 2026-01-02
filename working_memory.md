# Raspberry Pi 4 – Ubuntu 22.04 Server Bootstrap  

## Static IP + SSH Key Only + Ansible Ready

This document describes how to bootstrap a Raspberry Pi 4 running **Ubuntu 22.04.5 Server (preinstalled image)** using **cloud-init**, with:

- A **static IPv4 address**: `192.168.1.58`
- Hostname: **`rpi-box-01`**
- **SSH enabled**
- **Key-based authentication only** (no password logins)
- A non-root user: **`eduardo`** with passwordless `sudo`
- Ready to be managed by Ansible from your devcontainer

---

## 1. Prerequisites

- Hardware:
  - Raspberry Pi 4
  - SD card (e.g. 32 GB)
  - Ethernet connection to your LAN
- Network assumptions:
  - Static IP: `192.168.1.58`
  - Gateway: `192.168.1.1`
  - DNS: `192.168.1.1` and `1.1.1.1` (adjust if needed)
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
ssh-keygen -t ed25519 -C "eduardo-hhlab-lan"
```

When prompted for the file, use:

```text
~/.ssh/eduardo-hhlab
```

You should now have:

- `~/.ssh/eduardo-hhlab`
- `~/.ssh/eduardo-hhlab.pub`

Public key used in this guide:

```bash
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtx2I1dKO0ZUptTkHMBR6A+SrtaJR0mPUX5GRmNt1aF eduardo-hhlab-lan
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
hostname: rpi-box-01
manage_etc_hosts: true

users:
  - name: eduardo
    gecos: "Eduardo"
    groups: [users, adm, dialout, audio, netdev, video, plugdev, cdrom, games, input, gpio, spi, i2c, render, sudo]
    shell: /bin/bash
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: true
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtx2I1dKO0ZUptTkHMBR6A+SrtaJR0mPUX5GRmNt1aF eduardo-hhlab-lan

ssh_pwauth: false
disable_root: true

timezone: Europe/Dublin

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
instance-id: rpi-box-01
local-hostname: rpi-box-01
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
      - 192.168.1.58/24
    gateway4: 192.168.1.1
    nameservers:
      addresses: [192.168.1.1, 1.1.1.1]
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
ssh -i ~/.ssh/eduardo-hhlab eduardo@192.168.1.58
```

Prompt should be:

```bash
eduardo@rpi-box-01:~$
```

---

## 9. Ansible inventory setup

```yaml
all:
  children:
    rpi:
      hosts:
        rpi-box-01:
          ansible_host: 192.168.1.58
          ansible_user: eduardo
          ansible_ssh_private_key_file: ~/.ssh/eduardo-hhlab
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
ssh -o PubkeyAuthentication=no eduardo@192.168.1.58
```
