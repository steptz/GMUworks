#!/usr/bin/python
import sys
import string

for line in sys.stdin:
    line = line.strip()
    words = line.split('\t')
    sys.stdout.write("{}{}{}{}{}\n".format(words[0],'\t', words[1], '\t', words[2],'\n'))