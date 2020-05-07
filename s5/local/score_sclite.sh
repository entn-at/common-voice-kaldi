#!/usr/bin/sh

. path.sh

test_meta=$1
decode_dir=$2
lm_weight=$3
word_ins_pen=$4

# add accent labels as 'speaker' in sclite format
score_dir=$decode_dir/scoring_kaldi
python local/spk2acc_sclite.py $test_meta $score_dir/test_filt.txt $score_dir/penalty_${word_ins_pen}/${lm_weight}.txt

# run sclite with wer per accent label
part=$(basename ${test_meta%.*})
refs=$score_dir/test_filt_accent.txt
hyps=$score_dir/penalty_${word_ins_pen}/${lm_weight}_accent.txt
$KALDI_ROOT/tools/sctk/bin/sclite -r $refs -h $hyps -i rm -o sum stdout | tee RESULTS_${part}_${lm_weight}_${word_ins_pen}

