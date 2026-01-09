# ADR-0009: Use Traefik for all admin UIs

## Status

Accepted

## Context

Some Raspberry Pi boxes expose admin UIs directly by IP.
This causes inconsistency once Pi-hole DNS is enabled.

## Decision

All services with a web UI must be exposed via Traefik
using an FQDN. No direct IP access is supported.

## Consequences

- Traefik must be bootstrapped first
- DNS must exist before service deployment
- An initial IP-based access is required only for Traefik

## Alternatives Considered

- Expose UIs directly by IP (rejected: inconsistent UX)
- Mixed IP/FQDN access (rejected: harder automation)
