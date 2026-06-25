#!/usr/bin/env bash

set -euo pipefail

DESTINATION_PATH="${PLUGIN_ROOT:-}"
DOWNLOAD_URL="https://github.com/ouyangwenzhe-51aes/cim-skills/archive/refs/heads/main.zip"

usage() {
	cat <<'EOF'
Usage: update-version.sh [--destination-path <path>]
EOF
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		--destination-path)
			DESTINATION_PATH="${2:-}"
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

if [[ -z "${DESTINATION_PATH// }" ]]; then
	echo "Error: DestinationPath is not provided and PLUGIN_ROOT is not set" >&2
	exit 1
fi

TMP_ROOT="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"
ZIP_FILE="$TMP_ROOT/cim-skills-main.zip"
EXTRACT_DIR="$TMP_ROOT/cim-skills-main"

download_zip() {
	if command -v curl >/dev/null 2>&1; then
		curl -fL --retry 2 --connect-timeout 20 "$DOWNLOAD_URL" -o "$ZIP_FILE"
		return
	fi

	if command -v wget >/dev/null 2>&1; then
		wget -O "$ZIP_FILE" "$DOWNLOAD_URL"
		return
	fi

	echo "Error: neither curl nor wget is available for download" >&2
	exit 1
}

extract_zip() {
	rm -rf "$EXTRACT_DIR"

	if command -v unzip >/dev/null 2>&1; then
		unzip -q -o "$ZIP_FILE" -d "$TMP_ROOT"
		return
	fi

	if command -v bsdtar >/dev/null 2>&1; then
		bsdtar -xf "$ZIP_FILE" -C "$TMP_ROOT"
		return
	fi

	echo "Error: neither unzip nor bsdtar is available for extraction" >&2
	exit 1
}

echo "Starting download..."
download_zip
echo "Download completed: $ZIP_FILE"

echo "Starting extraction..."
extract_zip
echo "Extraction completed"

if [[ ! -d "$EXTRACT_DIR" ]]; then
	echo "Error: extracted directory does not exist or is not a directory" >&2
	exit 1
fi

echo "Installing to destination: $DESTINATION_PATH"
mkdir -p "$DESTINATION_PATH"
find "$DESTINATION_PATH" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

shopt -s dotglob nullglob
items=("$EXTRACT_DIR"/*)
if (( ${#items[@]} > 0 )); then
	mv "${items[@]}" "$DESTINATION_PATH"/
fi
shopt -u dotglob nullglob

rm -rf "$EXTRACT_DIR"
echo "Install completed"

rm -f "$ZIP_FILE"
echo "Temporary files cleaned"
echo "All operations completed"
