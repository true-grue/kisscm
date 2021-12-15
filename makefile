MD_FILES = md/introduction.md \
	md/command_line.md \
	md/package_managers.md \
	md/conf_languages.md \
	md/build_automation.md \
	md/version_control.md \
	md/docs_as_code.md \
	md/virtual_machines.md \
	md/bibliography.md

HTML_FILE = build/kisscm.html
PDF_FILE = build/kisscm.pdf
DOCX_FILE = build/kisscm.docx

OPTIONS = -d default.yaml \
	--from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex \
	--toc \
	--resource-path=images \
	-F pandoc-crossref \
	--columns=1 \
	--citeproc \
	--lua-filter=filters/pagebreak.lua \
	--lua-filter=filters/upper.lua

ifeq ($(OS), Windows_NT)
	MK_BUILD = if not exist build mkdir build
	RM_BUILD = del /q build\*.*
else
	MK_BUILD = mkdir -p build
	RM_BUILD = rm build/*.*
endif

all: html pdf docx

html: $(HTML_FILE)

pdf: $(PDF_FILE)

docx: $(DOCX_FILE)

$(HTML_FILE): $(MD_FILES)
	$(MK_BUILD)
	pandoc $(MD_FILES) $(OPTIONS) --output=$(HTML_FILE) --to=html5 --mathjax --self-contained

$(PDF_FILE): $(MD_FILES)
	$(MK_BUILD)
	pandoc $(MD_FILES) $(OPTIONS) --metadata-file pdf.yaml --output=$(PDF_FILE) --to=latex --pdf-engine=xelatex

$(DOCX_FILE): $(MD_FILES)
	$(MK_BUILD)
	pandoc $(MD_FILES) $(OPTIONS) --reference-doc=template.docx --output=$(DOCX_FILE) --to=docx
	python filters/bullets.py $(DOCX_FILE)

clean:
	$(RM_BUILD)
