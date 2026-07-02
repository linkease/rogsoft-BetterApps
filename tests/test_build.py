import hashlib
import importlib.util
import json
import os
import tarfile
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
BUILD = ROOT / "build.py"


def load_build_module():
    spec = importlib.util.spec_from_file_location("betterapps_build", BUILD)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class BuildScriptTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.module_dir = self.root / "BetterApps"
        (self.module_dir / "bin").mkdir(parents=True)
        (self.module_dir / "scripts").mkdir()
        (self.module_dir / "webs").mkdir()
        (self.module_dir / "res").mkdir()
        (self.module_dir / "kaiplus" / "defaults" / "profiles" / "asusgo").mkdir(parents=True)
        (self.module_dir / "install.sh").write_text("#!/bin/sh\n", encoding="utf-8")
        (self.module_dir / "uninstall.sh").write_text("#!/bin/sh\n", encoding="utf-8")
        (self.module_dir / "kaiplus" / "defaults" / "profiles" / "asusgo" / "manifest.json").write_text(
            '{"role":"asusgo","aliases":["asuswrt"]}\n',
            encoding="utf-8",
        )
        self.source_binary = self.root / "source-BetterApps"
        self.source_binary.write_bytes(b"betterapps binary fixture\n")
        self.sha256 = hashlib.sha256(self.source_binary.read_bytes()).hexdigest()
        self.config_path = self.root / "config.json.js"
        self.config_path.write_text(json.dumps({
            "module": "BetterApps",
            "version": "0.1.0",
            "home_url": "Module_BetterApps.asp",
            "title": "BetterApps",
            "description": "BetterApps for Asus/ROG router",
            "binary_name": "BetterApps",
            "binary_url": self.source_binary.as_uri(),
            "binary_sha256": self.sha256,
        }, indent=4), encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def test_build_downloads_verifies_and_packages_binary(self):
        build = load_build_module()

        conf = build.build_module(self.root)

        binary = self.module_dir / "bin" / "BetterApps"
        package = self.root / "BetterApps.tar.gz"
        self.assertTrue(binary.exists())
        self.assertEqual(binary.read_bytes(), self.source_binary.read_bytes())
        self.assertTrue(os.access(binary, os.X_OK))
        self.assertTrue(package.exists())
        self.assertEqual((self.module_dir / "version").read_text(encoding="utf-8"), "0.1.0\n")
        self.assertIn("md5", conf)
        saved = json.loads(self.config_path.read_text(encoding="utf-8"))
        self.assertEqual(saved["md5"], conf["md5"])
        with tarfile.open(package, "r:gz") as tf:
            names = tf.getnames()
            self.assertIn("BetterApps/bin/BetterApps", names)
            self.assertIn("BetterApps/kaiplus/defaults/profiles/asusgo/manifest.json", names)

    def test_build_downloads_binary_archive_and_extracts_executable(self):
        archive = self.root / "BetterApps-binary-linux-arm64-v0.1.3.tar.gz"
        with tarfile.open(archive, "w:gz") as tf:
            tf.add(self.source_binary, arcname="BetterApps")
        data = json.loads(self.config_path.read_text(encoding="utf-8"))
        data["binary_url"] = archive.as_uri()
        data["binary_sha256"] = hashlib.sha256(archive.read_bytes()).hexdigest()
        self.config_path.write_text(json.dumps(data), encoding="utf-8")
        build = load_build_module()

        conf = build.build_module(self.root)

        binary = self.module_dir / "bin" / "BetterApps"
        self.assertEqual(binary.read_bytes(), self.source_binary.read_bytes())
        self.assertTrue(os.access(binary, os.X_OK))
        self.assertIn("md5", conf)

    def test_build_rejects_empty_binary_url(self):
        data = json.loads(self.config_path.read_text(encoding="utf-8"))
        data["binary_url"] = ""
        self.config_path.write_text(json.dumps(data), encoding="utf-8")
        build = load_build_module()

        with self.assertRaisesRegex(ValueError, "binary_url"):
            build.build_module(self.root)

    def test_build_rejects_sha256_mismatch(self):
        data = json.loads(self.config_path.read_text(encoding="utf-8"))
        data["binary_sha256"] = "0" * 64
        self.config_path.write_text(json.dumps(data), encoding="utf-8")
        binary = self.module_dir / "bin" / "BetterApps"
        binary.write_bytes(b"existing trusted binary\n")
        build = load_build_module()

        with self.assertRaisesRegex(ValueError, "sha256"):
            build.build_module(self.root)
        self.assertEqual(binary.read_bytes(), b"existing trusted binary\n")
