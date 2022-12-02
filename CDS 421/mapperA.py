#!/usr/bin/python
import sys
import string

for line in sys.stdin:
    line = line.strip()
    words = line.split(",")
    sys.stdout.write("{}{}{}{}{}\n".format(words[3],'\t', words[7], '\t', 1,'\n'))
