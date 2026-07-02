#!/usr/bin/env python3

import argparse
import hashlib
import json
import os
import shutil
import stat
import tarfile
import tempfile
import urllib.request
from pathlib import Path


REQUIRED_FIELDS = ("module", "version", "home_url", "title", "description")
BINARY_FIELDS = ("binary_name", "binary_url", "binary_sha256")


def file_md5(path):
    return hashlib.md5(Path(path).read_bytes()).hexdigest()


def file_sha256(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def load_config(root):
    config_path = Path(root) / "config.json.js"
    if not config_path.is_file():
        raise FileNotFoundError(f"missing config file: {config_path}")
    with config_path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def write_config(root, conf):
    config_path = Path(root) / "config.json.js"
    with config_path.open("w", encoding="utf-8") as fh:
        json.dump(conf, fh, sort_keys=True, indent=4, ensure_ascii=False)
        fh.write("\n")


def apply_overrides(conf, binary_url=None, binary_sha256=None):
    env_url = os.environ.get("BETTERAPPS_BINARY_URL")
    env_sha256 = os.environ.get("BETTERAPPS_BINARY_SHA256")
    if env_url:
        conf["binary_url"] = env_url
    if env_sha256:
        conf["binary_sha256"] = env_sha256
    if binary_url:
        conf["binary_url"] = binary_url
    if binary_sha256:
        conf["binary_sha256"] = binary_sha256
    return conf


def validate_config(root, conf):
    for field in REQUIRED_FIELDS + BINARY_FIELDS:
        if not str(conf.get(field, "")).strip():
            raise ValueError(f"{field} is required in config.json.js or build overrides")
    if conf["module"] != "BetterApps":
        raise ValueError("module must be BetterApps")
    if conf["binary_name"] != "BetterApps":
        raise ValueError("binary_name must be BetterApps")
    module_dir = Path(root) / conf["module"]
    if not module_dir.is_dir():
        raise FileNotFoundError(f"missing module directory: {module_dir}")
    install = module_dir / "install.sh"
    if not install.is_file():
        raise FileNotFoundError(f"missing install script: {install}")


def download_binary(url, dest):
    dest = Path(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=str(dest.parent), delete=False) as tmp:
        tmp_path = Path(tmp.name)
        try:
            with urllib.request.urlopen(url, timeout=60) as response:
                shutil.copyfileobj(response, tmp)
            tmp.flush()
            os.fsync(tmp.fileno())
        except Exception:
            tmp_path.unlink(missing_ok=True)
            raise
    return tmp_path


def extract_binary_from_archive(archive_path, binary_name, dest_dir):
    archive_path = Path(archive_path)
    dest_dir = Path(dest_dir)
    candidates = {
        binary_name,
        f"./{binary_name}",
        f"bin/{binary_name}",
        f"./bin/{binary_name}",
        f"BetterApps/bin/{binary_name}",
        f"./BetterApps/bin/{binary_name}",
    }
    with tarfile.open(archive_path, "r:*") as tf:
        member = None
        for item in tf.getmembers():
            name = item.name.lstrip("/")
            if name in candidates:
                member = item
                break
        if member is None:
            raise ValueError(f"archive does not contain {binary_name}")
        if not member.isfile():
            raise ValueError(f"archive member is not a file: {member.name}")
        source = tf.extractfile(member)
        if source is None:
            raise ValueError(f"cannot extract archive member: {member.name}")
        with source, tempfile.NamedTemporaryFile(dir=str(dest_dir), delete=False) as tmp:
            tmp_path = Path(tmp.name)
            try:
                shutil.copyfileobj(source, tmp)
                tmp.flush()
                os.fsync(tmp.fileno())
            except Exception:
                tmp_path.unlink(missing_ok=True)
                raise
    return tmp_path


def prepare_downloaded_binary(downloaded_path, binary_name, dest_dir):
    downloaded_path = Path(downloaded_path)
    if not tarfile.is_tarfile(downloaded_path):
        return downloaded_path
    extracted_path = extract_binary_from_archive(downloaded_path, binary_name, dest_dir)
    downloaded_path.unlink(missing_ok=True)
    return extracted_path


def make_executable(path):
    current = Path(path).stat().st_mode
    Path(path).chmod(current | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


def package_module(root, module):
    root = Path(root)
    package_path = root / f"{module}.tar.gz"
    if package_path.exists():
        package_path.unlink()
    with tarfile.open(package_path, "w:gz") as tf:
        tf.add(root / module, arcname=module)
    return package_path


def build_module(root=None, binary_url=None, binary_sha256=None):
    root = Path(root or Path(__file__).resolve().parent)
    conf = apply_overrides(load_config(root), binary_url, binary_sha256)
    validate_config(root, conf)

    module = conf["module"]
    binary_path = root / module / "bin" / conf["binary_name"]
    tmp_binary_path = download_binary(conf["binary_url"], binary_path)
    try:
        actual_sha256 = file_sha256(tmp_binary_path)
        if actual_sha256.lower() != conf["binary_sha256"].lower():
            raise ValueError(f"sha256 mismatch for {binary_path}: expected {conf['binary_sha256']}, got {actual_sha256}")
        tmp_binary_path = prepare_downloaded_binary(tmp_binary_path, conf["binary_name"], binary_path.parent)
        tmp_binary_path.replace(binary_path)
    except Exception:
        tmp_binary_path.unlink(missing_ok=True)
        raise

    make_executable(binary_path)
    (root / module / "version").write_text(f"{conf['version']}\n", encoding="utf-8")
    package_path = package_module(root, module)
    conf["md5"] = file_md5(package_path)
    write_config(root, conf)
    return conf


def main():
    parser = argparse.ArgumentParser(description="Build BetterApps Asus plugin package")
    parser.add_argument("--binary-url", help="Override binary_url from config.json.js")
    parser.add_argument("--binary-sha256", help="Override binary_sha256 from config.json.js")
    args = parser.parse_args()
    conf = build_module(binary_url=args.binary_url, binary_sha256=args.binary_sha256)
    print(f"build done {conf['module']}.tar.gz md5={conf['md5']}")


if __name__ == "__main__":
    main()
