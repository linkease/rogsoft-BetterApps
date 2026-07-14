---
name: asuswrt-system-diagnostics
description: Collect read-only ASUSWRT/KoolShare router diagnostics before changing services, plugins, firewall rules, or BetterApps/KaiPlus runtime files.
---

# ASUSWRT System Diagnostics

Use this skill before making changes on ASUSWRT-Merlin-KoolShare / asusgo systems.

Run:

```sh
sh "$KAIPLUS_HOME/config/skills/asuswrt-system-diagnostics/scripts/collect.sh"
```

Review the output before changing system files, dbus keys, iptables rules, or `/koolshare` plugin scripts.
