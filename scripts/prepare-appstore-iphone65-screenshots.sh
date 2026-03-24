#!/bin/bash
# Resize/crop portrait iPhone Simulator screenshots to App Store Connect
# "iPhone 6.5-inch Display" size: 1284 x 2778 (portrait).
#
# Use FULL-resolution captures: Simulator → File → Save Screen Shot (⌘S).
# Do NOT use scaled previews or images recompressed through chat apps.
#
# Usage:
#   ./scripts/prepare-appstore-iphone65-screenshots.sh [input.png ...]
#   ./scripts/prepare-appstore-iphone65-screenshots.sh ~/Desktop/*.png
#
# Outputs go to AppStore/Screenshots/for-app-store-connect-1284x2778/ (numbered names; rename if needed).

set -euo pipefail

TW=1284
TH=2778
OUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/AppStore/Screenshots/for-app-store-connect-1284x2778"
mkdir -p "$OUT_DIR"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <png ...>" >&2
  echo "Example: $0 ~/Desktop/Simulator\\ Screenshot*.png" >&2
  exit 1
fi

n=1
for in_path in "$@"; do
  [[ -f "$in_path" ]] || { echo "Skip (not a file): $in_path" >&2; continue; }

  W=$(sips -g pixelWidth "$in_path" 2>/dev/null | awk '/pixelWidth/{print $2}')
  H=$(sips -g pixelHeight "$in_path" 2>/dev/null | awk '/pixelHeight/{print $2}')
  if [[ -z "$W" || -z "$H" ]]; then
    echo "Skip (could not read): $in_path" >&2
    continue
  fi

  if (( W > H )); then
    echo "Skip (not portrait): $in_path (${W}x${H})" >&2
    continue
  fi

  tmp=$(mktemp -t appstore_screenshot).png
  cp "$in_path" "$tmp"

  # Fit width to TW (keeps aspect ratio). Force real PNG — sips otherwise may write JPEG while using a .png path.
  sips -s format png --resampleWidth "$TW" "$tmp" -o "$tmp" >/dev/null
  NH=$(sips -g pixelHeight "$tmp" 2>/dev/null | awk '/pixelHeight/{print $2}')

  out_file="$OUT_DIR/$(printf '%02d' "$n")-appstore-1284x2778.png"

  if (( NH > TH )); then
    off=$(( (NH - TH) / 2 ))
    sips -s format png -c "$TH" "$TW" --cropOffset "$off" 0 "$tmp" -o "$out_file" >/dev/null
  elif (( NH < TH )); then
    sips -s format png -p "$TH" "$TW" --padColor FFFFFF "$tmp" -o "$out_file" >/dev/null
  else
    sips -s format png "$tmp" -o "$out_file" >/dev/null
  fi

  rm -f "$tmp"
  echo "$out_file  (from ${W}x${H})"
  n=$((n + 1))
done

echo "Done. Upload PNGs from: $OUT_DIR"
