# Development Workflow

## Getting Started

### Initial Setup

1. **Clone the repository**:

```bash
git clone <repository-url>
cd devcontainers-rpi
```

1. **Create environment configuration**:

```bash
cp .devcontainer/config/.env.example .devcontainer/config/.env
# Edit .devcontainer/config/.env with your values
```

1. **Launch the DevContainer**:

```bash
./launch.sh
```

. **Wait for container to build and start**

1. **Verify Ansible installation**:

```bash
cd src
./test-ansible.sh
```

---

## Workflow

### 1. Creating a New Ansible Role

1. **Create role structure**:

```bash
cd src/roles
ansible-galaxy init my_new_role
```

1. **Define defaults**:

Edit `my_new_role/defaults/main.yml`:

```yaml
---
my_new_role_variable: "default_value"
```

1. **Create tasks**:

Edit `my_new_role/tasks/main.yml`:

```yaml
---
- name: Example task
  ansible.builtin.debug:
    msg: "Hello from my_new_role"
```

1. **Add to playbook**:

Edit `src/site.yml`:

```yaml
roles:
  - common
  - my_new_role
```

1. **Test the role**:

```bash
ansible-playbook site.yml --tags my_new_role --check
```

---

### 2. Modifying Existing Roles

1. **Make changes** to role files
1. **Test with check mode**:

```bash
ansible-playbook site.yml --tags role_name --check
```

1. **Test on one host**:

```bash
ansible-playbook site.yml --tags role_name --limit rpi1
```

1. **Apply to all hosts**:

```bash
ansible-playbook site.yml --tags role_name
```

---

### 3. Adding New Variables

1. **Add to role defaults** (`roles/role_name/defaults/main.yml`):

```yaml
---
new_variable: "default_value"
```

1. **Document in role README or comments**
1. **Override in group_vars** if needed:

```yaml
# src/inventory/group_vars/rpi.yml
new_variable: "custom_value"
```

---

### 4. Testing Playbooks

### Check Mode (Dry Run)

```bash
ansible-playbook site.yml --check
```

### Syntax Check

```bash
ansible-playbook site.yml --syntax-check
```

### Linting

```bash
ansible-lint src/site.yml
ansible-lint src/roles/
```

### Test on Single Host

```bash
ansible-playbook site.yml --limit rpi1
```

---

## Git Workflow

### Synchronizing with Remote

```bash
# Normal sync
./scripts/sync_git.sh

# Force pull (overwrites local changes)
FORCE_PULL=true ./scripts/sync_git.sh
```

### Making Changes

1. **Create a branch**:

```bash
git checkout -b feature/my-feature
```

1. **Make changes and commit**:

```bash
git add .
git commit -m "Add new feature"
```

1. **Push to remote**:

```bash
git push -u origin feature/my-feature
```

1. **Create pull request** (if using GitHub/GitLab)

---

## Ansible Best Practices

### 1. Use Tags

Tag your tasks for selective execution:

```yaml
- name: Install package
  ansible.builtin.apt:
    name: package-name
  tags: [packages, common]
```

### 2. Use Handlers

Use handlers for service restarts:

```yaml
# tasks/main.yml
- name: Update config
  ansible.builtin.template:
    src: config.j2
    dest: /etc/config
  notify: Restart service

# handlers/main.yml
- name: Restart service
  ansible.builtin.systemd:
    name: myservice
    state: restarted
```

### 3. Idempotency

Ensure tasks are idempotent (safe to run multiple times):

```yaml
- name: Ensure package is installed
  ansible.builtin.apt:
    name: package-name
    state: present  # present, not latest
```

### 4. Error Handling

Use `failed_when` and `changed_when`:

```yaml
- name: Check service status
  ansible.builtin.command: systemctl status myservice
  register: result
  failed_when: false
  changed_when: false
```

### 5. Variable Naming

Use descriptive, namespaced variable names:

```yaml
# Good
daily_report_email: "admin@example.com"

# Bad
email: "admin@example.com"
```

---

## Debugging

### Verbose Output

```bash
# Level 1 (default)
ansible-playbook site.yml -v

# Level 2
ansible-playbook site.yml -vv

# Level 3 (very verbose)
ansible-playbook site.yml -vvv
```

### Debug Tasks

Add debug tasks:

```yaml
- name: Debug variable
  ansible.builtin.debug:
    var: my_variable

- name: Debug message
  ansible.builtin.debug:
    msg: "Current value: {{ my_variable }}"
```

### Test Connectivity

```bash
ansible all -m ping
```

### Test Specific Module

```bash
ansible rpi -m apt -a "name=htop state=present" --become
```

---

## Container Development

### Rebuilding Container

If you modify Dockerfile or devcontainer.json:

1. **Rebuild in VS Code/Cursor**: Command Palette > "Rebuild Container"
2. **Or manually**:

```bash
docker build -t devcontainers-rpi-box:latest -f .devcontainer/Dockerfile .
```

### Accessing Container Shell

```bash
docker exec -it <container-id> /bin/bash
```

### Viewing Container Logs

```bash
docker logs <container-id>
```

---

## Troubleshooting

### Ansible Connection Issues

1. **Test SSH connection**:

```bash
ssh pi@192.168.1.100
```

1. **Check inventory**:

```bash
ansible-inventory --list
```

1. **Test with verbose output**:

```bash
ansible-playbook site.yml -vvv
```

### Container Issues

1. **Check container status**:

```bash
docker ps -a
```

1. **View container logs**:

```bash
docker logs <container-id>
```

1. **Rebuild container**:

```bash
# Remove old container
docker rm <container-id>

# Rebuild
./launch.sh
```

### Git Sync Failing

1. **Check remote URL**:

```bash
git remote -v
```

1. **Verify credentials**:

```bash
git ls-remote origin
```

1. **Check for local changes**:

```bash
git status
```

---

## Code Quality

### Linting instructions

```bash
# Ansible linting
ansible-lint src/

# YAML linting
yamllint src/
```

### Formatting

Use consistent formatting:

- 2 spaces for YAML indentation
- No tabs
- Trailing newline at end of files

### Documentation

- Document all role variables in `defaults/main.yml`
- Add comments for complex tasks
- Update README when adding features
- Document breaking changes

---

## Release Process

1. **Update version numbers** in relevant files
1. **Update CHANGELOG.md** (if maintained)
1. **Test all playbooks**:

```bash
ansible-playbook site.yml --check
ansible-lint src/
```

1. **Commit and tag**:

```bash
git add .
git commit -m "Release v1.0.0"
git tag v1.0.0
git push origin master --tags
```

---

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Lint Rules](https://ansible-lint.readthedocs.io/)
- [DevContainers Documentation](https://containers.dev/)
