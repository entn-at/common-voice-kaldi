#!/usr/bin/python

import csv
import os
import sys

script, meta_in, acc_vec_dir, accent_list = sys.argv

with open(accent_list) as accf:
    accents = sorted(list(i.strip() for i in accf.readlines()))
accent_map = {acc: i for i, acc in enumerate(accents)}
accent_vec_map = {}
for acc, i in accent_map.items():
    accent_vec_map[acc] = '[{}{}{} ]'.format(
            ''.join(' 0' for m in range(i)),
            ' 1',
            ''.join(' 0' for n in range(len(accent_map) - 1 - i)))

utt_acc_map = {}

with open(meta_in) as meta_inf:
    meta_reader = csv.DictReader(meta_inf, delimiter='\t')
    for row in meta_reader:
        client_id = row['client_id']
        path = os.path.splitext(row['path'])[0]
        utt_id = '{}-{}'.format(client_id, path)
        accent = row['accent']
        assert accent in accents, 'Unexpected accent: {}\n' \
            'Remove from meta or add to accent list file {}'.format(accent, accent_list)
        utt_acc_map[utt_id] = accent

with open(os.path.join(acc_vec_dir, 'accent_vec.txt'), 'w') as outf:
    for speed in [1, 0.9, 1.1]:
        for utt, acc in sorted(utt_acc_map.items()):
            if speed != 1:
                utt = 'sp{}-{}'.format(speed, utt)
            outf.write('{} {}\n'.format(utt, accent_vec_map[acc]))

