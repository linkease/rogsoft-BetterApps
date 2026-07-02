---
name: asuswrt-storage-path
description: ASUSWRT/Koolshare storage and path diagnostics for JFFS, USB mounts, /tmp/upload, /koolshare, and plugin data placement; emphasizes read-only checks before write tests.
---

# ASUSWRT Storage Path

Use this skill when installs fail due to space, a plugin needs a data path, or the user asks where to store data.

## Check Areas

- JFFS and persistent storage: `/jffs`, `/jffs/.koolshare`.
- Koolshare root and configs: `/koolshare`, `/koolshare/configs`.
- Upload staging: `/tmp/upload`.
- USB or external mounts shown by `mount` and `df`.

## Workflow

1. Inspect mounts and free space.
2. Check path existence and ownership.
3. Ask before write tests such as creating and deleting a probe file.
4. Prefer persistent storage for plugin configuration and external storage for large data when available.
5. Warn when a path is temporary, especially under `/tmp`.

Use POSIX `sh` and BusyBox-compatible commands.
