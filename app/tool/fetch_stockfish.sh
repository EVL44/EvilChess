#!/usr/bin/env bash
# Downloads the official Stockfish binary for desktop builds into app/engines/<os>/.
# Usage: tool/fetch_stockfish.sh [windows|linux|macos]   (defaults to the current OS)
# Stockfish is GPL-3.0; see https://stockfishchess.org. The binary is not committed.
set -euo pipefail

VERSION="sf_19"
BASE="https://github.com/official-stockfish/Stockfish/releases/download/${VERSION}"

os="${1:-}"
if [[ -z "$os" ]]; then
  case "$(uname -s)" in
    Linux*) os=linux ;;
    Darwin*) os=macos ;;
    MINGW*|MSYS*|CYGWIN*) os=windows ;;
    *) echo "Unknown OS, pass windows|linux|macos" >&2; exit 1 ;;
  esac
fi

case "$os" in
  windows) asset="stockfish-windows-x86-64-universal.zip"; exe="stockfish.exe" ;;
  linux)   asset="stockfish-linux-x86-64-universal.tar.gz"; exe="stockfish" ;;
  macos)   asset="stockfish-macos-universal.tar.gz"; exe="stockfish" ;;
  *) echo "Unsupported OS: $os" >&2; exit 1 ;;
esac

here="$(cd "$(dirname "$0")/.." && pwd)"
dest="$here/engines/$os"
if [[ -f "$dest/$exe" ]]; then
  echo "Stockfish already present at $dest/$exe"; exit 0
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
echo "Downloading $asset ($VERSION)..."
curl -fsSL -o "$tmp/$asset" "$BASE/$asset"
mkdir -p "$tmp/x"
tar -xf "$tmp/$asset" -C "$tmp/x"

# The archive holds one engine binary named stockfish-<os>-...; pick it.
bin="$(find "$tmp/x" -type f -name 'stockfish*' ! -name '*.txt' ! -name '*.md' | head -n1)"
if [[ -z "$bin" ]]; then echo "No binary found in $asset" >&2; exit 1; fi

mkdir -p "$dest"
cp "$bin" "$dest/$exe"
chmod +x "$dest/$exe"
copying="$(find "$tmp/x" -type f -iname 'Copying.txt' | head -n1 || true)"
if [[ -n "$copying" ]]; then cp "$copying" "$dest/COPYING-stockfish.txt"; fi
echo "Installed $dest/$exe"
