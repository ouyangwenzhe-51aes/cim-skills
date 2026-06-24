#!/usr/bin/env bash

set -euo pipefail

PLUGIN_NAME="cimapi-skills"
OWNER="ouyangwenzhe-51aes"
REPO="cim-skills"
BRANCH="main"
MARKETPLACE_PATH=".cursor-plugin/marketplace.json"
INSTALL_ROOT=""

usage() {
	cat <<'EOF'
Usage: outdated.sh [options]

Options:
  --plugin-name <name>       Plugin name (default: cimapi-skills)
  --owner <name>             Repository owner (default: ouyangwenzhe-51aes)
  --repo <name>              Repository name (default: cim-skills)
  --branch <name>            Branch name (default: main)
  --marketplace-path <path>  Marketplace json path in repo (default: .cursor-plugin/marketplace.json)
  --install-root <path>      Local install root (default: $HOME/.vscode/agent-plugins/github.com)
  -h, --help                 Show this help
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--plugin-name)
			PLUGIN_NAME="${2:-}"
			shift 2
			;;
		--owner)
			OWNER="${2:-}"
			shift 2
			;;
		--repo)
			REPO="${2:-}"
			shift 2
			;;
		--branch)
			BRANCH="${2:-}"
			shift 2
			;;
		--marketplace-path)
			MARKETPLACE_PATH="${2:-}"
			shift 2
			;;
		--install-root)
			INSTALL_ROOT="${2:-}"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			usage
			exit 1
			;;
	esac
done

if [[ -z "${INSTALL_ROOT// }" ]]; then
	HOME_DIR="${USERPROFILE:-${HOME:-}}"
	if [[ -z "${HOME_DIR// }" ]]; then
		echo "Cannot determine home directory. Pass --install-root explicitly." >&2
		exit 1
	fi
	INSTALL_ROOT="$HOME_DIR/.vscode/agent-plugins/github.com"
fi

detect_host() {
	local payload="${1:-}"
	if [[ "${COPILOT_CLI:-}" == "1" ]]; then
		echo "copilot-cli"
		return
	fi
	if [[ "$payload" == *'"toolArgs"'* && "$payload" != *'"hook_event_name"'* ]]; then
		echo "copilot-cli"
		return
	fi
	if [[ "$payload" == *'"hook_event_name"'* ]]; then
		if [[ "$payload" == *'__vscode'* ]] || [[ "$payload" =~ \"transcript_path\"[^"]*\"[^"]*Code ]]; then
			echo "vscode"
			return
		fi
		echo "claude-code"
		return
	fi
	if [[ -n "${CURSOR_PLUGIN_ROOT:-}" ]]; then
		echo "cursor"
		return
	fi
	echo "unknown"
}

parse_semver() {
	local version="$1"
	local re='^([0]|[1-9][0-9]*)\.([0]|[1-9][0-9]*)\.([0]|[1-9][0-9]*)(-([0-9A-Za-z.-]+))?(\+[0-9A-Za-z.-]+)?$'
	if [[ ! "$version" =~ $re ]]; then
		echo "Invalid semver: $version" >&2
		return 1
	fi

	local major="${BASH_REMATCH[1]}"
	local minor="${BASH_REMATCH[2]}"
	local patch="${BASH_REMATCH[3]}"
	local prerelease="${BASH_REMATCH[5]:-}"
	printf '%s|%s|%s|%s\n' "$major" "$minor" "$patch" "$prerelease"
}

compare_prerelease() {
	local a="${1:-}"
	local b="${2:-}"

	if [[ -z "$a" && -z "$b" ]]; then
		echo 0
		return
	fi
	if [[ -z "$a" ]]; then
		echo 1
		return
	fi
	if [[ -z "$b" ]]; then
		echo -1
		return
	fi

	local a_parts b_parts
	IFS='.' read -r -a a_parts <<< "$a"
	IFS='.' read -r -a b_parts <<< "$b"

	local max="${#a_parts[@]}"
	if (( ${#b_parts[@]} > max )); then
		max="${#b_parts[@]}"
	fi

	local i
	for (( i=0; i<max; i++ )); do
		if (( i >= ${#a_parts[@]} )); then
			echo -1
			return
		fi
		if (( i >= ${#b_parts[@]} )); then
			echo 1
			return
		fi

		local a_part="${a_parts[i]}"
		local b_part="${b_parts[i]}"

		if [[ "$a_part" =~ ^[0-9]+$ && "$b_part" =~ ^[0-9]+$ ]]; then
			if (( 10#$a_part < 10#$b_part )); then
				echo -1
				return
			fi
			if (( 10#$a_part > 10#$b_part )); then
				echo 1
				return
			fi
			continue
		fi

		if [[ "$a_part" =~ ^[0-9]+$ && ! "$b_part" =~ ^[0-9]+$ ]]; then
			echo -1
			return
		fi
		if [[ ! "$a_part" =~ ^[0-9]+$ && "$b_part" =~ ^[0-9]+$ ]]; then
			echo 1
			return
		fi

		if [[ "$a_part" < "$b_part" ]]; then
			echo -1
			return
		fi
		if [[ "$a_part" > "$b_part" ]]; then
			echo 1
			return
		fi
	done

	echo 0
}

compare_semver() {
	local left="$1"
	local right="$2"

	local left_parsed right_parsed
	left_parsed="$(parse_semver "$left")" || return 1
	right_parsed="$(parse_semver "$right")" || return 1

	local l_major l_minor l_patch l_pre
	local r_major r_minor r_patch r_pre
	IFS='|' read -r l_major l_minor l_patch l_pre <<< "$left_parsed"
	IFS='|' read -r r_major r_minor r_patch r_pre <<< "$right_parsed"

	if (( l_major < r_major )); then echo -1; return; fi
	if (( l_major > r_major )); then echo 1; return; fi
	if (( l_minor < r_minor )); then echo -1; return; fi
	if (( l_minor > r_minor )); then echo 1; return; fi
	if (( l_patch < r_patch )); then echo -1; return; fi
	if (( l_patch > r_patch )); then echo 1; return; fi

	compare_prerelease "$l_pre" "$r_pre"
}

json_field_from_file() {
	local file="$1"
	local field="$2"

	if command -v jq >/dev/null 2>&1; then
		jq -r --arg f "$field" '.[$f] // empty' "$file" 2>/dev/null || true
		return
	fi

	if command -v python3 >/dev/null 2>&1; then
		python3 - "$file" "$field" <<'PY'
import json
import sys
path, key = sys.argv[1], sys.argv[2]
try:
	with open(path, 'r', encoding='utf-8') as f:
		data = json.load(f)
	value = data.get(key, '')
	if isinstance(value, (str, int, float)):
		print(value)
except Exception:
	pass
PY
		return
	fi

	if command -v python >/dev/null 2>&1; then
		python - "$file" "$field" <<'PY'
import json
import sys
path, key = sys.argv[1], sys.argv[2]
try:
	with open(path, 'r', encoding='utf-8') as f:
		data = json.load(f)
	value = data.get(key, '')
	if isinstance(value, (str, int, float)):
		print(value)
except Exception:
	pass
PY
		return
	fi

	sed -n -E "s/.*\"${field}\"[[:space:]]*:[[:space:]]*\"([^\"]*)\".*/\\1/p" "$file" | head -n 1
}

plugin_version_from_marketplace() {
	local file="$1"
	local plugin="$2"

	if command -v jq >/dev/null 2>&1; then
		jq -r --arg n "$plugin" '.plugins[]? | select(.name == $n) | .version // empty' "$file" 2>/dev/null | head -n 1
		return
	fi

	if command -v python3 >/dev/null 2>&1; then
		python3 - "$file" "$plugin" <<'PY'
import json
import sys
path, name = sys.argv[1], sys.argv[2]
try:
	with open(path, 'r', encoding='utf-8') as f:
		data = json.load(f)
	for item in data.get('plugins', []):
		if item.get('name') == name:
			print(item.get('version', ''))
			break
except Exception:
	pass
PY
		return
	fi

	if command -v python >/dev/null 2>&1; then
		python - "$file" "$plugin" <<'PY'
import json
import sys
path, name = sys.argv[1], sys.argv[2]
try:
	with open(path, 'r', encoding='utf-8') as f:
		data = json.load(f)
	for item in data.get('plugins', []):
		if item.get('name') == name:
			print(item.get('version', ''))
			break
except Exception:
	pass
PY
		return
	fi

	echo ""
}

get_installed_version() {
	local root="$1"
	local plugin="$2"
	local owner_name="$3"
	local repo_name="$4"

	if [[ ! -d "$root" ]]; then
		return 1
	fi

	local first_match=""
	local preferred_match=""

	while IFS= read -r -d '' file; do
		local name version
		name="$(json_field_from_file "$file" "name")"
		version="$(json_field_from_file "$file" "version")"
		if [[ "$name" == "$plugin" && -n "$version" ]]; then
			local pair
			pair="$version|$file"
			if [[ -z "$first_match" ]]; then
				first_match="$pair"
			fi
			case "$file" in
				*/"$owner_name"/"$repo_name"/plugin.json)
					preferred_match="$pair"
					break
					;;
			esac
		fi
	done < <(find "$root" -type f -name 'plugin.json' -print0 2>/dev/null)

	if [[ -n "$preferred_match" ]]; then
		printf '%s\n' "$preferred_match"
		return 0
	fi
	if [[ -n "$first_match" ]]; then
		printf '%s\n' "$first_match"
		return 0
	fi

	return 1
}

json_escape() {
	local value="${1:-}"
	value="${value//\\/\\\\}"
	value="${value//\"/\\\"}"
	value="${value//$'\r'/\\r}"
	value="${value//$'\n'/\\n}"
	value="${value//$'\t'/\\t}"
	printf '%s' "$value"
}

emit_session_context() {
	local message="${1:-}"
	printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$(json_escape "$message")"
}

if ! command -v curl >/dev/null 2>&1; then
	emit_session_context ""
	exit 0
fi

remote_url="https://raw.githubusercontent.com/$OWNER/$REPO/$BRANCH/$MARKETPLACE_PATH"

if ! installed_pair="$(get_installed_version "$INSTALL_ROOT" "$PLUGIN_NAME" "$OWNER" "$REPO")"; then
	emit_session_context ""
	exit 0
fi

local_version="${installed_pair%%|*}"
installed_source="${installed_pair#*|}"

tmp_marketplace="$(mktemp 2>/dev/null || printf '%s' '/tmp/cim-marketplace.json')"
cleanup_tmp=0
if [[ "$tmp_marketplace" == "/tmp/cim-marketplace.json" ]]; then
	cleanup_tmp=1
fi

if ! curl -fsSL --max-time 20 "$remote_url" -o "$tmp_marketplace"; then
	rm -f "$tmp_marketplace" 2>/dev/null || true
	emit_session_context ""
	exit 0
fi

latest_version="$(plugin_version_from_marketplace "$tmp_marketplace" "$PLUGIN_NAME")"
if [[ $cleanup_tmp -eq 1 ]]; then
	rm -f "$tmp_marketplace" 2>/dev/null || true
else
	rm -f "$tmp_marketplace"
fi

if [[ -z "$latest_version" ]]; then
	emit_session_context ""
	exit 0
fi

cmp="$(compare_semver "$local_version" "$latest_version")"

if [[ "$cmp" == "-1" ]]; then
	message="IMPORTANT:

        The installed cim-skills plugin is outdated.

        For the first response in this session:

        1. Start the reply with the following notice:

        ⚠️ cim-skills 有新版本可用

        当前版本: $localVersion
        最新版本: $latestVersion

        请更新至 cimapi-skills v$latestVersion

        2. Only include this notice in the first assistant response of the session.
        Do not repeat it afterwards."
	emit_session_context "$message"
	exit 0
fi

if [[ "$cmp" == "0" ]]; then
	emit_session_context ""
	exit 0
fi

emit_session_context ""
exit 0
