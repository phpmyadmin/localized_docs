#!/usr/bin/make -f
# Makefile to build translations

# Languages which we translate
LANGUAGES=it pl ja fr cs gl sv nl ka tr fi ca hr hu nb es de lt ro mn pt_BR pt_PT zh_CN zh_TW hy en_GB rcf si sk sl el da ar bs az et fy sq eo id ko uk ru

# Documentation source dir
SOURCE_DIR=phpmyadmin/doc/

SPHINXOPTS=

# Names of pages, this is hardcoded to allow ordering
SOURCES=$(wildcard $(SOURCE_DIR)*.rst)
PAGES=$(basename $(notdir $(SOURCES)))

# Name of Gettext templates
TEMPLATES=$(addprefix locale/,$(addsuffix .pot,$(PAGES)))

# Symlinked fake mo files
FAKE_MOFILES=$(foreach lang,$(LANGUAGES),$(addsuffix .mo, $(addprefix translated/$(lang)/LC_MESSAGES/, $(PAGES))))

POFILES=$(addsuffix .po, $(addprefix po/,$(LANGUAGES)))
MOFILES=$(addsuffix .mo, $(addprefix po/,$(LANGUAGES)))
INDEXFILES=$(addsuffix /index.html, $(addprefix output/,$(LANGUAGES)))

CONFIGS=$(addsuffix /conf.py, $(addprefix docs/,$(LANGUAGES)))

all: $(FAKE_MOFILES) $(MOFILES) $(CONFIGS)

SECONDARY: $(POFILES) $(INDEXFILES)
.phony: all html $(addprefix html-,$(LANGUAGES))

docs/%/conf.py: $(SOURCE_DIR)conf.py Makefile $(SOURCES)
	@mkdir -p docs/$*
	@cd docs/$* && ln -sf ../../$(SOURCE_DIR)* .
	@rm -f $@
	@sed 's/#language = None/language = "$*"\nlocale_dirs = ["..\/..\/translated\/"]/' $< > $@

locale/%.pot: $(SOURCES)
	@make -C $(SOURCE_DIR) gettext BUILDDIR=`pwd`

po/documentation.pot: $(TEMPLATES)
	@echo "UPDATE $@"
	@msgcat -o $@ $(TEMPLATES)
	@sed -i 's/Report-Msgid-Bugs-To: [^"]*/Report-Msgid-Bugs-To: translators@phpmyadmin.net\\n/' $@

po/%.po: po/documentation.pot phpmyadmin/po/%.po
	@echo "UPDATE $@"
	@if [ ! -f $@ ] ; then msginit --no-translator -i $< -o $@ ; fi
	@msgmerge --previous -U $@ -C phpmyadmin/$@ $<

po/%.mo: po/%.po
	@echo "GEN $@"
	@msgfmt $< -o $@

translated/%.mo:
	@mkdir -p $(dir $@)
	@ln -sf ../../../po/`echo $@ | sed 's@translated/\(.*\)/LC_MESSAGES.*@\1@'`.mo $@

html: $(addprefix html-,$(LANGUAGES))

html-%: output/%/index.html
	@echo -n

output/%/index.html: po/%.mo
	@echo "HTML $*"
	@mkdir -p "output/$*"
	@sphinx-build $(SPHINXOPTS) docs/$*/ output/$*
