.PHONY: build open clean test wcag ats cover-letter archive

build:
	./build.sh

# Archive the built PDF into the application folder under version control.
# Usage: make archive SLUG=<company>-<role>  (same slug as applications/<slug>/)
# Builds first so the archived PDF matches the current resume.html.
archive: build
	@test -n "$(SLUG)" || { echo "Usage: make archive SLUG=<company>-<role>"; exit 1; }
	mkdir -p applications/$(SLUG)
	cp resume.pdf applications/$(SLUG)/resume.pdf
	@echo "Archived: applications/$(SLUG)/resume.pdf"

# Render a cover letter to PDF (optional). Usage: make cover-letter CL=<slug>
# where applications/<slug>/cover-letter.html exists.
cover-letter:
	@test -n "$(CL)" || { echo "Usage: make cover-letter CL=<slug>"; exit 1; }
	./build_cover_letter.sh $(CL)

open: build
	@(command -v xdg-open >/dev/null && xdg-open resume.pdf) || \
	 (command -v open >/dev/null && open resume.pdf) || \
	 (command -v wslview >/dev/null && wslview resume.pdf) || \
	 echo "Open resume.pdf manually — no opener found (xdg-open/open/wslview)."

test: wcag ats

wcag:
	npx pa11y ./resume.html

ats: build
	python3 test_ats.py

clean:
	rm -f resume.pdf
	@find applications -name cover-letter.pdf -delete 2>/dev/null || true
