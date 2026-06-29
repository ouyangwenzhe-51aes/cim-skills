#!/usr/bin/env python3
"""
Check and update script - cross-platform replacement for
check-and-update.ps1 / check-and-update.sh.

Usage: python check-and-update.py [--destination-path <path>]
       Falls back to PLUGIN_ROOT environment variable when --destination-path
       is omitted.
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

SCRIPT_DIR = Path(__file__).parent
OUTDATED_SCRIPT = SCRIPT_DIR / "outdated.py"
UPDATE_SCRIPT = SCRIPT_DIR / "update-version.py"
NOTICE_TITLE = "\u26a0\ufe0f cim-skills \u5df2\u81ea\u52a8\u66f4\u65b0\u81f3\u6700\u65b0\u7248\u672c\uff0c\u8bf7\u91cd\u542f\u8fdb\u7a0b\u4ee5\u4f7f\u7528\u3002"


def parse_args() -> str:
    parser = argparse.ArgumentParser(
        description="Check for cim-skills updates and install if needed."
    )
    parser.add_argument(
        "--destination-path",
        default=os.environ.get("PLUGIN_ROOT", ""),
        help="Destination directory (defaults to PLUGIN_ROOT env var)",
    )
    return parser.parse_args().destination_path.strip()


def run_child_script(script_path: Path, destination_path: str = "") -> tuple[int, str]:
    command = [sys.executable, str(script_path)]
    if destination_path:
        command.extend(["--destination-path", destination_path])

    result = subprocess.run(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
    )
    return result.returncode, result.stdout or ""


def emit_session_start(additional_context: str) -> None:
    payload = {
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": additional_context,
        }
    }
    print(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))


def main() -> int:
    destination_path = parse_args()

    check_exit_code, check_output = run_child_script(OUTDATED_SCRIPT)

    if check_exit_code == 99:
        update_exit_code, _update_output = run_child_script(
            UPDATE_SCRIPT,
            destination_path,
        )

        if update_exit_code == 0:
            additional_context = (
                "IMPORTANT:\n"
                "        1. Start the reply with the following notice:\n\n"
                f"\t\t{NOTICE_TITLE}\n\n"
                "        2. Only include this notice in the first assistant response of the session.\n"
                "        Do not repeat it afterwards."
            )
        else:
            additional_context = f"cim-skills update failed with exit code {update_exit_code}"

        emit_session_start(additional_context)
        return update_exit_code

    if check_output:
        print(check_output, end="")

    return check_exit_code


if __name__ == "__main__":
    sys.exit(main())
