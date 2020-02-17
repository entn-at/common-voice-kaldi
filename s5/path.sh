export KALDI_ROOT=/opt/kaldi
export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
. $KALDI_ROOT/tools/env.sh
export LC_ALL=C
export LD_LIBRARY_PATH=/opt/kaldi/tools/liblbfgs-1.10/lib:/opt/kaldi/tools/openfst-1.6.7/lib:$LD_LIBRARY_PATH

# For now, don't include any of the optional dependenices of the main
# librispeech recipe
