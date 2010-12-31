#!/usr/bin/make -f
# Makefile to build translations

# Languages which we translate
LANGUAGES=it pl ja fr cs gl sv nl ka tr fi ca hu nb es de lt ro mn pt_BR zh_CN zh_TW hy en_GB sk sl el

# directory where phpMyAdmin sources are placed
PMA_DIR=../phpmyadmin

# Option to po4a programs
PO4AOPTS=-M utf-8 -k 15

# Options for generating po files using po4a
PO4A_PO_OPTS=--msgid-bugs-address phpmyadmin-devel@lists.sourceforge.net \
		--copyright-holder "the phpMyAdmin project" \
		--package-name "phpMyAdmin documentation" \
		-M utf-8 \

# Options for processing text files
PO4A_TEXT_OPTS=-f text -o asciidoc

# Options for processing html files
PO4A_HTML_OPTS=-f xhtml

# phpMyAdmin version
PMA_VERSION=$(shell sed -n "s/.*'PMA_VERSION', '\(.*\)'.*/\1/p" $(PMA_DIR)/libraries/Config.class.php)

all: $(addsuffix /Documentation.html.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /index.html, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /README.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /INSTALL.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /TODO.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /themes/original/img/docs_menu_bg.png, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /themes/original/img/logo_right.png, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /favicon.ico, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /docs.css, $(addprefix output/, ${LANGUAGES})) \
	output/index.html


output/%/index.html: po/%.po output/%/index-template.html
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_HTML_OPTS) -m output/$*/index-template.html -p $< -l $@ ${PO4AOPTS} -k 0

output/%/Documentation.html.stamp: po/%.po addendum/html_head.% addendum/html_comment.% orig-docs/Documentation.html addendum/html_credits.%
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_HTML_OPTS) -m orig-docs/Documentation.html -p $< -l output/$*/Documentation.html ${PO4AOPTS} --addendum addendum/html_head.$* --addendum addendum/html_comment.$* --addendum addendum/html_credits.$*
	@if [ -f output/$*/Documentation.html ] ; then sed -i 's/@@VER@@/$(PMA_VERSION)/' output/$*/Documentation.html ; fi
	@touch $@

output/%/README.stamp: po/%.po orig-docs/README
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_TEXT_OPTS) -m orig-docs/README -p $< -l output/$*/README ${PO4AOPTS}
	@if [ -f output/$*/README ] ; then sed -i 's/@@VER@@/$(PMA_VERSION)/' output/$*/README ; fi
	@touch $@

output/%/TODO.stamp: po/%.po orig-docs/TODO
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_TEXT_OPTS) -m orig-docs/TODO -p $< -l output/$*/TODO ${PO4AOPTS}
	@if [ -f output/$*/TODO ] ; then sed -i 's/@@VER@@/$(PMA_VERSION)/' output/$*/TODO ; fi
	@touch $@

output/%/INSTALL.stamp: po/%.po orig-docs/INSTALL
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_TEXT_OPTS) -m orig-docs/INSTALL -p $< -l output/$*/INSTALL ${PO4AOPTS}
	@if [ -f output/$*/INSTALL ] ; then sed -i 's/@@VER@@/$(PMA_VERSION)/' output/$*/INSTALL ; fi
	@touch $@

.PRECIOUS: addendum/html_head.%
addendum/html_head.%: po/%.po addendum/head.html addendum/add-html_head
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_HTML_OPTS) -m addendum/head.html -p $< -l $@ ${PO4AOPTS} -k 0 --addendum addendum/add-html_head

.PRECIOUS: addendum/html_head-translations.%
addendum/html_head-translations.%: po/%.po addendum/head.html addendum/add-html_head-translations
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_HTML_OPTS) -m addendum/head.html -p $< -l $@ ${PO4AOPTS} -k 0 --addendum addendum/add-html_head-translations

.PRECIOUS: addendum/html_comment.%
addendum/html_comment.%: po/%.po addendum/comment.html addendum/add-html_comment
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_TEXT_OPTS) -m addendum/comment.html -p $< -l $@ ${PO4AOPTS} -k 0 --addendum addendum/add-html_comment

.PRECIOUS: addendum/html_credits.%
addendum/html_credits.%: po/%.po addendum/credits.html addendum/add-html_credits
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_HTML_OPTS) -m addendum/credits.html -p $< -l $@ ${PO4AOPTS} -k 0 --addendum addendum/add-html_credits

output/%/index-template.html: generate-lang-index get-lang-name \
	$(wildcard $(addsuffix /Documentation.html, output/%) \
	$(addsuffix /README, output/%) \
	$(addsuffix /INSTALL, output/%) \
	$(addsuffix /TODO, output/%))
	@./generate-lang-index $* > $@

output/%/docs.css: $(PMA_DIR)/docs.css
	@cp $< $@

output/%/favicon.ico: $(PMA_DIR)/favicon.ico
	@cp $< $@

output/%/themes/original/img/docs_menu_bg.png: $(PMA_DIR)/themes/original/img/docs_menu_bg.png
	@cp $< $@

output/%/themes/original/img/logo_right.png: $(PMA_DIR)/themes/original/img/logo_right.png
	@cp $< $@

.PRECIOUS: output/%/index-full-template.html
output/%/index-full-template.html: generate-lang-index get-lang-name
	@./generate-lang-index $* full > $@

output/index.html: $(wildcard output/*/index.html) generate-index get-lang-name
	@./generate-index > $@

.PRECIOUS: orig-docs/%
orig-docs/%: $(PMA_DIR)/%
	@echo 'SED $@'
	@sed 's/$(PMA_VERSION)/@@VER@@/' < $< > $@

.PRECIOUS: pot/%-html.pot
pot/%-html.pot: orig-docs/Documentation.html output/%/index-full-template.html addendum/head.html addendum/credits.html
	@echo 'GEN $@'
	@po4a-gettextize $(PO4A_HTML_OPTS) ${PO4A_PO_OPTS} \
		-m orig-docs/Documentation.html \
		-m output/$*/index-full-template.html \
		-m addendum/head.html \
		-m addendum/credits.html \
		-p $@

.PRECIOUS: pot/%-txt.pot
pot/%-txt.pot: orig-docs/INSTALL orig-docs/TODO orig-docs/README addendum/comment.html
	@echo 'GEN $@'
	@po4a-gettextize $(PO4A_TEXT_OPTS) ${PO4A_PO_OPTS} \
		-m addendum/comment.html \
		-m orig-docs/INSTALL \
		-m orig-docs/TODO \
		-m orig-docs/README \
		-p $@

.PRECIOUS: pot/%-full.pot
pot/%-full.pot: pot/%-html.pot pot/%-txt.pot
	@echo 'JOIN $@'
	@msgcat -o $@ $^

po/%.po:  pot/%-full.pot
	@set -e; \
	if [ ! -f $@ ] ; then msginit -i $< -l $* --no-translator -o $@ ; fi
	@set -e; \
	echo 'MERGE $@'; \
	if [ -f $(PMA_DIR)/po/$*.po ] ; then \
		msgmerge -U $@ -C $(PMA_DIR)/po/$*.po $< ; \
	else \
		msgmerge -U $@ $< ; \
	fi
	@touch $@
