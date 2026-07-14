#!/bin/sh
set -eu

section() {
  printf '\n## %s\n' "$1"
}

section "system"
uname -a 2>/dev/null || true
nvram get productid 2>/dev/null || true
nvram get buildno 2>/dev/null || true
nvram get extendno 2>/dev/null || true

section "space"
df -h 2>/dev/null || true

section "processes"
ps 2>/dev/null | grep -E 'BetterApps|kaiplus|skipd|httpdb' | grep -v grep || true

section "ports"
netstat -lntp 2>/dev/null | grep -E '19290|19291|8198|httpdb|BetterApps|kaiplus' || true

section "betterapps"
ls -la /koolshare/BetterApps 2>/dev/null || true
ls -la /koolshare/BetterApps/kaiplus 2>/dev/null || true
ls -la /koolshare/scripts/BetterApps_config.sh 2>/dev/null || true

section "kaiplus-home"
KAIPLUS_HOME="${KAIPLUS_HOME:-/koolshare/BetterApps/data/kaiplus}"
printf 'KAIPLUS_HOME=%s\n' "$KAIPLUS_HOME"
find "$KAIPLUS_HOME" -maxdepth 3 -type d 2>/dev/null | sed -n '1,80p' || true

section "dbus"
dbus list BetterApps 2>/dev/null || true
