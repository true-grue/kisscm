include contents

NAME = kisscm

PDF_FILE = build/$(NAME).pdf
DOCX_FILE = build/$(NAME).docx

MDBOOK = build/book
MDBOOK_SRC = build/src
MDBOOK_IMG = img

BASE_OPTIONS = -d default.yaml \
	--from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex \
	--toc \
	--resource-path=images \
	--columns=1 \
	--lua-filter=tools/pysvg.lua \

DOCX_OPTIONS = $(BASE_OPTIONS) \
	--metadata crossrefYaml=crossref-docx.yaml \
	--filter tools/pandoc-crossref.exe \
	--lua-filter=tools/pagebreak.lua \
	--lua-filter=tools/upper.lua \
	--citeproc \
	--reference-doc=template.docx \
	--output=$(DOCX_FILE) \
	--to=docx \
	-M lang:ru

SITE_OPTIONS = $(BASE_OPTIONS) \
	--metadata crossrefYaml=crossref.yaml \
	--filter tools/pandoc-crossref.exe \
	--lua-filter=tools/pagebreak.lua \
	--citeproc \
	--lua-filter=tools/mdbook.lua \
	--extract-media=$(MDBOOK_IMG) \
	--output=$(MDBOOK_SRC)/$(NAME).md \
	--to=markdown-citations-implicit_figures+hard_line_breaks-pipe_tables-simple_tables-multiline_tables-grid_tables \
	-M lang:ru

ifeq ($(OS), Windows_NT)
	MKBUILD = if not exist build mkdir build
	MKSRC = if not exist build\src mkdir build\src
	RMDIR = rmdir /s /q
	MOVE = move /Y
else
	MKBUILD = mkdir -p build
	MKSRC = mkdir -p $(MDBOOK_SRC)
	RMDIR = rm -r
	MOVE = mv
endif

all: spellcheck docx pdf web

spellcheck:
	python tools/spellcheck.py md

docx:
	$(MKBUILD)
	tools/pandoc.exe $(MD) $(DOCX_OPTIONS)
	python tools/bullets.py $(DOCX_FILE)

pdf: docx
	python tools/doc2pdf.py $(DOCX_FILE) $(PDF_FILE)

web:
	$(MKBUILD)
	$(MKSRC)
	tools/pandoc.exe $(MD) $(SITE_OPTIONS)
	$(MOVE) $(MDBOOK_IMG) $(MDBOOK_SRC)
	python tools/mdbook.py $(MDBOOK_SRC)/$(NAME).md Spisok-literatury.md
	tools/mdbook.exe build

serve: web
	tools/mdbook.exe serve

clean:
	-$(RMDIR) build
	-$(RMDIR) img

install-pandoc:
	wget -O pandoc-3.8.3.tar.gz https://github.com/jgm/pandoc/releases/download/3.8.3/pandoc-3.8.3-linux-amd64.tar.gz
	tar -xvzf pandoc-3.8.3.tar.gz
	mv pandoc-3.8.3/bin/pandoc tools/pandoc.exe
	rm pandoc-3.8.3.tar.gz
	rm -rf pandoc-3.8.3

install-pandoc-crossref:
	wget -O pandoc-crossref.tar.xz https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.18.1/pandoc-crossref-Linux-X64.tar.xz
	tar -xvf pandoc-crossref.tar.xz
	mv pandoc-crossref tools/pandoc-crossref.exe
	rm pandoc-crossref*

install-mdbook:
	wget -O mdbook.tar.gz https://github.com/rust-lang/mdBook/releases/download/v0.5.1/mdbook-v0.5.1-x86_64-unknown-linux-gnu.tar.gz
	tar -xvzf mdbook.tar.gz
	mv mdbook tools/mdbook.exe
	rm mdbook*

install-graphviz:
	sudo apt update
	sudo apt install -y graphviz

install: install-pandoc install-pandoc-crossref install-mdbook install-graphviz
