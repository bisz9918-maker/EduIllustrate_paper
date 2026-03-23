#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEX_FILE="${1:-acl_latex.tex}"
TEX_BASENAME="${TEX_FILE%.tex}"

cd "$SCRIPT_DIR"

if [[ ! -f "$TEX_FILE" ]]; then
  echo "TeX file not found: $TEX_FILE" >&2
  exit 1
fi

# Clean stale auxiliary files before building. ACL templates can fail when
# line-numbering state in old .aux files no longer matches the current run.
rm -f \
  "${TEX_BASENAME}.aux" \
  "${TEX_BASENAME}.bbl" \
  "${TEX_BASENAME}.blg" \
  "${TEX_BASENAME}.fdb_latexmk" \
  "${TEX_BASENAME}.fls" \
  "${TEX_BASENAME}.log" \
  "${TEX_BASENAME}.out" \
  "${TEX_BASENAME}.synctex.gz" \
  "${TEX_BASENAME}.xdv"

if command -v latexmk >/dev/null 2>&1; then
  latexmk -pdf -interaction=nonstopmode -halt-on-error "$TEX_FILE"
else
  pdflatex -interaction=nonstopmode -halt-on-error "$TEX_FILE"
  bibtex "$TEX_BASENAME"
  pdflatex -interaction=nonstopmode -halt-on-error "$TEX_FILE"
  pdflatex -interaction=nonstopmode -halt-on-error "$TEX_FILE"
fi

echo "Built PDF: ${SCRIPT_DIR}/${TEX_BASENAME}.pdf"
