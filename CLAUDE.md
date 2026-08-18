# Claude Resume Builder

You are helping the user build a professional resume as a styled HTML page that converts to PDF, tailored to a specific job when a job spec is provided.

## Getting Started

**First run in a fresh clone:** `resumes/master.txt`, `interview-prep/story-bank.txt`,
and `interview-prep/question-bank.txt` ship with clearly marked fictional example
content (the "Alex Rivera" persona) so a new user can see the expected structure.
If a file still carries its `[EXAMPLE — REPLACE WITH YOUR OWN]` marker, treat it as
empty: never tailor a resume from the example persona, and never mix example content
with the user's real content. Offer to replace it with their real information instead.
`examples/resume.example.html` is the canonical markup reference for a generated
`resume.html`; `examples/job-spec.example.txt` is a sample posting for trying out the
tailored build.

1. Check for `job-spec.txt` in the root — if present, this run is a **tailored build** (see Tailored Workflow below)
2. If no `job-spec.txt`, check for `resumes/master.txt` — use it as the general-purpose source (unless it is still the example, see above)
3. If neither exists, ask the user for their information interactively:
   - Name, contact info, links
   - Professional summary
   - Skills (grouped by category)
   - Work experience (company, title, dates, bullet points)
   - Notable projects or highlights
   - Recognition, certifications, publications
4. Generate `resume.html` using the template structure below and theme values from `config.yaml`

## Directory Layout

Artifacts are grouped **per application** so everything for one role sits
together and is easy to pull up when an interview is scheduled. Each tailored
build creates or updates `applications/<company>-<role>/` (slug lowercase,
hyphenated, the same slug used across every artifact for that role):

```
applications/<company>-<role>/
  job-spec.txt        verbatim copy of the posting (archived every tailored build)
  resume.txt          plain-text tailored resume content
  resume.pdf          tracked, version-controlled PDF (via `make archive`)
  cover-letter.txt    optional, only when a cover letter is requested
  cover-letter.html   optional, styled source for the cover-letter PDF
  cover-letter.pdf    optional, gitignored (regenerable from the .html)
  interview-prep.txt  optional, per-role question -> story mapping
```

Two resources stay **global**, shared across all applications, and never move
into an application folder:
- `resumes/master.txt` — the career bank every tailored build draws from
- `interview-prep/story-bank.txt` and `interview-prep/question-bank.txt` —
  cumulative across all interviews

The root `resume.html`, `resume.pdf`, `resume.txt`, and `job-spec.txt` are
transient working files (gitignored); the archived copies under
`applications/<slug>/` are the durable record.

## Resume Bank

`resumes/master.txt` is the single source of truth for the user's full career history — every role, every bullet point, every framing variant they've ever used, unfiltered. It is never trimmed or overwritten by a tailored build; it only grows over time as the user adds new achievements or framing options.

Where `master.txt` contains multiple framing options for the same underlying achievement (marked "Option A / B / C" or "variant"), treat these as deliberate alternatives for different audiences, not duplicates to merge — pick the one that best matches the target role's emphasis, and never blend two framings into one bullet.

Where a bullet is marked "situational," only include it if the job spec specifically calls for that skill or tooling — don't include it by default.

Files named `applications/<company>-<role>/resume.txt` are past tailored outputs, saved automatically at the end of each tailored build (see step 6 below). These are historical record only — never read from them as a source; `master.txt` is always authoritative.

## Tailored Workflow (when `job-spec.txt` is present)

1. Read `job-spec.txt` in full — extract the role title, company, required skills, and key responsibilities
2. Read `resumes/master.txt` in full — this is the complete pool of real experience to draw from
3. Match relevant bullets from `master.txt` against the job spec:
   - Prioritize bullets whose skills/impact most closely match the job spec's language
   - Never invent achievements, metrics, or skills not present in `master.txt` — only select, reorder, and rephrase for relevance
   - If there's a genuine gap between the job spec and the master bank, flag it to the user rather than papering over it with vague language
4. Rephrase selected bullets using the job spec's own terminology where it's a true match (not keyword-stuffing)
5. Generate `resume.html` following the template structure below
6. Save a plain-text copy of the tailored content to `applications/<company>-<role>/resume.txt` (slugify company and role from the job spec, lowercase, hyphenated — e.g. `applications/acme-delivery-manager/resume.txt`). Create the application folder if it does not exist. If `resume.txt` already exists there, ask before overwriting.
7. Archive the job spec itself, under version control, to `applications/<company>-<role>/job-spec.txt` (same slug / same folder) — copy the root `job-spec.txt` verbatim (do not edit or summarise it) so the exact posting is available later for interview prep. If `job-spec.txt` already exists there, ask before overwriting.
8. Archive the PDF into the same folder, under version control. After building (step 9 below), run `make archive SLUG=<company>-<role>` using the **same slug** — this rebuilds and copies `resume.pdf` to `applications/<company>-<role>/resume.pdf`. The root `resume.pdf` stays gitignored and transient; the per-role `applications/<slug>/resume.pdf` is the tracked artifact. If it already exists, ask before overwriting (same as `resume.txt`).
9. Build and test with `make build && make test`, then archive per step 8.
10. Tell the user which bullets were selected and why, note any notable gaps against the job spec, and confirm where the tailored copy was saved (`applications/<slug>/` holding `resume.txt`, `resume.pdf`, and `job-spec.txt`).

## Adding to the Resume Bank

When the user pastes a new achievement, role, or bullet point:
1. Append it to `resumes/master.txt` under the correct role/section — never overwrite existing content
2. If it's a new framing of an existing achievement rather than a new achievement, add it as an additional "Option" or "variant" under that bullet rather than replacing the existing text
3. Keep the user's own wording where possible; ask clarifying questions only if the impact or metric is ambiguous

## Writing Style

- **Never use em-dashes (—) in generated resume content** (`resume.html` and any
  `applications/<company>-<role>/resume.txt` output). Em-dashes are a common AI-writing
  indicator and can undermine credibility with reviewers and detection tools.
  Rewrite with commas, colons, parentheses, or separate sentences — do not just
  swap the character for a hyphen, which often reads awkwardly. Prefer phrasing
  that flows naturally without the dash at all.
- En-dashes (–) are acceptable **only** in numeric or date ranges (e.g. `2015 – 2022`).
- Keep the language interview-defensible: never introduce metrics, tools, or
  outcomes not evidenced in `resumes/master.txt`.

## Theme

Read `config.yaml` for all theme values. When generating or updating `resume.html`:
- Use CSS custom properties (`--bg`, `--text`, `--muted`, `--accent`, `--border`, `--code-bg`, `--bright`, `--font`)
- Set the `@import url()` from `theme.font_import`
- Set body padding from `theme.padding`
- The `:root` block in the HTML should match config.yaml values

Users customize their theme by editing `config.yaml`, not the CSS directly.

## HTML Template Structure

The resume uses this section order:
1. **Header** — name + contact links (`.header`, `.contact`)
2. **Profile** — professional summary paragraph (`.profile`)
3. **Skills** — categorized skill rows (`.skills-grid`, `.skill-row`)
4. **Highlights** — notable work with optional tags (`.highlight-block`)
5. **Experience** — job history with bullet points (`.job`, `.job-header`)
6. **Recognition** — awards, publications, community (`.recognition-list`)
7. **Footer**(optional, see below) — "Built with Claude Resume Builder" link (.footer)

Each section uses an `<h2>` with `::before { content: "> " }` for the terminal prompt aesthetic.

The footer is opt-in only — do not include it by default. Only add it if the user explicitly asks for it in that session (e.g. "add the footer" or "include the built-with line"). Most applications should not have it, since a footer crediting the tool can read as an unnecessary risk signal for conservative or enterprise-leaning roles; it's worth including only when the user specifically wants to signal it (e.g. developer-tooling or platform-engineering roles).

When the user does ask for it:
```html
<div class="footer">
  Built with <a href="https://github.com/adamenger/claude-resume-builder">Claude Resume Builder</a>
</div>
```
Style it with muted text, centered, `font-size: 7.5pt`, with a `border-top` divider.

## Interview Prep Generation
`interview-prep/story-bank.txt` holds SOAR-format stories (Situation,
Obstacle, Action, Result) built up across past interview prep. `interview-prep/question-bank.txt`
holds question patterns from past interviews, organized by category — this
is reference material for what TYPE of question tends to come up, not a
script to repeat verbatim.
 
When the user asks to generate interview questions for a role (with
`job-spec.txt` present):
 
1. Read `job-spec.txt` in full — extract the responsibilities, required
   skills, and any distinctive emphasis (e.g. security, AI tooling,
   specific frameworks) the way the Tailored Workflow does for the CV.
2. Read `interview-prep/question-bank.txt` — identify which existing
   question categories are likely to recur based on the JD's emphasis.
3. Read `interview-prep/story-bank.txt` — for each likely question, identify
   which existing story (if any) answers it well. Note the story's tags to
   confirm relevance rather than forcing a loose match.
4. Generate a small set of NEW, JD-specific questions only for things the
   existing question bank doesn't cover (e.g. a specific technology, a
   specific responsibility named in the JD that hasn't come up before).
   Don't pad the list with generic questions the bank already covers well.
5. For each question (existing or new), note:
   - Which story answers it (by story title), or
   - That there's a genuine gap — no story currently covers this — rather
     than stretching an unrelated story to fit
6. If `story-bank.txt` contains a flagged discrepancy (multiple conflicting
   versions of the same story), surface that flag to the user before
   suggesting the story be used — do not silently pick one version.
7. Present the output as a simple mapping: Question → Story to use (or gap
   noted) → any framing notes. Do not generate full written-out answers
   unless the user asks for that separately.
8. Save the mapping to `applications/<company>-<role>/interview-prep.txt`
   (same slug as the tailored resume) so it sits alongside the resume, cover
   letter, and job spec for that role. The shared `interview-prep/story-bank.txt`
   and `question-bank.txt` remain the global banks and are never moved into an
   application folder; only the per-role mapping is archived there.
Never invent a story, metric, or outcome not already in `story-bank.txt` to
fill a gap — flag the gap honestly instead, consistent with how the CV
tailoring workflow handles gaps against `resumes/master.txt`.

## Adding to the Story Bank
When the user pastes a new story, question, or reflection from an actual
interview:
1. Append new stories to `interview-prep/story-bank.txt` using the SOAR
   format, tagged with the competencies it demonstrates
2. Append new question patterns to `interview-prep/question-bank.txt` under
   the closest existing category, or a new category if none fits
3. If a new version of an existing story conflicts with a version already in
   the bank (different specifics, different framing of the same event), add
   it as a tagged variant with a flagged discrepancy note — do not overwrite
   or silently merge conflicting versions

## Cover Letter Workflow (optional)

Cover letters are an **opt-in** deliverable — only produce one when the user
explicitly asks for a cover letter. They are never generated automatically as
part of a resume or tailored build.

Cover letters live inside the application folder,
`applications/<company>-<role>/`, alongside the tailored resume. The default and
primary format is plain text; a PDF is optional and only built when the user
asks for one.

When the user asks for a cover letter (job spec present, tailored to the role):
1. Read `job-spec.txt` and `resumes/master.txt` (and the tailored
   `applications/<company>-<role>/resume.txt` if one exists) the same way the
   Tailored Workflow does. Ground every claim in `master.txt` — never invent
   metrics, tools, stories, or outcomes not evidenced there, and flag genuine
   gaps rather than papering over them, exactly as CV tailoring does.
2. Apply the same **Writing Style** rules as resume content: no em-dashes,
   en-dashes only in numeric/date ranges, honest and interview-defensible
   language.
3. Write the letter as plain text to `applications/<company>-<role>/cover-letter.txt`
   (using the **same slug** as the tailored resume). If the company is unnamed
   (e.g. a listing via an intermediary), slug from the intermediary or the role.
   If the file already exists, ask before overwriting.
4. Keep it to roughly one page: a short opening that names the role and a
   genuine hook, two or three body paragraphs mapping the user's real
   experience to the job spec's emphasis, and a brief close.

When the user asks for a **PDF** version of a cover letter:
1. Generate `applications/<slug>/cover-letter.html` styled to match the resume
   theme — reuse the same `:root` custom properties and header markup as
   `resume.html` so the theme stays consistent (the build applies `config.yaml`
   values, same as the resume).
2. Run `make cover-letter CL=<slug>` (or `./build_cover_letter.sh <slug>`) to
   produce `applications/<slug>/cover-letter.pdf` (gitignored, regenerable).
3. Cover letters are not held to the resume's ATS/WCAG gates, but keep the
   PDF to a single page and confirm the text is selectable.

## Available Commands

- `make build` — apply theme + generate PDF via headless Chrome
- `make test` — run WCAG accessibility check + ATS parsability test
- `make open` — build and open the PDF
- `make clean` — remove the transient root resume PDF and any regenerable cover-letter PDFs (does not touch the archived `applications/<slug>/resume.pdf`)
- `make cover-letter CL=<slug>` — render `applications/<slug>/cover-letter.html` to PDF (optional)
- `make archive SLUG=<company>-<role>` — rebuild and copy `resume.pdf` to the version-controlled `applications/<slug>/resume.pdf`

## Compliance Requirements

### WCAG Accessibility
- All text must have sufficient color contrast against backgrounds
- Links must be distinguishable
- Semantic HTML structure (h1, h2, h3, ul, li)
- The page must pass `npx pa11y resume.html`

### ATS (Applicant Tracking System) Parsability
- Text must be extractable from the PDF (no images of text)
- Must contain: email, phone number, URLs, job titles, date ranges
- The PDF must pass `python3 test_ats.py`

## Workflow

When the user asks to update their resume (no job spec):
1. Read the current `resume.html` to understand existing content
2. Make the requested changes
3. Run `make build` to generate the PDF
4. Run `make test` to verify WCAG + ATS compliance
5. If tests fail, fix issues and rebuild

When the user provides a `job-spec.txt` (tailored build):
1. Follow the Tailored Workflow above
2. Archive the job spec to `applications/<company>-<role>/job-spec.txt` (same slug / folder) so the exact posting is kept for interview prep
3. Build and test with `make build && make test`
4. Archive the PDF with `make archive SLUG=<company>-<role>` (same slug) so the per-role PDF is version-controlled in `applications/<slug>/`

When the user asks to start fresh:
1. Gather their information (from file or interactively)
2. Generate `resume.html` following the template structure
3. Build and test with `make build && make test`
