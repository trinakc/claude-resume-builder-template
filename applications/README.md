# Applications

One folder per role you apply for, named `<company>-<role>` (lowercase,
hyphenated). The same slug is used for every artifact belonging to that role,
so everything for one application sits together and is easy to pull up when
an interview gets scheduled.

```
applications/<company>-<role>/
  job-spec.txt        verbatim copy of the posting (archived on every tailored build)
  resume.txt          plain-text tailored resume content
  resume.pdf          tracked, version-controlled PDF (via `make archive SLUG=<slug>`)
  cover-letter.txt    optional, only when you ask for a cover letter
  cover-letter.html   optional, styled source for the cover-letter PDF
  cover-letter.pdf    optional, gitignored (regenerable from the .html)
  interview-prep.txt  optional, per-role question -> story mapping
```

Claude creates these folders for you during a tailored build. This file is
here so the directory exists in a fresh clone; you can delete it once you have
real applications in here.

Two resources stay **global** and never move into an application folder:

- `resumes/master.txt` — the career bank every tailored build draws from
- `interview-prep/story-bank.txt` and `interview-prep/question-bank.txt` —
  cumulative across all interviews

The root `resume.html`, `resume.pdf`, `resume.txt`, and `job-spec.txt` are
transient working files and are gitignored. The copies under
`applications/<slug>/` are the durable record.
