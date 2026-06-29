#!/usr/bin/env python3
"""
Update release metadata across cim-skills.

Cross-platform replacement for dev-scripts/release.ps1.
"""

import argparse
import json
import re
import shutil
import subprocess
import sys
from datetime import date
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
PLUGIN_NAME = "cimapi-skills"


class ReleaseError(RuntimeError):
    pass


def add_months(source: date, months: int) -> date:
    month = source.month - 1 + months
    year = source.year + month // 12
    month = month % 12 + 1
    days_in_month = [
        31,
        29 if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0) else 28,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31,
    ]
    day = min(source.day, days_in_month[month - 1])
    return date(year, month, day)


def repo_path(path: str) -> Path:
    return REPO_ROOT / path


def read_json_file(path: str) -> object:
    with repo_path(path).open("r", encoding="utf-8") as file:
        return json.load(file)


def write_json_file(path: str, data: object) -> None:
    with repo_path(path).open("w", encoding="utf-8", newline="\n") as file:
        json.dump(data, file, ensure_ascii=False, indent=2)
        file.write("\n")


def set_json_version(path: str, version: str) -> None:
    data = read_json_file(path)
    data["version"] = version
    write_json_file(path, data)


def set_marketplace_version(path: str, version: str) -> None:
    data = read_json_file(path)
    for plugin in data.get("plugins", []):
        if plugin.get("name") == PLUGIN_NAME:
            plugin["version"] = version
    write_json_file(path, data)


def set_apm_versions(path: str, version: str) -> None:
    apm_path = repo_path(path)
    text = apm_path.read_text(encoding="utf-8")

    # Update top-level plugin version.
    text, top_level_count = re.subn(
        r"(?m)^version:\s*\S+\s*$",
        f"version: {version}",
        text,
        count=1,
    )
    if top_level_count == 0:
        raise ReleaseError(f"Top-level version not found in {path}")

    # Update marketplace package version (the first package entry in apm.yml).
    text, package_count = re.subn(
        r"(?m)^(\s*\-\s*name:\s*cimapi-skills\s*\n(?:\s+.*\n)*?\s*version:)\s*\S+\s*$",
        rf"\1 {version}",
        text,
        count=1,
    )
    if package_count == 0:
        raise ReleaseError(f"Marketplace package version not found in {path}")

    apm_path.write_text(text, encoding="utf-8", newline="\n")




def set_skill_version(path: Path, version: str, valid_until: str) -> None:
    text = path.read_text(encoding="utf-8")

    if not re.search(r"(?m)^version:\s*", text):
        text = re.sub(
            r"(?m)^(metadata:\s*)$",
            f'version: "{version}"\nvalid_until: "{valid_until}"\n\\1',
            text,
            count=1,
        )
    else:
        text = re.sub(r"(?m)^version:\s*.*$", f'version: "{version}"', text)
        if not re.search(r"(?m)^valid_until:\s*", text):
            text = re.sub(
                r"(?m)^(metadata:\s*)$",
                f'valid_until: "{valid_until}"\n\\1',
                text,
                count=1,
            )
        else:
            text = re.sub(
                r"(?m)^valid_until:\s*.*$",
                f'valid_until: "{valid_until}"',
                text,
            )

    text = re.sub(
        r"(?m)^(\s*)version:\s*\d+\.\d+\.\d+\s*$",
        rf"\1version: {version}",
        text,
    )
    path.write_text(text, encoding="utf-8", newline="\n")


def validate_json(path: str) -> None:
    read_json_file(path)


def run_command(command: list[str]) -> None:
    subprocess.run(command, cwd=REPO_ROOT, check=True)



def create_tag(version: str, push: bool) -> None:
    tag_name = f"v{version}"
    result = subprocess.run(
        ["git", "tag", "-l", tag_name],
        cwd=REPO_ROOT,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        encoding="utf-8",
    )
    if result.stdout.strip():
        raise ReleaseError(f"Tag {tag_name} already exists. Delete it intentionally before recreating.")

    run_command(["git", "tag", tag_name])
    if push:
        run_command(["git", "push", "origin", "HEAD"])
        run_command(["git", "push", "origin", tag_name])


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Update release files for a cim-skills version.")
    parser.add_argument("-version", required=True, help="Semantic version, e.g. 1.2.3")
    parser.add_argument(
        "--valid-until",
        default=add_months(date.today(), 6).isoformat(),
        help="Skill validity date, default: today + 6 months",
    )
    parser.add_argument("--tag", action="store_true", help="Create git tag v<version>")
    parser.add_argument("--push", action="store_true", help="Push HEAD and tag when --tag is used")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    if not re.fullmatch(r"\d+\.\d+\.\d+", args.version):
        raise ReleaseError("-version must match MAJOR.MINOR.PATCH, e.g. 1.2.3")

    set_json_version("plugin.json", args.version)
    set_json_version(".claude-plugin/plugin.json", args.version)
    set_json_version(".cursor-plugin/plugin.json", args.version)
    set_marketplace_version(".claude-plugin/marketplace.json", args.version)
    set_marketplace_version(".cursor-plugin/marketplace.json", args.version)
    set_apm_versions("apm.yml", args.version)

    for skill_path in repo_path("skills").rglob("SKILL.md"):
        set_skill_version(skill_path, args.version, args.valid_until)

    validate_json("plugin.json")
    validate_json(".claude-plugin/plugin.json")
    validate_json(".claude-plugin/marketplace.json")
    validate_json(".cursor-plugin/plugin.json")
    validate_json(".cursor-plugin/marketplace.json")


    if args.tag:
        create_tag(args.version, args.push)

    print(f"Release files updated for version {args.version} (valid_until: {args.valid_until}).")
    print("Next steps:")
    print("  1. Update CHANGELOG.md with human-readable release notes.")
    print(
        f"  2. Commit changes, then tag and push: git tag v{args.version}; "
        f"git push origin HEAD; git push origin v{args.version}"
    )
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except ReleaseError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
