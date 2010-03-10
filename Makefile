#!/usr/bin/make -f
# Makefile to build translations

LANGUAGES=it pl jp fr cs gl sv nl ka tr fi ca hu no es de lt ro mn pt_BR zh_CN zh_TW hy en_GB
PO4AOPTS=-M utf-8 -k 15
PO4A_PO_OPTS=--msgid-bugs-address phpmyadmin-devel@lists.sourceforge.net \
		--copyright-holder "the phpMyAdmin project" \
		--package-name "phpMyAdmin documentation" \
		-M utf-8 \

all: $(addsuffix /Documentation.html.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /translators.html.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /index.html, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /README.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /INSTALL.stamp, $(addprefix output/, ${LANGUAGES})) \
	$(addsuffix /TODO.stamp, $(addprefix output/, ${LANGUAGES})) \
	output/index.html


output/%/index.html: po/%.po output/%/index-template.html
	po4a-translate -f xhtml -m output/$*/index-template.html -p $< -l $@ ${PO4AOPTS} -k 0

output/%/Documentation.html.stamp: po/%.po addendum/html_head.% addendum/html_comment.% ../phpmyadmin/Documentation.html
	po4a-translate -f xhtml -m ../phpmyadmin/Documentation.html -p $< -l output/$*/Documentation.html ${PO4AOPTS} --addendum addendum/html_head.$* --addendum addendum/html_comment.$*
	touch $@

output/%/translators.html.stamp: po/%.po addendum/html_head.% addendum/html_comment.% ../phpmyadmin/translators.html
	po4a-translate -f xhtml -m ../phpmyadmin/translators.html -p $< -l output/$*/translators.html ${PO4AOPTS} --addendum addendum/html_head.$* --addendum addendum/html_comment.$*
	touch $@

output/%/README.stamp: po/%.po ../phpmyadmin/README
	po4a-translate -f text -m ../phpmyadmin/README -p $< -l output/$*/README ${PO4AOPTS}
	touch $@

output/%/TODO.stamp: po/%.po ../phpmyadmin/TODO
	po4a-translate -f text -m ../phpmyadmin/TODO -p $< -l output/$*/TODO ${PO4AOPTS}
	touch $@

output/%/INSTALL.stamp: po/%.po ../phpmyadmin/INSTALL
	po4a-translate -f text -m ../phpmyadmin/INSTALL -p $< -l output/$*/INSTALL ${PO4AOPTS}
	touch $@

addendum/html_head.%: po/%.po addendum/head.html addendum/add-html_head
	po4a-translate -f xhtml -m addendum/head.html -p $< -l $@ ${PO4AOPTS} -k 0 --addendum addendum/add-html_head

addendum/html_comment.%: po/%.po addendum/comment.html addendum/add-html_comment
	po4a-translate -f text -m addendum/comment.html -p $< -l $@ ${PO4AOPTS} -k 0 --addendum addendum/add-html_comment

output/%/index-template.html: generate-lang-index get-lang-name \
	$(addsuffix /Documentation.html, output/%) \
	$(addsuffix /translators.html, output/%) \
	$(addsuffix /README, output/%) \
	$(addsuffix /INSTALL, output/%) \
	$(addsuffix /TODO, output/%)
	./generate-lang-index $* > $@

output/%/index-full-template.html: generate-lang-index get-lang-name
	./generate-lang-index $* full > $@

output/index.html: $(wildcard output/*/index.html) generate-index get-lang-name
	./generate-index > $@

pot/%-html.pot: ../phpmyadmin/Documentation.html ../phpmyadmin/translators.html output/%/index-full-template.html addendum/head.html
	po4a-gettextize -f xhtml ${PO4A_PO_OPTS} \
		-m ../phpmyadmin/Documentation.html \
		-m../phpmyadmin/translators.html \
		-m  output/$*/index-full-template.html \
		-m addendum/head.html \
		-p $@

pot/%-txt.pot: ../phpmyadmin/INSTALL ../phpmyadmin/TODO ../phpmyadmin/README addendum/comment.html
	po4a-gettextize -f text ${PO4A_PO_OPTS} \
		-m addendum/comment.html \
		-m  ../phpmyadmin/INSTALL \
		-m ../phpmyadmin/TODO \
		-m../phpmyadmin/README \
		-p $@

pot/%-full.pot: pot/%-html.pot pot/%-txt.pot
	msgcat -o $@ $^

po/%.po:  pot/%-full.pot
	msgmerge -U $@ $<

aadasdas: ../phpmyadmin/INSTALL ../phpmyadmin/TODO ../phpmyadmin/README ../phpmyadmin/Documentation.html ../phpmyadmin/translators.html output/%/index-full-template.html addendum/comment.html addendum/head.html
	po4a-updatepo \
		--msgid-bugs-address phpmyadmin-devel@lists.sourceforge.net \
		--copyright-holder "the phpMyAdmin project" \
		--package-name "phpMyAdmin documentation" \
		-M utf-8 \
		-f xhtml \
		-m ../phpmyadmin/Documentation.html \
		-m../phpmyadmin/translators.html \
		-m  output/$*/index-full-template.html \
		-m addendum/head.html \
		-f text \
		-m addendum/comment.html \
		-m  ../phpmyadmin/INSTALL \
		-m ../phpmyadmin/TODO \
		-m../phpmyadmin/README \
		-p $@

#		-f text \
