#!/bin/bash

# Set up trap to ensure cleanup happens even if script fails or is interrupted
cleanup() {
    echo "Cleaning up..."
    if [ -f "test-playbook.yml" ]; then
        rm -f test-playbook.yml
        echo "Test playbook removed."
    fi
}

# Set trap to call cleanup function on exit, interrupt, or error
trap cleanup EXIT INT TERM

echo "Testing Ansible installation..."

# Test 1: Check Ansible version
echo "Checking Ansible version..."
ansible --version
if [ $? -ne 0 ]; then
    echo "ERROR: Ansible is not installed correctly"
    exit 1
fi

# Test 2: Check ansible-lint
echo "Checking ansible-lint..."
ansible-lint --version
if [ $? -ne 0 ]; then
    echo "ERROR: ansible-lint is not installed correctly"
    exit 1
fi

# Create a temporary test playbook
echo "Creating test playbook..."
cat > test-playbook.yml << 'EOL'
---
- name: Test Ansible Installation
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Test task
      ansible.builtin.debug:
        msg: "Ansible is working correctly!"
EOL

# Test 3: Run the playbook
echo "Running test playbook..."
ansible-playbook test-playbook.yml
if [ $? -ne 0 ]; then
    echo "ERROR: Playbook execution failed"
    exit 1
fi

# Test 4: Run ansible-lint on the playbook
echo "Running ansible-lint..."
ansible-lint test-playbook.yml
if [ $? -ne 0 ]; then
    echo "ERROR: ansible-lint check failed"
    exit 1
fi

echo "All tests passed! Ansible is working correctly." 