#!/usr/bin/env python

import sys
from math import exp

script, res, l2i, u2l = sys.argv

def read_text_vector(path, expected_dim=14):
    vecs = {}
    with open(path) as vecf:
        for line in vecf:
            vec_split = line.strip('\n').split(' ')
            utt_id = vec_split[0]
            # just in case there are any extra spaces anywhere...
            vec_start = vec_split.index('[') + 1
            vec_end = vec_split.index(']')
            vec = [float(i) for i in vec_split[vec_start:vec_end]]
            assert len(vec) == expected_dim, "Unexpected length in parsed vector: " \
            "{} != {}\n{}: {}".format(len(vec), expected_dim, utt_id, vec)
            vecs[utt_id] = vec
    return vecs

def read_lang2int(path):
    lang2int = {}
    with open(path) as l2if:
        for line in l2if:
            lang, idx = line.strip('\n').split(' ')
            lang2int[lang] = int(idx)
    return lang2int

def read_utt2lang(path):
    utt2lang = {}
    with open(path) as u2lf:
        for line in u2lf:
            utt_id, lang = line.strip('\n').split(' ')
            utt2lang[utt_id] = lang
    return utt2lang

lang2int = read_lang2int(l2i)
utt2lang = read_utt2lang(u2l)
utt2int = {utt: lang2int[lang] for utt, lang in utt2lang.items()}

logsofts = read_text_vector(res)
softs = {utt: list(map(exp, out)) for utt, out in logsofts.items()}

total = len(softs)
correct = 0
for utt, soft in softs.items():
    if soft.index(max(soft)) == utt2int[utt]:
        correct += 1
acc = correct / total * 100
print("{}/{} correct: {:.2f}% accuracy".format(correct, total, acc))

