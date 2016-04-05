#!/usr/bin/make -f
# Makefile to build translations

# Languages which we translate
LANGUAGES=it pl ja fr cs gl sv nl ka tr fi ca hu nb es de lt ro mn pt_BR zh_CN zh_TW hy en_GB sk sl el da ar bs az et fy sq

# Names of pages, this is hardcoded to allow ordering
PAGES=index intro require setup config transformations faq developers vendors copyright credits glossary

# Documentation source dir
SOURCE_DIR=phpmyadmin/doc/

# Name of Gettext templates
TEMPLATES=$(addprefix locale/,$(addsuffix .pot,$(PAGES)))

# Symlinked fake mo files
FAKE_MOFILES=$(foreach lang,$(LANGUAGES),$(addsuffix .mo, $(addprefix translated/$(lang)/LC_MESSAGES/, $(PAGES))))

MOFILES=$(addsuffix .mo, $(addprefix po/,$(LANGUAGES)))

CONFIGS=$(addsuffix /conf.py, $(addprefix docs/,$(LANGUAGES)))

all: $(FAKE_MOFILES) $(MOFILES) $(CONFIGS)

.phony:
FORCE:

docs/%/conf.py: $(SOURCE_DIR)conf.py Makefile
	@mkdir -p docs/$*
	@cd docs/$* && ln -sf ../../$(SOURCE_DIR)* .
	@rm -f $@
	@sed 's/#language = None/language = "$*"\nlocale_dirs = ["..\/..\/translated\/"]/' $< > $@

locale/%.pot: $(addprefix $(SOURCE_DIR), $(addsuffix .rst, $(PAGES)))
	@make -C $(SOURCE_DIR) gettext BUILDDIR=`pwd`

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
