#!/usr/bin/env python3
"""Verify resume PDF is parseable by ATS (Applicant Tracking Systems)."""
import sys
import re
import pypdf

reader = pypdf.PdfReader("resume.pdf")
text = "\n".join(page.extract_text() for page in reader.pages)

checks = {
    "Has extractable text": lambda t: len(t) > 100,
    "Contains email address": lambda t: bool(re.search(r"[\w.+-]+@[\w-]+\.[\w.]+", t)),
    "Contains phone number": lambda t: bool(re.search(r"\d{3}[\.\-]?\d{3}[\.\-]?\d{4}", t)),
    "Contains URL or link text": lambda t: bool(re.search(r"(https?://|LinkedIn|GitHub|\.com)", t)),
    "Contains job titles": lambda t: bool(re.search(r"(Engineer|Architect|Developer|Manager|Director|Lead)", t)),
    "Contains date ranges": lambda t: bool(re.search(r"\d{4}\s*[–\-—]\s*(\d{4}|Present)", t)),
}

failures = 0
for label, check in checks.items():
    passed = check(text)
    status = "PASS" if passed else "FAIL"
    if not passed:
        failures += 1
    print(f"  [{status}] {label}")

print(f"\n{'ALL PASSED' if not failures else f'{failures} FAILED'}")
sys.exit(1 if failures else 0)
