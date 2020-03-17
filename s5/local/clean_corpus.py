#!/usr/bin/env python3
#-*- coding: utf-8 -*-

import argparse
import csv
import os
import re
import string
from unicodedata import normalize


def clean_lines(meta, clean):
    # normalize apostrophes, some we will keep
    fix_apos = str.maketrans("`‘’", "'''")
    # anything else we convert to space, and will squash multiples later
    # this will catch things like hyphens where we don't want to concatenate words
    all_but_apos = "".join(i for i in string.punctuation if i != "'")
    all_but_apos += "–—“”"
    clean_punc = str.maketrans(all_but_apos, (" " * len(all_but_apos)))
    # keep only apostrophes between word chars => abbreviations
    clean_apos = re.compile(r"(\W)'(\W)|'(\W)|(\W)'|^'|'$")
    squash_space = re.compile(r"\s{2,}")
    # chars not handled by unicodedata.normalize because not compositions
    bad_chars = {'Æ': 'AE', 'Ð': 'D', 'Ø': 'O', 'Þ': 'TH', 'Œ': 'OE',
                 'æ': 'ae', 'ð': 'd', 'ø': 'o', 'þ': 'th', 'œ': 'oe',
                 'ß': 'ss', 'ƒ': 'f'}
    clean_chars = str.maketrans(bad_chars)

    with open(meta) as inf, open(clean, 'w') as outf:
        inf_reader = csv.DictReader(inf, delimiter='\t')
        fn = inf_reader.fieldnames
        outf_writer = csv.DictWriter(outf, fieldnames=fn, delimiter="\t")
        outf_writer.writeheader()
        for row in inf_reader:
            line = row['sentence']
            line = line.translate(fix_apos)
            line = line.translate(clean_punc)
            line = re.sub(clean_apos, r"\1 \2", line)
            line = re.sub(squash_space, r" ", line)
            line = line.strip(' ')
            # normalize unicode characters to remove accents etc.
            line = line.translate(clean_chars)
            line = normalize('NFD', line).encode('ascii', 'ignore')
            line = line.decode('UTF-8')
            line = line.upper()
            row['sentence'] = line
            outf_writer.writerow(row)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--meta", type=str, required=True,
            help="Metadata file in TSV format with raw transcriptions")
    parser.add_argument("--clean", type=str, required=True,
            help="Output file for cleaned metadata")
    args = parser.parse_args()
    clean_lines(args.meta, args.clean)

