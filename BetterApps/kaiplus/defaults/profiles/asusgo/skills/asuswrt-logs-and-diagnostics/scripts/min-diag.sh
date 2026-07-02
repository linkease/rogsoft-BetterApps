#!/bin/sh
set -eu

mode="${1:-base}"

help() {
  cat <<'EOF'
Usage:
  min-diag.sh [base|koolshare|disk|network]

Read-only ASUSWRT/Koolshare diagnostics intended for support.
EOF
}

say() {
  echo ""
  echo "## $1"
}

run() {
  echo "\$ $*"
  "$@" 2>&1 || true
}

run_sh() {
  echo "\$ $*"
  sh -c "$*" 2>&1 || true
}

case "$mode" in
  base)
    say "Base"
    run uname -a
    run cat /proc/version
    run date
    run uptime
    run df -h
    ;;
  koolshare)
    say "Koolshare"
    run test -d /koolshare
    run_sh "ls -la /koolshare 2>/dev/null | head -n 120"
    run_sh "ls -la /koolshare/scripts 2>/dev/null | head -n 120"
    run_sh "dbus list soft 2>/dev/null | head -n 120 || true"
    run_sh "logread 2>/dev/null | grep -iE 'koolshare|ks_|software|install|error|fail' | tail -n 160 || true"
    ;;
  disk)
    say "Disk"
    run df -h
    run mount
    run_sh "ls -la /tmp/upload 2>/dev/null || true"
    run_sh "ls -la /jffs 2>/dev/null || true"
    ;;
  network)
    say "Network"
    run ip addr
    run ip route
    run_sh "nslookup rogsoft.ddnsto.com 2>/dev/null || true"
    ;;
  -h|--help|help)
    help
    ;;
  *)
    echo "error: unknown mode: $mode" >&2
    help >&2
    exit 2
    ;;
esac
