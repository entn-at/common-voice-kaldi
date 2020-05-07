#!/usr/bin/env python

import csv
import os
import sys

script, meta, ref, hyp = sys.argv

spk2acc = {}
with open(meta) as meta_f:
    meta_csv = csv.DictReader(meta_f, delimiter='\t')
    for row in meta_csv:
        spk2acc[row['client_id']] = row['accent']

for f in ref, hyp:
    with open(f) as inf:
        fpath, fname = os.path.split(f)
        outname = os.path.splitext(fname)[0] + "_accent.txt"
        outpath = os.path.join(fpath, outname)
        with open(outpath, 'w') as outf:
            for row in inf:
                stuff = row.strip().split(' ')
                text = ' '.join(stuff[1:])
                utt_id = stuff[0]
                spk, utt = utt_id.split('-')
                outf.write("{} ({}-{})\n".format(text, spk2acc[spk], utt))

