#!/bin/sh
set -eu

say() {
  echo "$*" >&2
}

ok() {
  base="$1"
  [ -n "$base" ] || return 1
  [ -d "$base" ] || return 1
  [ -w "$base" ] || return 1
  return 0
}

base_from_kaiplus_home() {
  home="${KAIPLUS_HOME:-}"
  [ -n "$home" ] || return 1
  case "$home" in
    */BetterApps/kaiplus*) printf '%s\n' "${home%%/BetterApps/kaiplus*}/BetterApps" ;;
    */Configs/*) printf '%s\n' "${home%%/Configs/*}" ;;
    *) printf '%s\n' "$home" ;;
  esac
}

fallback="$(base_from_kaiplus_home || true)"
if [ -n "$fallback" ] && ok "$fallback"; then
  say "picked: base path=$fallback (derived from KAIPLUS_HOME)"
  echo "$fallback"
  exit 0
fi

chosen=""
best_avail=0
cands="$(df -P -k 2>/dev/null | awk '
  NR==1 { next }
  $6 == "/jffs" || $6 == "/tmp" || $6 ~ "^/tmp/" || $6 ~ "^/mnt/" || $6 ~ "^/media/" || $6 ~ "^/opt/" { print $6 "\t" $4 }
')"

tab="$(printf '\t')"
while IFS="$tab" read -r mp avail; do
  [ -n "${mp:-}" ] || continue
  [ -n "${avail:-}" ] || continue
  ok "$mp" || continue
  if [ "$avail" -gt "$best_avail" ] 2>/dev/null; then
    best_avail="$avail"
    chosen="$mp"
  fi
done <<EOF
$cands
EOF

if [ -n "$chosen" ]; then
  say "picked: base path=$chosen (largest writable ASUSWRT candidate)"
  echo "$chosen"
  exit 0
fi

say "failed: cannot auto-pick a writable base path; set KAIPLUS_HOME or choose /jffs, /tmp, or mounted storage."
exit 1
