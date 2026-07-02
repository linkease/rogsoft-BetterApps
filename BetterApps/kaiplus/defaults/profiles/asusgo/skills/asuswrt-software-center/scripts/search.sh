#!/bin/sh
set -eu

query="${1:-}"
if [ -z "$query" ]; then
  echo "usage: $0 <query>" >&2
  exit 2
fi

dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
catalog="${ASUSWRT_APP_JSON_FILE:-}"

if [ -n "$catalog" ]; then
  if [ ! -f "$catalog" ]; then
    echo "catalog file not found: $catalog" >&2
    exit 1
  fi
else
  catalog="${TMPDIR:-/tmp}/asuswrt-app-json.$$"
  sh "$dir/fetch_catalog.sh" "$catalog" >/dev/null
  trap 'rm -f "$catalog"' EXIT HUP INT TERM
fi

awk -v q="$query" '
BEGIN {
  q = tolower(q)
}
function trim(s) {
  sub(/^[ \t\r\n]+/, "", s)
  sub(/[ \t\r\n,]+$/, "", s)
  return s
}
function clean(s) {
  s = trim(s)
  sub(/^"/, "", s)
  sub(/"$/, "", s)
  gsub(/\\"/, "\"", s)
  return s
}
function emit() {
  text = tolower(name " " title " " description " " tags)
  if (name != "" && index(text, q) > 0) {
    if (count > 0) {
      print ""
    }
    print "name: " name
    if (title != "") print "title: " title
    if (version != "") print "version: " version
    if (description != "") print "description: " description
    if (tags != "") print "tags: " tags
    if (home_url != "") print "home_url: " home_url
    if (tar_url != "") print "tar_url: " tar_url
    if (md5 != "") print "md5: " md5
    if (order != "") print "order: " order
    count++
  }
}
function reset() {
  name = ""; title = ""; description = ""; home_url = ""; tar_url = ""; md5 = ""; tags = ""; version = ""; order = ""; inapp = 1
}
{
  line = $0
  if (line ~ /^[ \t]*\{[ \t]*$/ && seen_apps) {
    reset()
    next
  }
  if (line ~ /"apps"[ \t]*:/) {
    seen_apps = 1
  }
  if (!inapp) {
    next
  }
  if (line ~ /^[ \t]*\}[,]?[ \t]*$/) {
    emit()
    inapp = 0
    next
  }
  if (match(line, /^[ \t]*"name"[ \t]*:[ \t]*"[^"]*"/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    name = clean(value)
  } else if (match(line, /^[ \t]*"title"[ \t]*:[ \t]*"[^"]*"/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    title = clean(value)
  } else if (match(line, /^[ \t]*"description"[ \t]*:[ \t]*"[^"]*"/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    description = clean(value)
  } else if (match(line, /^[ \t]*"home_url"[ \t]*:[ \t]*"[^"]*"/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    home_url = clean(value)
  } else if (match(line, /^[ \t]*"tar_url"[ \t]*:[ \t]*"[^"]*"/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    tar_url = clean(value)
  } else if (match(line, /^[ \t]*"md5"[ \t]*:[ \t]*"[^"]*"/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    md5 = clean(value)
  } else if (match(line, /^[ \t]*"version"[ \t]*:[ \t]*"[^"]*"/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    version = clean(value)
  } else if (match(line, /^[ \t]*"order"[ \t]*:/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    order = clean(value)
  } else if (match(line, /^[ \t]*"tags"[ \t]*:/)) {
    value = line
    sub(/^[^:]*:[ \t]*/, "", value)
    tags = clean(value)
  } else if (tags != "" && line ~ /^[ \t]*"/) {
    tags = tags " " clean(line)
  }
}
END {
  if (count == 0) {
    print "no matches for: " q > "/dev/stderr"
    exit 1
  }
}
' "$catalog"
