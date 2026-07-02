#!/bin/sh
set -eu

say() {
  echo ""
  echo "## $1"
}

run() {
  echo "\$ $*"
  "$@" 2>&1 || true
}

safe_path() {
  name="$1"
  value="$2"
  case "$value" in
    *[!A-Za-z0-9._/%:@+=,-]*)
      echo "invalid $name: unsafe path characters" >&2
      exit 2
      ;;
  esac
}

base="${BETTERAPPS_BASE:-/koolshare/BetterApps}"
kaiplus="${KAIPLUS_HOME:-$base/kaiplus}"

safe_path "BETTERAPPS_BASE" "$base"
safe_path "KAIPLUS_HOME" "$kaiplus"

say "Paths"
echo "BETTERAPPS_BASE=$base"
echo "KAIPLUS_HOME=$kaiplus"
run test -d "$base"
run test -d "$kaiplus"
run test -f "$kaiplus/defaults/profiles/asusgo/manifest.json"

say "KaiPlus Defaults"
echo "\$ ls -la $kaiplus/defaults"
ls -la "$kaiplus/defaults" 2>/dev/null | head -n 80 || true
echo "\$ sed -n 1,80p $kaiplus/defaults/profiles/asusgo/manifest.json"
sed -n '1,80p' "$kaiplus/defaults/profiles/asusgo/manifest.json" 2>/dev/null || true

say "Web Assets"
echo "\$ ls -la $kaiplus/webs"
ls -la "$kaiplus/webs" 2>/dev/null | head -n 80 || true
echo "\$ find $kaiplus/webs -maxdepth 3 -type f"
find "$kaiplus/webs" -maxdepth 3 -type f 2>/dev/null | head -n 80 || true

say "Runtime"
run ps
echo "\$ ps | grep -E BetterApps|kaiplus|reasonix"
ps 2>/dev/null | grep -E 'BetterApps|kaiplus|reasonix' | grep -v grep || true
echo "\$ netstat -lntp | grep -E :(2080|3000|4173|5173)"
netstat -lntp 2>/dev/null | grep -E ':(2080|3000|4173|5173) ' || true

say "Recent Logs"
echo "\$ logread | grep -iE betterapps|kaiplus|reasonix|iframe|apps/kaiplus"
logread 2>/dev/null | grep -iE 'betterapps|kaiplus|reasonix|iframe|apps/kaiplus' | tail -n 120 || true
