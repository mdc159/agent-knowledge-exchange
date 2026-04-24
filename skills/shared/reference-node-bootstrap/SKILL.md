# Reference Node Bootstrap

## Purpose

Bootstrap a fresh private-first node using the current reference pattern.

## Inputs

- plain Ubuntu host
- one canonical root operator `.env`
- deployment repo with projection scripts

## Procedure

1. install base packages and Docker
2. set the firewall baseline
3. clone the deployment repo
4. create and edit the root `.env`
5. project subsystem runtime files
6. bring up the substrate
7. install and join Tailscale
8. publish operator services privately
9. install outer Hermes host-native
10. verify persistence after reboot

## Guardrails

- do not expose app services publicly
- do not hand-maintain multiple competing env files
- do not leave operator-required steps undocumented
