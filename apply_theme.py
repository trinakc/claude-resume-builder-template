#!/usr/bin/env python3
"""Apply config.yaml theme to an HTML file, writing a themed temp file.

Usage: apply_theme.py [INPUT] [OUTPUT]
Defaults to resume.html -> .resume_themed.html so the resume build is unchanged.
Cover letters pass their own paths, e.g.
    apply_theme.py cover-letters/foo.html .cover_letter_themed.html
"""
import re
import sys
import yaml

CONFIG = "config.yaml"
INPUT = sys.argv[1] if len(sys.argv) > 1 else "resume.html"
OUTPUT = sys.argv[2] if len(sys.argv) > 2 else ".resume_themed.html"


def main():
    with open(CONFIG) as f:
        config = yaml.safe_load(f)

    theme = config["theme"]

    # Build the @import and :root block
    font_import = f"  @import url('{theme['font_import']}');"
    root_lines = [
        f"    --bg: {theme['bg']};",
        f"    --text: {theme['text']};",
        f"    --muted: {theme['muted']};",
        f"    --accent: {theme['accent']};",
        f"    --border: {theme['border']};",
        f"    --code-bg: {theme['code_bg']};",
        f"    --bright: {theme['bright']};",
        f"    --font: {theme['font']};",
    ]
    root_block = "  :root {\n" + "\n".join(root_lines) + "\n  }"

    with open(INPUT) as f:
        html = f.read()

    # Replace @import url(...)
    html = re.sub(
        r"@import url\([^)]+\);",
        f"@import url('{theme['font_import']}');",
        html,
    )

    # Replace :root { ... }
    html = re.sub(
        r":root\s*\{[^}]+\}",
        root_block,
        html,
    )

    # Replace body padding
    html = re.sub(
        r"(body\s*\{[^}]*?)padding:\s*[^;]+;",
        rf"\1padding: {theme['padding']};",
        html,
    )

    with open(OUTPUT, "w") as f:
        f.write(html)

    print(f"Themed: {OUTPUT}")


if __name__ == "__main__":
    main()
