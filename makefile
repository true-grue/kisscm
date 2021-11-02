MD_FILES = md/introduction.md md/command_line.md md/package_managers.md md/languages.md md/build_automation.md md/version_control.md md/docs_as_code.md md/virtual_machines.md

HTML_FILE = build/kisscm.html
PDF_FILE = build/kisscm.pdf
DOCX_FILE = build/kisscm.docx

OPTIONS = -d kisscm.yaml --from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex --toc --resource-path=images
RM = powershell rm

all: html pdf docx

html: $(HTML_FILE)

pdf: $(PDF_FILE)

docx: $(DOCX_FILE)

$(HTML_FILE): $(MD_FILES)
	pandoc $(MD_FILES) $(OPTIONS) --output=$(HTML_FILE) --to=html5 --mathjax --self-contained

$(PDF_FILE): $(MD_FILES)
	pandoc $(MD_FILES) $(OPTIONS) --metadata-file=pdf.yaml --output=$(PDF_FILE) --to=latex --pdf-engine=xelatex

$(DOCX_FILE): $(MD_FILES)
	pandoc $(MD_FILES) $(OPTIONS) --output=$(DOCX_FILE) --to=docx

clean:
	$(RM) $(HTML_FILE)
	$(RM) $(PDF_FILE)
	$(RM) $(DOCX_FILE)
