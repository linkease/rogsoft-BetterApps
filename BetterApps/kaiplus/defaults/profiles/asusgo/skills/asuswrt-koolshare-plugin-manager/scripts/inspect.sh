#!/bin/sh
set -eu

plugin="${1:-}"

if [ -z "$plugin" ]; then
  echo "usage: $0 <plugin-name>" >&2
  exit 2
fi

case "$plugin" in
  *[!A-Za-z0-9._-]*)
    echo "invalid plugin name: use only A-Z, a-z, 0-9, dot, underscore, or dash" >&2
    exit 2
    ;;
esac

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

grep_plugin() {
  dir="$1"
  echo "\$ ls -la $dir | grep -i $plugin"
  ls -la "$dir" 2>/dev/null | grep -i "$plugin" || true
}

scripts="/koolshare/scripts"
webs="/koolshare/webs"

say "Plugin Files"
run test -x "$scripts/${plugin}_config.sh"
run test -x "$scripts/${plugin}_status.sh"
run test -x "$scripts/uninstall_${plugin}.sh"
grep_plugin "$scripts"
grep_plugin "$webs"

say "DBus Keys"
run_sh "dbus list '$plugin' 2>/dev/null || true"
run_sh "dbus get '${plugin}_enable' 2>/dev/null || true"

say "Status"
if [ -x "$scripts/${plugin}_status.sh" ]; then
  run sh "$scripts/${plugin}_status.sh"
else
  echo "status script not executable: $scripts/${plugin}_status.sh"
fi

say "Process And Logs"
echo "\$ ps | grep -i $plugin"
ps 2>/dev/null | grep -i "$plugin" | grep -v grep || true
echo "\$ logread | grep -i $plugin | tail -n 120"
logread 2>/dev/null | grep -i "$plugin" | tail -n 120 || true
