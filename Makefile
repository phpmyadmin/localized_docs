#!/usr/bin/make -f
# Makefile to build translations

# Languages which we translate
LANGUAGES=it pl ja fr cs gl sv nl ka tr fi ca hu nb es de lt ro mn pt_BR zh_CN zh_TW hy en_GB sk sl el da ar

# directory where phpMyAdmin sources are placed
PMA_DIR=../phpmyadmin

# phpMyAdmin version
PMA_VERSION=$(shell sed -n "s/.*'PMA_VERSION', '\(.*\)'.*/\1/p" $(PMA_DIR)/libraries/Config.class.php)

# Source documents
SOURCES=$(wildcard ../phpmyadmin/doc/*.rst)

# Names of pages
PAGES=$(subst .rst,,$(subst ../phpmyadmin/doc/,,$(SOURCES)))

# Copied sources
OUR_SOURCES=$(addprefix source/, $(addsuffix .rst, $(PAGES)))

# Name of Gettext templates
TEMPLATES=$(addprefix locale/,$(addsuffix .pot,$(PAGES)))

# Symlinked fake mo files
FAKE_MOFILES=$(foreach lang,$(LANGUAGES),$(addsuffix .mo, $(addprefix translated/$(lang)/LC_MESSAGES/, $(PAGES))))

MOFILES=$(addsuffix .mo, $(addprefix po/,$(LANGUAGES)))

CONFIGS=$(addsuffix /conf.py, $(addprefix docs/,$(LANGUAGES)))

all: $(FAKE_MOFILES) $(MOFILES) $(CONFIGS)

$(OUR_SOURCES) source/conf.py:
	@rsync -a --delete --exclude 'html' --exclude doctrees --exclude locale ../phpmyadmin/doc/ source/

docs/%/conf.py: source/conf.py Makefile
	@mkdir -p docs/$*
	@cd docs/$* && ln -sf ../../source/* .
	@rm -f $@
	@sed 's/#language = None/language = "$*"\nlocale_dirs = ["..\/..\/translated\/"]/' $< > $@

locale/%.pot: $(OUR_SOURCES)
	@make -C source/ gettext BUILDDIR=`pwd`

po/documentation.pot: $(TEMPLATES)
	@echo "UPDATE $@"
	@msgcat -o $@ $(TEMPLATES)

po/%.po: po/documentation.pot
	@echo "UPDATE $@"
	@msgmerge -U $@ $< 

po/%.mo: po/%.po
	@echo "GEN $@"
	@msgfmt $< -o $@

translated/%.mo:
	@mkdir -p $(dir $@)
	@ln -sf ../../../po/`echo $@ | sed 's@translated/\(.*\)/LC_MESSAGES.*@\1@'`.mo $@
