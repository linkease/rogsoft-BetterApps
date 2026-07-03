# rogsoft-BetterApps Notes

## Packaging Boundary

- Module slug is lowercase `betterapps`.
- Binary filename is fixed as `BetterApps`.
- Do not commit built binaries into this repository.
- `config.json.js` should describe released binaries with `binary_url` and `binary_sha256`.
- Local `build.py` is for local packaging and test use only.
- The release server must not execute plugin-provided scripts such as `build.py`, `build.sh`, or `build_hnd.sh`.
- The release server should run the trusted generic builder from `asusgo-build`.
- Register this module in the target rogsoft repository's `softcenter/modules.json` and `koolcenter/modules.json`.
- Do not add BetterApps-specific functions, hard-coded module injection, or extra module registry files under `asusgo-build`.
