# Resume Builder Template

Build a polished, ATS-friendly resume as styled HTML that converts to PDF, driven
by [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Keep a single
master bank of your career history, then generate a tailored CV, cover letter, and
interview prep pack per job application, each archived in its own folder.

This is a **template**. It ships with fictional example content so you can see the
shape of everything before you put your own details in. Nothing here is anyone's
real resume.

## Credit

Forked from and built on top of
[adamenger/claude-resume-builder](https://github.com/adamenger/claude-resume-builder),
which provides the original concept, the themed HTML to PDF build, and the ATS and
accessibility checks. Thanks to the author.

Added on top of the original:

- a master resume bank (`resumes/master.txt`) as the single source of truth, with
  framing variants and situational bullets
- a job-spec-driven tailored build that selects from the bank rather than inventing
  content
- per-application archive folders (`applications/<company>-<role>/`) holding the
  resume, PDF, job spec, cover letter, and interview prep for that role
- an optional cover letter workflow with a matching PDF build
- interview prep generation against a cumulative SOAR story bank and question bank
- theme presets under `themes/`

The upstream repository does not publish a license file, so no license is asserted
here. If you plan to redistribute this publicly, check with the original author first.

## Quick Start

### Prerequisites

- [Google Chrome](https://www.google.com/chrome/) or Chromium (headless PDF generation)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- Python 3 with `pyyaml` and `pypdf` (`pip install pyyaml pypdf`)
- Node.js (for `npx pa11y` accessibility testing)

### See it work first

```bash
cp examples/resume.example.html resume.html
make build && make test
```

That produces `resume.pdf` from the example persona and runs the accessibility and
ATS checks, confirming your toolchain is set up.

### Then make it yours

```bash
claude
```

Tell Claude to replace the example content. It will walk you through your details
and write them into `resumes/master.txt`, or you can paste in an existing resume and
have it converted. Everything downstream reads from that bank.

### Tailor to a specific job

```bash
cp examples/job-spec.example.txt job-spec.txt   # or paste a real posting in
claude
```

Ask for a tailored resume. Claude reads the posting, selects the closest-matching
bullets from your master bank, rephrases them in the posting's own language where
that is a genuine match, flags real gaps rather than papering over them, and archives
the result to `applications/<company>-<role>/`.

## Commands

```bash
make build                      # Apply theme + generate resume.pdf
make test                       # WCAG (pa11y) + ATS parsability checks
make open                       # Build and open the PDF
make archive SLUG=<slug>        # Rebuild and archive the PDF into applications/<slug>/
make cover-letter CL=<slug>     # Render applications/<slug>/cover-letter.html to PDF
make clean                      # Remove transient PDFs
```

## Customization

Edit `config.yaml` to change the theme, then `make build`:

```yaml
theme:
  bg: "#ffffff"        # background color
  text: "#1a1a1a"      # body text
  muted: "#595959"     # secondary text
  accent: "#2456a6"    # headings, links, highlights
  border: "#d0d0d0"    # divider lines
  code_bg: "#f5f5f5"   # profile block background
  bright: "#0d0d0d"    # names, job titles
  font: "'Georgia', 'Times New Roman', serif"
  font_import: ""      # Google Fonts URL, if the font needs one
  padding: "0.5in 0.6in"
```

`themes/` holds drop-in presets: `cp themes/dark.yaml config.yaml` for the original
dark terminal look, `themes/light.yaml` for the light serif default.

If you change the theme, re-run `make test`. Contrast is part of the accessibility
check, so a low-contrast palette will fail.

## How It Works

1. `apply_theme.py` reads `config.yaml` and injects theme values into a temp copy of `resume.html`
2. `build.sh` runs headless Chrome to convert the themed HTML to PDF
3. `test_ats.py` verifies the PDF is parseable by applicant tracking systems
4. `npx pa11y` checks WCAG accessibility compliance

## Project Structure

```
CLAUDE.md              # Instructions Claude Code follows (workflows live here)
config.yaml            # Active theme
themes/                # Theme presets
resumes/master.txt     # Your full career bank, the source of truth
interview-prep/        # Cumulative SOAR story bank + question bank
applications/          # One folder per job application (see its README)
examples/              # Example resume markup + example job spec
apply_theme.py         # Applies config.yaml theme to HTML
build.sh               # Headless Chrome PDF generation
build_cover_letter.sh  # Cover letter PDF generation
test_ats.py            # ATS parsability tests
Makefile               # Build commands
resume.html            # Working file, generated (gitignored)
resume.pdf             # Working file, generated (gitignored)
job-spec.txt           # Working file, the posting being tailored to (gitignored)
```

## A Note on Honesty

The workflows in `CLAUDE.md` are deliberately strict about this: tailoring may only
select, reorder, and rephrase what is already in `resumes/master.txt`. It will not
invent achievements, metrics, tools, or stories, and it flags genuine gaps against a
job spec instead of hiding them behind vague language. Everything on the CV should be
something you can defend in an interview.
