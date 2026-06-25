#!/usr/bin/env bash

set -euo pipefail

DESTINATION_PATH="${PLUGIN_ROOT:-}"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--destination-path)
			DESTINATION_PATH="${2:-}"
			shift 2
			;;
		-h|--help)
			cat <<'EOF'
Usage: check-and-update.sh [--destination-path <path>]
EOF
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			exit 1
			;;
	esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDATED_SCRIPT="$SCRIPT_DIR/outdated.sh"
UPDATE_SCRIPT="$SCRIPT_DIR/update-version.sh"

NOTICE_TITLE="⚠️ cim-skills 已自动更新至最新版本，请重启进程以使用。"

json_escape() {
	local s="${1:-}"
	s="${s//\\/\\\\}"
	s="${s//\"/\\\"}"
	s="${s//$'\n'/\\n}"
	s="${s//$'\r'/\\r}"
	s="${s//$'\t'/\\t}"
	printf '%s' "$s"
}

emit_sessionstart_json() {
	local additional_context="${1:-}"
	printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$(json_escape "$additional_context")"
}

run_child_script() {
	local script_path="$1"
	local destination="${2:-}"

	if [[ -z "${destination// }" ]]; then
		bash "$script_path"
	else
		bash "$script_path" --destination-path "$destination"
	fi
}

set +e
check_output="$(run_child_script "$OUTDATED_SCRIPT" 2>&1)"
check_exit_code=$?
set -e

if [[ $check_exit_code -eq 99 ]]; then
	set +e
	update_output="$(run_child_script "$UPDATE_SCRIPT" "$DESTINATION_PATH" 2>&1)"
	update_exit_code=$?
	set -e

	if [[ $update_exit_code -eq 0 ]]; then
		additional_context="IMPORTANT:
        1. Start the reply with the following notice:

		$NOTICE_TITLE

        2. Only include this notice in the first assistant response of the session.
        Do not repeat it afterwards."
	else
		additional_context="cim-skills update failed with exit code $update_exit_code"
	fi

	emit_sessionstart_json "$additional_context"
	exit $update_exit_code
fi

if [[ -n "${check_output// }" ]]; then
	echo "$check_output"
fi

exit $check_exit_code
