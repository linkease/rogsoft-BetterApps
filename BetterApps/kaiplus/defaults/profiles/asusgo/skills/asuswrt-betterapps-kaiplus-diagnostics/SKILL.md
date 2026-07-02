---
name: asuswrt-betterapps-kaiplus-diagnostics
description: BetterApps and KaiPlus self-checks on ASUSWRT/Koolshare, covering install paths, runtime process evidence, listening port, prompts, skills, logs, and startup integration.
---

# ASUSWRT BetterApps/KaiPlus Diagnostics

Use this skill when the user asks whether BetterApps or KaiPlus is installed, healthy, reachable, or loading profile content correctly.

## Evidence Checklist

- Installation directories and config paths related to BetterApps and KaiPlus.
- Running process evidence and listening port evidence.
- Startup integration under Koolshare paths such as `/koolshare/init.d` and `/koolshare/scripts`.
- KaiPlus config, skills, agents, home prompts, and system prompt files.
- Recent logs and stderr/stdout captures.
- Storage status for JFFS, `/koolshare`, `/tmp/upload`, and any configured data path.

## Rules

- Read evidence before changing service state.
- Ask for confirmation before restart, overwrite, reinstall, or config changes.
- Use POSIX `sh`; do not assume Bash, `systemctl`, `opkg`, or `is-opkg`.
