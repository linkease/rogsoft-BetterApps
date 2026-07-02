#!/bin/sh
set -eu

url="${ASUSWRT_APP_JSON_URL:-https://rogsoft.ddnsto.com/koolcenter/app.json.js}"
out="${1:-}"

fetch() {
  if [ -x /usr/bin/wget ] || [ -x /bin/wget ]; then
    wget -q -O - "$url"
    return
  fi
  if [ -x /usr/bin/curl ] || [ -x /bin/curl ]; then
    curl -fsSL "$url"
    return
  fi
  echo "missing wget/curl for catalog fetch" >&2
  return 1
}

has_dotdot_segment() {
  case "$1" in
    ../*|*/../*|*/..|..)
      return 0
      ;;
  esac
  return 1
}

if [ -n "$out" ]; then
  case "$out" in
    /tmp/*) ;;
    *)
      echo "refusing output path outside /tmp: $out" >&2
      exit 2
      ;;
  esac
  out_name="${out#/tmp/}"
  case "$out_name" in
    ""|.|..|*/*)
      echo "refusing output path outside direct /tmp file: $out" >&2
      exit 2
      ;;
  esac
  if has_dotdot_segment "$out"; then
    echo "refusing output path with traversal segment: $out" >&2
    exit 2
  fi
  tmp="$out.$$"
  if [ -L "$out" ] || [ -L "$tmp" ]; then
    echo "refusing symlink output path: $out" >&2
    exit 2
  fi
  rm -f "$tmp"
  fetch >"$tmp"
  mv "$tmp" "$out"
  echo "$out"
else
  fetch
fi
