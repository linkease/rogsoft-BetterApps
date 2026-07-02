---
name: asuswrt-koolshare-plugin-manager
description: Koolshare plugin install, enable, start, status, and uninstall guidance using /tmp/upload, dbus soft_name, ks_tar_install.sh, plugin config/status scripts, and explicit confirmation gates.
---

# ASUSWRT Koolshare Plugin Manager

Use this skill for installed plugin state, install planning, enable/start flows, and uninstall planning.

## Install Flow

1. Identify plugin metadata from the software center catalog.
2. Confirm `tar_url`, `md5`, plugin `name`, and required storage.
3. Confirm `/tmp/upload` is available and has enough space.
4. Ask the user for explicit confirmation before downloading or installing.
5. Place the tarball under `/tmp/upload`.
6. Set the install name: `dbus set soft_name=<Plugin>`.
7. Run the installer: `/koolshare/scripts/ks_tar_install.sh`.
8. Verify with software center status, plugin status script, logs, and `dbus` keys.

## Enable And Start Flow

After confirming the plugin name and script casing:

- Enable: `dbus set <Plugin>_enable=1`
- Start: `ACTION=start sh /koolshare/scripts/<Plugin>_config.sh start`
- Verify: `sh /koolshare/scripts/<Plugin>_status.sh` when present, plus logs and process/listening evidence.

## Safety

Require confirmation before install, remove, restart, overwrite, `dbus set`, or running config scripts that change service state.
