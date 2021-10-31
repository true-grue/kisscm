MD_FILES = docs/title.md docs/cli.md docs/pm.md docs/dsl.md docs/make.md docs/git.md docs/doc.md docs/vm.md
HTML_FILE = build/scm.html
PDF_FILE = build/scm.pdf
DOCX_FILE = build/scm.docx

all: html pdf docx

html: $(HTML_FILE)

pdf: $(PDF_FILE)

docx: $(DOCX_FILE)

$(HTML_FILE): $(MD_FILES)
	pandoc $(MD_FILES) --from=markdown+tex_math_single_backslash+tex_math_dollars --to=html5 --output=$(HTML_FILE) --mathjax --self-contained --toc

$(PDF_FILE): $(MD_FILES)
	pandoc $(MD_FILES) --from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex --to=latex -o $(PDF_FILE) --pdf-engine=xelatex --toc -V toc-title:"Оглавление" 

$(DOCX_FILE): $(MD_FILES)
	pandoc $(MD_FILES) -f markdown -o $(DOCX_FILE) --toc

#clean:
#	rm -f $(HTML_FILE)
#	rm -f $(PDF_FILE)
