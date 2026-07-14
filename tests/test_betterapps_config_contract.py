from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
CONFIG = ROOT / "betterapps" / "scripts" / "betterapps_config.sh"


class BetterAppsConfigContractTest(unittest.TestCase):
    def test_runtime_paths_use_selected_data_disk_and_keep_app_assets_under_koolshare(self):
        text = CONFIG.read_text(encoding="utf-8")

        self.assertIn("APP_DIR=/koolshare/betterapps", text)
        self.assertIn("BIN=/koolshare/bin/BetterApps", text)
        self.assertIn("export KAIPLUS_BIN=${APP_DIR}/kaiplus/bin/kaiplus_bin", text)
        self.assertIn("export KAIPLUS_STATIC_DIR=${APP_DIR}/kaiplus/www", text)
        self.assertIn("export KAIPLUS_DEFAULTS_DIR=${APP_DIR}/kaiplus/defaults", text)
        self.assertIn(
            "export KAIPLUS_WORKSPACE_TOOL_BINARY=${APP_DIR}/kaiplus/helpers/kaiplus_workspace_tool",
            text,
        )

        self.assertIn('resolve_betterapps_data_disk()', text)
        self.assertIn('read_persisted_data_disk()', text)
        self.assertIn('persisted_config=${APP_DIR}/data/bootstrap/system/data-root.json', text)
        self.assertIn('"selectedDisk"', text)
        self.assertLess(text.index('"$betterapps_data_disk"'), text.index('"$betterapps_data_root_parent"'))
        self.assertLess(text.index('"$betterapps_data_root_parent"'), text.index('case "$betterapps_data_root" in'))
        self.assertIn('case "$betterapps_data_root" in', text)
        self.assertIn('*/.linkease_data)', text)
        self.assertIn('BETTERAPPS_DATA_DISK="$resolved_data_disk"', text)
        self.assertIn('export BETTERAPPS_DATA_ROOT=${BETTERAPPS_DATA_DISK}/.linkease_data', text)
        self.assertIn('export BETTERAPPS_RECYCLE_ROOT=${BETTERAPPS_DATA_DISK}/.linkease_recycle', text)
        self.assertIn('export USER_DATA_PATH=${BETTERAPPS_DATA_ROOT}/users/admin', text)
        self.assertIn('export SYSTEM_DATA_PATH=${BETTERAPPS_DATA_ROOT}/system', text)
        self.assertIn('export TEMP_PATH=${BETTERAPPS_DATA_ROOT}/tmp', text)
        self.assertIn('export KAIPLUS_HOME=${BETTERAPPS_DATA_ROOT}/kaiplus', text)

    def test_bootstrap_fallback_is_minimal_and_not_the_target_data_design(self):
        text = CONFIG.read_text(encoding="utf-8")

        self.assertIn('export BETTERAPPS_BOOTSTRAP_FALLBACK=1', text)
        self.assertIn('export BETTERAPPS_DATA_ROOT=${APP_DIR}/data/bootstrap', text)
        self.assertIn('export USER_DATA_PATH=${BETTERAPPS_DATA_ROOT}/users/admin', text)
        self.assertIn('export KAIPLUS_HOME=${BETTERAPPS_DATA_ROOT}/kaiplus', text)
        self.assertIn('[ "$BETTERAPPS_BOOTSTRAP_FALLBACK" = "1" ]', text)
        self.assertIn('mkdir -p "$USER_DATA_PATH" "$SYSTEM_DATA_PATH" "$TEMP_PATH" "$KAIPLUS_HOME"', text)
        self.assertIn(
            'mkdir -p "$USER_DATA_PATH" "$SYSTEM_DATA_PATH" "$TEMP_PATH" "$KAIPLUS_HOME" "$BETTERAPPS_RECYCLE_ROOT"',
            text,
        )

    def test_enable_path_initializes_apps_forward_nvram_and_defers_httpd_restart(self):
        text = CONFIG.read_text(encoding="utf-8")

        self.assertIn('APPS_PORT_FORWARD="http://127.0.0.1:${PORT}"', text)
        self.assertIn('current_forward="$(nvram get apps_port_forward 2>/dev/null)"', text)
        self.assertIn('[ "$current_forward" = "$APPS_PORT_FORWARD" ] && return 0', text)
        self.assertIn('nvram set apps_port_forward="$APPS_PORT_FORWARD"', text)
        self.assertIn("nvram commit", text)
        self.assertIn("schedule_httpd_restart", text)
        self.assertIn("service restart_httpd", text)
        self.assertIn("ensure_apps_forward", text)


if __name__ == "__main__":
    unittest.main()
