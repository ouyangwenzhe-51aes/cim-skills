#!/usr/bin/env python3
"""Check whether the installed cim-skills plugin is outdated.

Cross-platform replacement for outdated.sh / outdated.ps1.
Exits with code 99 and emits a SessionStart hook payload when an update is
available; exits with 0 otherwise.
"""

import argparse
import json
import logging
import os
import re
import sys
import tempfile
import urllib.error
import urllib.request
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

# ---------------------------------------------------------------------------
# Logging (file-only, mirrors the PowerShell / bash log helpers)
# ---------------------------------------------------------------------------

LOG_FILE = Path(tempfile.gettempdir()) / "cimapi-hook.log"

logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.DEBUG,
    format="%(asctime)s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

log = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Semver helpers
# ---------------------------------------------------------------------------

_SEMVER_RE = re.compile(
    r"^(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)"
    r"(?:-(?P<prerelease>[0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$"
)


def parse_semver(version: str) -> tuple:
    """Return (major, minor, patch, prerelease) tuple or raise ValueError."""
    m = _SEMVER_RE.match(version)
    if not m:
        raise ValueError(f"Invalid semver: {version}")
    return (
        int(m.group("major")),
        int(m.group("minor")),
        int(m.group("patch")),
        m.group("prerelease") or "",
    )


def _compare_prerelease(a: str, b: str) -> int:
    """Compare two pre-release strings per semver spec. Returns -1, 0, or 1."""
    if not a and not b:
        return 0
    if not a:
        return 1   # release > pre-release
    if not b:
        return -1

    a_parts = a.split(".")
    b_parts = b.split(".")
    for i in range(max(len(a_parts), len(b_parts))):
        if i >= len(a_parts):
            return -1
        if i >= len(b_parts):
            return 1
        ap, bp = a_parts[i], b_parts[i]
        a_num = ap.isdigit()
        b_num = bp.isdigit()
        if a_num and b_num:
            cmp = (int(ap) > int(bp)) - (int(ap) < int(bp))
            if cmp:
                return cmp
        elif a_num:
            return -1
        elif b_num:
            return 1
        else:
            cmp = (ap > bp) - (ap < bp)
            if cmp:
                return cmp
    return 0


def compare_semver(a: str, b: str) -> int:
    """Return -1 if a < b, 0 if a == b, 1 if a > b."""
    am, an, ap, apre = parse_semver(a)
    bm, bn, bp, bpre = parse_semver(b)
    for la, lb in ((am, bm), (an, bn), (ap, bp)):
        if la < lb:
            return -1
        if la > lb:
            return 1
    return _compare_prerelease(apre, bpre)


# ---------------------------------------------------------------------------
# Local install detection
# ---------------------------------------------------------------------------

def get_installed_version(root: Path, plugin: str, owner: str, repo: str):
    """
    Walk *root* looking for plugin.json files that match *plugin*.
    Returns (version, source_path) or None.
    Prefers the canonical <owner>/<repo>/plugin.json path.
    """
    if not root.is_dir():
        return None

    preferred = None
    first = None

    for plugin_json in root.rglob("plugin.json"):
        try:
            data = json.loads(plugin_json.read_text(encoding="utf-8"))
        except Exception:
            continue

        if data.get("name") == plugin and data.get("version"):
            entry = (str(data["version"]), plugin_json)
            if first is None:
                first = entry
            # Match cross-platform path separator
            parts = plugin_json.parts
            try:
                idx = parts.index(owner)
                if (
                    idx + 2 < len(parts)
                    and parts[idx + 1] == repo
                    and parts[idx + 2] == "plugin.json"
                ):
                    preferred = entry
                    break
            except ValueError:
                pass

    return preferred or first


# ---------------------------------------------------------------------------
# Remote marketplace lookup
# ---------------------------------------------------------------------------

def fetch_latest_version(owner: str, repo: str, branch: str, marketplace_path: str, plugin: str) -> str | None:
    """Download the marketplace JSON and return the version string for *plugin*, or None."""
    url = f"https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{marketplace_path}"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "cimapi-outdated-check/1.0"})
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = json.loads(resp.read().decode("utf-8"))
    except (urllib.error.URLError, json.JSONDecodeError, OSError) as exc:
        log.warning("Failed to fetch marketplace: %s", exc)
        return None

    for item in data.get("plugins", []):
        if item.get("name") == plugin:
            return str(item["version"]) if item.get("version") else None
    return None


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------

def emit_session_context(message: str = "") -> None:
    payload = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": message,
        }
    }
    print(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Check whether the installed cim-skills plugin is outdated.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    p.add_argument("--plugin-name", default="cimapi-skills", help="Plugin name (default: cimapi-skills)")
    p.add_argument("--owner", default="ouyangwenzhe-51aes", help="Repository owner")
    p.add_argument("--repo", default="cim-skills", help="Repository name")
    p.add_argument("--branch", default="main", help="Branch name (default: main)")
    p.add_argument(
        "--marketplace-path",
        default=".cursor-plugin/marketplace.json",
        help="Marketplace JSON path within the repo",
    )
    p.add_argument(
        "--install-root",
        default="",
        help="Local install root (default: $HOME/.vscode/agent-plugins/github.com)",
    )
    return p


def resolve_install_root(arg: str) -> Path:
    if arg.strip():
        return Path(arg)
    home = os.environ.get("USERPROFILE") or os.environ.get("HOME") or ""
    if not home:
        raise RuntimeError("Cannot determine home directory. Pass --install-root explicitly.")
    return Path(home) / ".vscode" / "agent-plugins" / "github.com"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    args = build_parser().parse_args()

    try:
        install_root = resolve_install_root(args.install_root)
    except RuntimeError as exc:
        log.error("%s", exc)
        emit_session_context("")
        return 0

    installed = get_installed_version(install_root, args.plugin_name, args.owner, args.repo)
    if not installed:
        log.warning("Cannot find installed plugin '%s'", args.plugin_name)
        emit_session_context("")
        return 0

    local_version, installed_source = installed

    latest_version = fetch_latest_version(
        args.owner, args.repo, args.branch, args.marketplace_path, args.plugin_name
    )
    if not latest_version:
        emit_session_context("")
        return 0

    try:
        cmp = compare_semver(local_version, latest_version)
    except ValueError as exc:
        log.error("Semver comparison failed: %s", exc)
        emit_session_context("")
        return 0

    log.info("local=%s latest=%s compare=%d", local_version, latest_version, cmp)

    if cmp < 0:
        message = (
            "IMPORTANT:\n\n"
            "        The installed cim-skills plugin is outdated.\n\n"
            "        For the first response in this session:\n\n"
            "        1. Start the reply with the following notice:\n\n"
            "        \u26a0\ufe0f cim-skills \u6709\u65b0\u7248\u672c\u53ef\u7528\n\n"
            f"        \u5f53\u524d\u7248\u672c: {local_version}\n"
            f"        \u6700\u65b0\u7248\u672c: {latest_version}\n\n"
            f"        \u8bf7\u66f4\u65b0\u81f3 cimapi-skills v{latest_version}\n\n"
            "        2. Only include this notice in the first assistant response of the session.\n"
            "        Do not repeat it afterwards."
        )
        emit_session_context(message)
        return 99

    emit_session_context("")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        log.exception("Unhandled exception: %s", exc)
        emit_session_context("")
        sys.exit(0)
