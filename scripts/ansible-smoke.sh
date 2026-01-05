#!/bin/sh

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANSIBLE_ROOT="${REPO_ROOT}/src"
ANSIBLE_CFG="${ANSIBLE_ROOT}/ansible.cfg"
INVENTORY_DIR="${ANSIBLE_ROOT}/inventory"

if [ $# -lt 2 ]; then
    printf 'Usage: %s /path/to/playbook.yml /path/to/inventory.ini\n' "$0" >&2
    printf 'Optional: set SMOKE_GROUP to override the default host group (default: raspberry_pi_boxes).\n' >&2
    exit 1
fi

PLAYBOOK="$1"
INVENTORY="$2"

if ! command -v ansible >/dev/null 2>&1; then
    printf '%s\n' "ansible command not found; run this script inside the devcontainer." >&2
    exit 1
fi

export ANSIBLE_CONFIG="$ANSIBLE_CFG"
export ANSIBLE_INVENTORY="$INVENTORY_DIR"

SMOKE_GROUP="${SMOKE_GROUP:-raspberry_pi_boxes}"

printf '%s\n' ">>> Ansible version"
ansible --version | sed -n '1,2p'
printf '\n'

if command -v ansible-lint >/dev/null 2>&1; then
    printf '%s\n' ">>> Running ansible-lint on ${PLAYBOOK}"
    ansible-lint "$PLAYBOOK"
    printf '\n'
else
    printf '%s\n' "ansible-lint not available; skipping lint step." >&2
fi

if command -v yamllint >/dev/null 2>&1; then
    printf '%s\n' ">>> Running yamllint on ${ANSIBLE_ROOT}"
    yamllint "$ANSIBLE_ROOT"
    printf '\n'
else
    printf '%s\n' "yamllint not available; skipping YAML lint step." >&2
fi

run_playbook() {
    smoke_label="$1"
    output_file="$(mktemp)"
    output_fifo="$(mktemp -u)"

    cleanup_fifo() {
        rm -f "$output_fifo" 2>/dev/null || true
    }
    trap cleanup_fifo EXIT HUP INT TERM

    if ! mkfifo "$output_fifo"; then
        rm -f "$output_file"
        printf '%s\n' "Failed to create FIFO for output streaming." >&2
        return 1
    fi

    printf '%s\n' ">>> Executing ansible-playbook ${PLAYBOOK} (${smoke_label}, inventory: ${INVENTORY})"
    tee "$output_file" < "$output_fifo" &
    tee_pid=$!

    ansible-playbook -i "$INVENTORY" "$PLAYBOOK" >"$output_fifo" 2>&1
    play_rc=$?

    wait "$tee_pid" 2>/dev/null || true
    rm -f "$output_fifo"
    trap - EXIT HUP INT TERM

    if [ "$play_rc" -ne 0 ]; then
        rm -f "$output_file"
        return 1
    fi

    if [ "$smoke_label" = "second-pass" ]; then
        if grep -Eq "changed=[1-9]" "$output_file"; then
            printf '%s\n' "Second pass reported changes; playbook is not idempotent." >&2
            rm -f "$output_file"
            return 1
        fi
    fi

    rm -f "$output_file"
}

run_playbook "first-pass"
run_playbook "second-pass"
