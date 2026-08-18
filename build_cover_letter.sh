#!/usr/bin/env bash
set -euo pipefail

# Render a cover letter HTML to PDF using the config.yaml theme.
# Usage: ./build_cover_letter.sh <slug>
#   where applications/<slug>/cover-letter.html exists;
#   output is applications/<slug>/cover-letter.pdf

DIR="$(cd "$(dirname "$0")" && pwd)"

SLUG="${1:-}"
if [ -z "$SLUG" ]; then
  echo "Usage: ./build_cover_letter.sh <slug>  (expects applications/<slug>/cover-letter.html)" >&2
  exit 1
fi

SRC="$DIR/applications/$SLUG/cover-letter.html"
OUT="$DIR/applications/$SLUG/cover-letter.pdf"
THEMED="$DIR/.cover_letter_themed.html"

if [ ! -f "$SRC" ]; then
  echo "Error: $SRC not found. Generate the styled HTML first." >&2
  exit 1
fi

# Apply theme from config.yaml (same theme as the resume)
python3 "$DIR/apply_theme.py" "$SRC" "$THEMED"

# Locate a Chrome/Chromium binary across platforms
find_chrome() {
  local candidates=(
    "${CHROME:-}"
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "$(command -v google-chrome 2>/dev/null || true)"
    "$(command -v google-chrome-stable 2>/dev/null || true)"
    "$(command -v chromium 2>/dev/null || true)"
    "$(command -v chromium-browser 2>/dev/null || true)"
  )
  for c in "${candidates[@]}"; do
    [ -n "$c" ] && [ -x "$c" ] && { echo "$c"; return 0; }
  done
  local puppet
  puppet="$(find "$HOME/.cache/puppeteer" -type f -name chrome 2>/dev/null | sort | tail -1)"
  [ -n "$puppet" ] && { echo "$puppet"; return 0; }
  return 1
}

CHROME_BIN="$(find_chrome)" || {
  echo "Error: no Chrome/Chromium binary found. Set CHROME=/path/to/chrome." >&2
  exit 1
}

"$CHROME_BIN" \
  --headless \
  --disable-gpu \
  --no-pdf-header-footer \
  --print-to-pdf="$OUT" \
  "$THEMED"

rm -f "$THEMED"

echo "Built: $OUT"
