#!/usr/bin/python
# -*- coding: UTF-8 -*-

import polib
import sys


TYPES = {
    'integer': u'číslo',
    'string': 'text',
    'string or integer': u'text nebo číslo',
    'boolean': 'boolean',
    'array': 'pole',
    'string [CSS color for background]': u'text [CSS barva pro pozadí]',
    'string [CSS color]': u'text [CSS barva]',
}

po = polib.pofile('po/cs.po')

for entry in po:
    for t in TYPES:
        l = len(t)
        if entry.msgid[:6] == "$cfg['":
            if entry.msgid[-(3 + l):] == "'] %s" % t:
                entry.msgstr = u'%s%s' % (entry.msgid[:-l], TYPES[t])
                try:
                    entry.flags.remove('fuzzy')
                except ValueError:
                    pass
                continue
        if entry.msgid[:14] == '<span id="cfg_':
            if entry.msgid[-(7 + l):] == '</span>%s' % t:
                entry.msgstr = u'%s%s' % (entry.msgid[:-l], TYPES[t])
                try:
                    entry.flags.remove('fuzzy')
                except ValueError:
                    pass
                continue
            if entry.msgid[-(8 + l):] == '</span> %s' % t:
                entry.msgstr = u'%s%s' % (entry.msgid[:-l], TYPES[t])
                try:
                    entry.flags.remove('fuzzy')
                except ValueError:
                    pass
                continue

po.save()


