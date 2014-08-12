#!/usr/bin/make -f
# Makefile to build translations

# Languages which we translate
LANGUAGES=it pl ja fr cs gl sv nl ka tr fi ca hu nb es de lt ro mn pt_BR zh_CN zh_TW hy en_GB sk sl el da ar bs az et

# directory where phpMyAdmin sources are placed
PMA_DIR=../phpmyadmin

# Names of pages, this is hardcoded to allow ordering
PAGES=index intro require setup config transformations faq developers vendors copyright credits glossary

# Copied sources
OUR_SOURCES=$(addprefix source/, $(addsuffix .rst, $(PAGES)))

# Copied examples
OUR_EXAMPLES=examples/signon-script.php examples/openid.php examples/signon.php

# Name of Gettext templates
TEMPLATES=$(addprefix locale/,$(addsuffix .pot,$(PAGES)))

# Symlinked fake mo files
FAKE_MOFILES=$(foreach lang,$(LANGUAGES),$(addsuffix .mo, $(addprefix translated/$(lang)/LC_MESSAGES/, $(PAGES))))

MOFILES=$(addsuffix .mo, $(addprefix po/,$(LANGUAGES)))

CONFIGS=$(addsuffix /conf.py, $(addprefix docs/,$(LANGUAGES)))

EXAMPLES=examples/signon.php examples/openid.php examples/signon-script.php examples/swekey.sample.conf

all: $(FAKE_MOFILES) $(MOFILES) $(CONFIGS) $(EXAMPLES)

.phony:
FORCE:

$(OUR_SOURCES) source/conf.py: FORCE
	@rsync -a --delete --exclude 'html' --exclude doctrees --exclude locale $(PMA_DIR)/doc/ source/

$(OUR_EXAMPLES): FORCE
	@rsync -a --delete $(PMA_DIR)/examples/ examples/

docs/%/conf.py: source/conf.py Makefile
	@mkdir -p docs/$*
	@cd docs/$* && ln -sf ../../source/* .
	@rm -f $@
	@sed 's/#language = None/language = "$*"\nlocale_dirs = ["..\/..\/translated\/"]/' $< > $@

locale/%.pot: $(OUR_SOURCES) $(OUR_EXAMPLES)
	@make -C source/ gettext BUILDDIR=`pwd`

po/documentation.pot: $(TEMPLATES)
	@echo "UPDATE $@"
	@msgcat -o $@ $(TEMPLATES)

po/%.po: po/documentation.pot
	@echo "UPDATE $@"
	@if [ ! -f $@ ] ; then msginit --no-translator -i $< -o $@ ; else msgmerge --previous -U $@ $< ; fi

po/%.mo: po/%.po
	@echo "GEN $@"
	@msgfmt $< -o $@

translated/%.mo:
	@mkdir -p $(dir $@)
	@ln -sf ../../../po/`echo $@ | sed 's@translated/\(.*\)/LC_MESSAGES.*@\1@'`.mo $@

examples/%: $(PMA_DIR)/examples/%
	cp $< $@
