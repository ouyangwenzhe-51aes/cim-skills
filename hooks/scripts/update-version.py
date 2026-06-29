#!/usr/bin/env python3
"""
Update version script — cross-platform replacement for update-version.ps1 / update-version.sh
Usage: python update-version.py [--destination-path <path>]
       Falls back to PLUGIN_ROOT environment variable when --destination-path is omitted.
"""

import argparse
import os
import shutil
import sys
import tempfile
import urllib.request
import zipfile

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

DOWNLOAD_URL = "https://github.com/ouyangwenzhe-51aes/cim-skills/archive/refs/heads/main.zip"
DEFAULT_DESTINATION_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..")
)


def parse_args() -> str:
    parser = argparse.ArgumentParser(description="Download and install cim-skills plugin.")
    parser.add_argument(
        "--destination-path",
        default=os.environ.get("PLUGIN_ROOT", DEFAULT_DESTINATION_PATH),
        help="Destination directory (defaults to PLUGIN_ROOT or this plugin root)",
    )
    args = parser.parse_args()
    destination = args.destination_path.strip()
    if not destination:
        print(
            "Error: DestinationPath is empty",
            file=sys.stderr,
        )
        sys.exit(1)
    return destination


def download(url: str, dest_file: str) -> None:
    print("Starting download...")
    urllib.request.urlretrieve(url, dest_file)
    print(f"Download completed: {dest_file}")


def extract(zip_file: str, extract_dir: str) -> None:
    print("Starting extraction...")
    if os.path.exists(extract_dir):
        shutil.rmtree(extract_dir)
    with zipfile.ZipFile(zip_file, "r") as zf:
        zf.extractall(extract_dir)
    print("Extraction completed")


def install(extracted_root: str, destination: str) -> None:
    # GitHub archives a single top-level folder named <repo>-<branch>
    entries = os.listdir(extracted_root)
    if len(entries) != 1:
        print(
            f"Error: expected exactly one top-level directory in archive, found: {entries}",
            file=sys.stderr,
        )
        sys.exit(1)
    source_dir = os.path.join(extracted_root, entries[0])
    if not os.path.isdir(source_dir):
        print(f"Error: extracted item is not a directory: {source_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"Installing to destination: {destination}")
    if os.path.exists(destination):
        for item in os.listdir(destination):
            if item == ".git":
                continue
            item_path = os.path.join(destination, item)
            if os.path.isdir(item_path):
                shutil.rmtree(item_path)
            else:
                os.remove(item_path)
    else:
        os.makedirs(destination)

    for item in os.listdir(source_dir):
        shutil.move(os.path.join(source_dir, item), os.path.join(destination, item))
    print("Install completed")


def main() -> None:
    destination = parse_args()

    tmp_root = tempfile.gettempdir()
    zip_file = os.path.join(tmp_root, "cim-skills-main.zip")
    extract_dir = os.path.join(tmp_root, "cim-skills-extract")

    try:
        download(DOWNLOAD_URL, zip_file)
        extract(zip_file, extract_dir)
        install(extract_dir, destination)
    finally:
        if os.path.exists(extract_dir):
            shutil.rmtree(extract_dir, ignore_errors=True)
        if os.path.exists(zip_file):
            os.remove(zip_file)
        print("Temporary files cleaned")

    print("All operations completed")


if __name__ == "__main__":
    main()
