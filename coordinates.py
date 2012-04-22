#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import sys
import re
import math

format = re.compile(
    r'\s*'
    r'(\d+)°(\d+)′([\d.]+)″([NS])\s*'
    r'(\d+)°(\d+)′([\d.]+)″([EW])\s*'
)

def to_degrees(string):
    m = format.match(string)
    if not m:
        return None
    deg1, min1, sec1, ns, deg2, min2, sec2, ew = m.groups()

    angle1 = float(deg1) + float(min1) / 60 + float(sec1) / 3600
    if ns == 'S':
        angle1 = -angle1
    angle2 = float(deg2) + float(min2) / 60 + float(sec2) / 3600
    if ew == 'W':
        angle2 = -angle2

    return angle1, angle2

def to_radians(string):
    r = to_degrees(string)
    if not r:
        return None
    lat, lon = r
    return math.radians(lat), math.radians(lon)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'Usage example: %s "14°55′58.80″N 24°22′58.80″W"' % sys.argv[0]
        sys.exit(2)
    for arg in sys.argv[1:]:
        r = to_radians(arg)
        if r:
            lat, lon = r
            print '%s,%s' % (lat, lon)
        else:
            print 'Invalid format:', arg

