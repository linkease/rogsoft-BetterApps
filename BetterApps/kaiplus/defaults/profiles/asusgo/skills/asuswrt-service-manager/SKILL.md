---
name: asuswrt-service-manager
description: ASUSWRT/Koolshare service and plugin runtime management using dbus keys, Koolshare init.d entries, config scripts, status scripts, logs, and confirmation before state changes.
---

# ASUSWRT Service Manager

Use this skill when a service or plugin is installed but not running, not enabled, or not reachable.

## Workflow

1. Collect read-only evidence: scripts, status output, logs, `dbus` keys, process evidence, and ports.
2. Confirm the exact plugin/service name and key casing from scripts or existing `dbus` values.
3. Explain the planned state change.
4. Ask for user confirmation.
5. Apply the smallest state change needed.
6. Verify status and logs.

## Koolshare Plugin Pattern

- Config script: `/koolshare/scripts/<Plugin>_config.sh`
- Status script: `/koolshare/scripts/<Plugin>_status.sh`
- Enable key: `dbus set <Plugin>_enable=1`
- Start command: `ACTION=start sh /koolshare/scripts/<Plugin>_config.sh start`

Do not assume `systemctl`, OpenWrt init conventions, `opkg`, or `is-opkg` for ASUSWRT/Koolshare.
