#!/usr/bin/env sh
set -eu

# Usage:
#   DATA_URL="https://github.com/midl-xyz/bitcoin-asia-bitcoind/releases/download/v1.0/bitcoin-regtest-data.tar.gz" \
#   ./download-regtest.sh /data
# If private release, export GITHUB_TOKEN first.

OUT_DIR="${1:-/data}"
URL="${DATA_URL:-}"

if [ -z "$URL" ]; then
  echo "Set GITHUB_RELEASE_URL to the release asset URL (see README)"
  exit 2
fi

# Quick check: skip download if chainstate/blocks present
if [ -d "$OUT_DIR/blocks" ] || [ -d "$OUT_DIR/chainstate" ]; then
  echo "Existing data detected in $OUT_DIR — skipping download."
  exit 0
fi

TMP_TAR="/tmp/regtest-data.tar.gz"

echo "Downloading regtest data from: $URL"
if [ -n "${GITHUB_TOKEN:-}" ]; then
  # authenticated download (private release)
  curl -L --fail -H "Authorization: token ${GITHUB_TOKEN}" -o "$TMP_TAR" "$URL"
else
  curl -L --fail -o "$TMP_TAR" "$URL"
fi

echo "Extracting to $OUT_DIR"
mkdir -p "$OUT_DIR"
tar -xzf "$TMP_TAR" -C "$OUT_DIR"
rm -f "$TMP_TAR"

echo "Done."