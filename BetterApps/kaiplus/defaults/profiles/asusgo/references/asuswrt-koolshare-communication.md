# ASUSWRT/Koolshare Communication Reference

This reference records generic ASUSWRT/Koolshare interface information for KaiPlus profile content. It must not include one device's LAN IPs, hostnames, serial numbers, MAC addresses, live process IDs, or observed router model/hostname.

## Software Center Catalog

- Endpoint: `https://rogsoft.ddnsto.com/koolcenter/app.json.js`
- Content type is commonly JavaScript or JSON-like text.
- Browser access may allow cross-origin requests.
- The response contains an `apps` array with plugin metadata.

Relevant response fields:

- `apps[].name`: plugin key or package identifier.
- `apps[].title`: user-facing plugin title.
- `apps[].description`: plugin summary.
- `apps[].home_url`: plugin homepage or documentation URL.
- `apps[].tar_url`: plugin tarball URL for install flow.
- `apps[].md5`: expected tarball checksum when provided.
- `apps[].tags`: category or search tags.
- `apps[].version`: plugin version string.
- `apps[].order`: software center ordering value.

## Koolshare Paths

Common Koolshare paths:

- `/koolshare`
- `/koolshare/bin`
- `/koolshare/scripts`
- `/koolshare/webs`
- `/koolshare/init.d`
- `/koolshare/configs`
- `/tmp/upload`
- `/jffs/.koolshare`

Common scripts:

- `/koolshare/scripts/ks_tar_install.sh`
- `/koolshare/scripts/ks_app_install.sh`
- `/koolshare/scripts/ks_home_status.sh`
- `/koolshare/scripts/center_config.sh`
- `/koolshare/scripts/<plugin>_config.sh`
- `/koolshare/scripts/<plugin>_status.sh`
- `/koolshare/scripts/uninstall_<plugin>.sh`

## Dbus Conventions

Koolshare plugins commonly use `dbus` keys for configuration and enable state.

- Install flow can set `soft_name` before running the installer: `dbus set soft_name=<Plugin>`.
- Enable flow commonly sets `<Plugin>_enable=1`.
- Start flow commonly uses `ACTION=start sh /koolshare/scripts/<Plugin>_config.sh start`.
- Key casing should come from the plugin's scripts or existing `dbus` output. Do not assume casing when evidence is absent.

## BusyBox Compatibility

ASUSWRT/Koolshare shell environments are often BusyBox-like.

- Use POSIX `sh`, not Bash.
- Avoid Bash-only syntax, GNU-only flags, and long command pipelines that are hard to audit.
- Prefer fixed path checks such as `test -x /koolshare/scripts/<plugin>_config.sh`.
- Collect evidence with read-only commands before changing files, `dbus` values, services, or plugin state.
