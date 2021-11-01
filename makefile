MD_FILES = docs/cli.md docs/pm.md docs/dsl.md docs/make.md docs/git.md docs/doc.md docs/vm.md

HTML_FILE = build/scm.html
PDF_FILE = build/scm.pdf

OPTIONS = -d kisscm.yaml --from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex --toc
RM = powershell rm

all: html pdf

html: $(HTML_FILE)

pdf: $(PDF_FILE)

$(HTML_FILE): $(MD_FILES)
	pandoc $(MD_FILES) $(OPTIONS) --metadata-file=html.yaml --output=$(HTML_FILE) --to=html5 --mathjax --self-contained

$(PDF_FILE): $(MD_FILES)
	pandoc $(MD_FILES) $(OPTIONS) --metadata-file=pdf.yaml --output=$(PDF_FILE) --to=latex --pdf-engine=xelatex

clean:
	$(RM) $(HTML_FILE)
	$(RM) $(PDF_FILE)
