#!/usr/bin/env python

import csv
import re

unwanted_characters = re.compile(r'[^a-zA-Z]')
reader = csv.reader(open('ship-names.csv'))

print 'window.shipNames = ['

names = set()
for row in reader:
    name = row[0]
    if not unwanted_characters.search(name):
        names.add(name)

print ',\n'.join(repr(name) for name in sorted(names))

print '];'
