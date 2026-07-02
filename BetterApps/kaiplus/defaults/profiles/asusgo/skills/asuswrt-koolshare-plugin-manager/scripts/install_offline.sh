#!/bin/sh
set -eu

tarball="${1:-}"
plugin="${2:-}"

if [ -z "$tarball" ] || [ -z "$plugin" ]; then
  echo "usage: $0 </tmp/upload/plugin.tar.gz> <plugin-name>" >&2
  echo "requires: CONFIRM_KOOLSHARE_INSTALL=YES" >&2
  exit 2
fi

case "$plugin" in
  *[!A-Za-z0-9._-]*)
    echo "invalid plugin name: use only A-Z, a-z, 0-9, dot, underscore, or dash" >&2
    exit 2
    ;;
esac

has_dotdot_segment() {
  case "$1" in
    ../*|*/../*|*/..|..)
      return 0
      ;;
  esac
  return 1
}

case "$tarball" in
  /tmp/upload/*) ;;
  *)
    echo "refusing tarball outside /tmp/upload: $tarball" >&2
    exit 2
    ;;
esac
tarball_name="${tarball#/tmp/upload/}"
case "$tarball_name" in
  ""|.|..|*/*)
    echo "refusing tarball outside direct /tmp/upload file: $tarball" >&2
    exit 2
    ;;
esac
if has_dotdot_segment "$tarball"; then
  echo "refusing tarball with traversal segment: $tarball" >&2
  exit 2
fi
if [ -L "$tarball" ]; then
  echo "refusing symlink tarball path: $tarball" >&2
  exit 2
fi

if [ "${CONFIRM_KOOLSHARE_INSTALL:-}" != "YES" ]; then
  echo "need-confirmation: set CONFIRM_KOOLSHARE_INSTALL=YES after verifying plugin, md5, source URL, and available space." >&2
  exit 2
fi

if [ ! -f "$tarball" ]; then
  echo "missing tarball: $tarball" >&2
  exit 1
fi

installer="/koolshare/scripts/ks_tar_install.sh"
if [ ! -x "$installer" ]; then
  echo "missing executable installer: $installer" >&2
  exit 1
fi

echo "action: dbus set soft_name=$plugin" >&2
dbus set "soft_name=$plugin"

echo "action: run $installer" >&2
sh "$installer"

status="/koolshare/scripts/${plugin}_status.sh"
if [ -x "$status" ]; then
  echo "## status" >&2
  sh "$status" 2>&1 || true
fi
