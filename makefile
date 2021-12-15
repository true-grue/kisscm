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


MKDIR_BUILD_WINDOWS = powershell -windowstyle hidden { New-Item -ItemType Directory -Force -Path build }
MKDIR_BUILD_LINUX = mkdir -p build

ifeq ($(OS), Windows_NT)
    UNAME := Windows
else
    UNAME := $(shell uname -s)
endif


all: html pdf docx

html: $(HTML_FILE)

pdf: $(PDF_FILE)

docx: $(DOCX_FILE)

$(HTML_FILE): $(MD_FILES)
ifeq ($(UNAME), Windows)
	$(MKDIR_BUILD_WINDOWS)
endif
ifeq ($(UNAME), Linux)
	$(MKDIR_BUILD_LINUX)
endif
	pandoc $(MD_FILES) $(OPTIONS) --output=$(HTML_FILE) --to=html5 --mathjax --self-contained

$(PDF_FILE): $(MD_FILES)
ifeq ($(UNAME), Windows)
	$(MKDIR_BUILD_WINDOWS)
endif
ifeq ($(UNAME), Linux)
	$(MKDIR_BUILD_LINUX)
endif
	pandoc $(MD_FILES) $(OPTIONS) --metadata-file pdf.yaml --output=$(PDF_FILE) --to=latex --pdf-engine=xelatex

$(DOCX_FILE): $(MD_FILES)
ifeq ($(UNAME), Windows)
	$(MKDIR_BUILD_WINDOWS)
endif
ifeq ($(UNAME), Linux)
	$(MKDIR_BUILD_LINUX)
endif
	pandoc $(MD_FILES) $(OPTIONS) --reference-doc=template.docx --output=$(DOCX_FILE) --to=docx
	python filters/bullets.py $(DOCX_FILE)

clean:
ifeq ($(UNAME), Windows)
	powershell rm build/*.*
endif
ifeq ($(UNAME), Linux)
	rm build/*.*
endif
