#!/usr/bin/python

import sys

script, meta, vecs, trials = sys.argv

# just in case any accent vector extractions failed,
# check against the final scp
with open(vecs) as inf:
    got_vecs = set()
    for line in inf:
        utt, _ = line.strip('\n').split(' ')
        got_vecs.add(utt)

with open(meta) as inf:
    utt2lang = {}
    for line in inf:
        utt, lang = line.strip('\n').split(' ')
        if utt in got_vecs:
            utt2lang[utt] = lang

langs = set(utt2lang.values())

with open(trials, 'w') as outf:
    for utt in utt2lang:
        for lang in langs:
            if lang == utt2lang[utt]:
                outf.write('{} {} target\n'.format(lang, utt))
            else:
                outf.write('{} {} nontarget\n'.format(lang, utt))
