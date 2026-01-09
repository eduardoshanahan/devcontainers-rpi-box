# ADR-0006: Pin Ansible toolchain versions in devcontainer build

## Status

Accepted

## Context

Unpinned developer tooling (Ansible, ansible-lint, yamllint) can drift over time, creating inconsistent behavior between machines and across sessions.
This can surface as formatting changes, lint rule differences, or playbook execution differences.

## Decision

Pin the Ansible toolchain versions as devcontainer build arguments sourced from `.env`:

- `ANSIBLE_CORE_VERSION`
- `ANSIBLE_LINT_VERSION`
- `YAMLLINT_VERSION`

The devcontainer image installs these specific versions (via `pip`) during build.

## Consequences

- Reproducible tooling across contributors and time
- Easier debugging when linting or playbook behavior changes
- Requires updating `.env.example` / `.env` versions intentionally when upgrading

## Alternatives Considered

- Install latest versions (rejected: non-deterministic)
- Pin only in documentation (rejected: enforcement is too weak)

