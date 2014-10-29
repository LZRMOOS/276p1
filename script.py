#!/usr/bin/python

# Read and parse file to filter

from sys import argv 
import re

script, filename = argv

txt = open(filename)

for line in txt:
    if re.match("(.*)(L|l)ove(.*)", line):
        print line,

print "Here's your file %r:" % filename
print txt.read()

