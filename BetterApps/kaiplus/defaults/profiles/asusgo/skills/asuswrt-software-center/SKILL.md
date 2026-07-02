---
name: asuswrt-software-center
description: Search and interpret the Koolshare ASUSWRT software center catalog, including plugin metadata fields and tarball install inputs, without performing installs.
---

# ASUSWRT Software Center

Use this skill when the user wants to search, compare, or identify Koolshare plugins.

## Catalog

- Endpoint: `https://rogsoft.ddnsto.com/koolcenter/app.json.js`
- Response is JSON-like content with an `apps` array.
- Relevant fields: `name`, `title`, `description`, `home_url`, `tar_url`, `md5`, `tags`, `version`, `order`.

## Search Workflow

1. Fetch or inspect the catalog.
2. Match by plugin `name`, `title`, `description`, and `tags`.
3. Return only relevant candidates.
4. Include install inputs such as `tar_url` and `md5` only when the user is considering install.
5. Ask the user to choose the exact plugin before any install flow.

Do not install plugins in this skill. Use the plugin manager flow after confirmation.
