#!/usr/bin/env python

import sys

from collections import defaultdict
from sklearn.metrics import confusion_matrix

script, meta, scores = sys.argv

with open(meta) as inf:
    utt2lang = {}
    for line in inf:
        utt, lang = line.strip('\n').split(' ')
        utt2lang[utt] = lang

langs = sorted(set(utt2lang.values()))

with open(scores) as inf:
    preds = {}
    for line in inf:
        lang, utt, score = line.strip('\n').split(' ')
        score = float(score)
        if (utt not in preds) or (score > preds[utt][1]):
            preds[utt] = (lang, score)

gold_list = []
pred_list = []
total = len(preds)
correct = 0
lang_correct = defaultdict(int)
for utt, (pred, score) in preds.items():
    if pred == utt2lang[utt]:
        correct += 1
        lang_correct[utt2lang[utt]] += 1
    pred_list.append(pred)
    gold_list.append(utt2lang[utt])


accuracy = correct / total * 100
print("{}/{} correct = {:0.2f}% accuracy".format(correct, total, accuracy))

for lang in langs:
    lang_acc = lang_correct[lang] / sum(1 for i in utt2lang.values() if i == lang)
    print("{}: {:0.2f}%".format(lang, lang_acc * 100))

#print(langs)
#confusions = confusion_matrix(gold_list, pred_list, labels=langs)
#print(confusions)
