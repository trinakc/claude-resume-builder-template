#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
THEMED="$DIR/.resume_themed.html"

# Apply theme from config.yaml
python3 "$DIR/apply_theme.py"

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
  # Fall back to a Chrome downloaded by puppeteer (e.g. via pa11y install)
  local puppet
  puppet="$(find "$HOME/.cache/puppeteer" -type f -name chrome 2>/dev/null | sort | tail -1)"
  [ -n "$puppet" ] && { echo "$puppet"; return 0; }
  return 1
}

CHROME_BIN="$(find_chrome)" || {
  echo "Error: no Chrome/Chromium binary found. Set CHROME=/path/to/chrome." >&2
  exit 1
}

# Generate PDF from themed HTML
"$CHROME_BIN" \
  --headless \
  --disable-gpu \
  --no-pdf-header-footer \
  --print-to-pdf="$DIR/resume.pdf" \
  "$THEMED"

# Clean up temp file
rm -f "$THEMED"

echo "Built: $DIR/resume.pdf"
