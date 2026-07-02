---
name: asuswrt-logs-and-diagnostics
description: ASUSWRT/Koolshare read-only diagnostics for firmware, BusyBox shell, Koolshare paths, dbus state, storage, logs, scripts, processes, and ports; use before conclusions or changes.
---

# ASUSWRT Logs & Diagnostics

Use this skill before diagnosing failures or changing state.

## Principles

- Collect read-only evidence first.
- Use POSIX `sh` commands that work on BusyBox-like systems.
- Prefer fixed path checks over PATH discovery.
- Do not include LAN IPs, hostnames, serials, MACs, or live process IDs in reusable notes.

## Evidence Areas

- Firmware and kernel: `/etc/os-release`, `/etc/profile`, `uname -a` when available.
- Shell: confirm `/bin/sh` behavior and avoid Bash assumptions.
- Koolshare layout: `/koolshare`, `/koolshare/bin`, `/koolshare/scripts`, `/koolshare/init.d`, `/koolshare/configs`, `/tmp/upload`, `/jffs/.koolshare`.
- Storage: `df`, `mount`, and writable checks only after user confirms write tests.
- Logs: system log commands available on the device and plugin-specific logs under Koolshare paths.
- Plugin status: relevant `dbus` keys, config script, status script, process evidence, and listening ports.

Ask for confirmation before install, remove, restart, overwrite, `dbus set`, or any write operation.
