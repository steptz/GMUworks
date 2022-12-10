#!/usr/bin/python
import sys

current_word = None
current_count = 0
word = None
current_number = 0.0

for line in sys.stdin:
    line = line.strip()
    word, number, count= line.split('\t')
    try:
        count = int(count)
        number = float(number)
    except ValueError:
        continue

    if current_word == word:
        current_count = current_count + count
        current_number = current_number + number
    else:
        if current_word:
            sys.stdout.write("{}{}{}{}{}\n".format(current_word, '\t', current_number, '\t', current_count))
        current_count = count
        current_word = word
        current_number = number

if current_word == word:
   sys.stdout.write("{}{}{}{}{}\n".format(current_word, '\t', current_number, '\t', current_count)) 


