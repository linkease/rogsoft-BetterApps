#!/bin/sh
set -eu

plugin="${1:-}"
action="${2:-status}"

if [ -z "$plugin" ]; then
  echo "usage: $0 <plugin-name> [status|enable|start|restart|stop]" >&2
  exit 2
fi

case "$plugin" in
  *[!A-Za-z0-9._-]*)
    echo "invalid plugin name: use only A-Z, a-z, 0-9, dot, underscore, or dash" >&2
    exit 2
    ;;
esac

config="/koolshare/scripts/${plugin}_config.sh"
status="/koolshare/scripts/${plugin}_status.sh"

run_status() {
  if [ -x "$status" ]; then
    sh "$status" 2>&1 || true
  else
    echo "status script not executable: $status" >&2
  fi
  dbus get "${plugin}_enable" 2>/dev/null || true
}

need_confirm() {
  echo "need-confirmation: $*" >&2
  echo "set CONFIRM_ASUSWRT_SERVICE_CHANGE=YES to proceed" >&2
  exit 2
}

case "$action" in
  status)
    run_status
    ;;
  enable)
    [ "${CONFIRM_ASUSWRT_SERVICE_CHANGE:-}" = "YES" ] || need_confirm "enable $plugin"
    dbus set "${plugin}_enable=1"
    run_status
    ;;
  start|restart|stop)
    [ "${CONFIRM_ASUSWRT_SERVICE_CHANGE:-}" = "YES" ] || need_confirm "$action $plugin"
    if [ ! -x "$config" ]; then
      echo "config script not executable: $config" >&2
      exit 1
    fi
    case "$action" in
      start) dbus set "${plugin}_enable=1" ;;
      restart) dbus set "${plugin}_enable=1" ;;
      stop) ;;
    esac
    ACTION="$action" sh "$config" "$action" 2>&1 || true
    run_status
    ;;
  *)
    echo "error: unknown action: $action" >&2
    exit 2
    ;;
esac
