#!/bin/bash

# Copyright   2014  Johns Hopkins University (author: Daniel Povey)
#             2017  Luminar Technologies, Inc. (author: Daniel Galvez)
#             2017  Ewald Enzinger
#             2020  Dan Wells
# Apache 2.0

# Adapted from egs/mini_librispeech/s5/local/download_and_untar.sh (commit 1cd6d2ac3a935009fdc4184cb8a72ddad98fe7d9)

remove_archive=false

if [ "$1" == --remove-archive ]; then
  remove_archive=true
  shift
fi

if [ $# -ne 2 ]; then
  echo "Usage: $0 [--remove-archive] <data-base> <url>"
  echo "e.g.: $0 /export/data/ https://voice-prod-bundler-ee1969a6ce8178826482b88e843c335139bd3fb4.s3.amazonaws.com/cv-corpus-4-2019-12-10/en.tar.gz"
  echo "Downloads and extracts 1488h English portion of Common Voice release 2019-12-10 to <data-base>"
  echo "With --remove-archive it will remove the archive after successfully un-tarring it."
fi

data=$1
url=$2

if [ ! -d "$data" ]; then
  echo "$0: no such directory $data"
  exit 1;
fi

if [ -z "$url" ]; then
  echo "$0: empty URL."
  exit 1;
fi

if [ -f $data/.complete ]; then
  echo "$0: data was already successfully extracted, nothing to do."
  exit 0;
fi

filepath="$data/en.tar.gz"
filesize="41448227462"

if [ -f $filepath ]; then
  size=$(/bin/ls -l $filepath | awk '{print $5}')
  size_ok=false
  if [ "$filesize" -eq "$size" ]; then size_ok=true; fi;
  if ! $size_ok; then
    echo "$0: removing existing file $filepath because its size in bytes ($size)"
    echo "does not equal the size of the archives ($filesize)."
    rm $filepath
  else
    echo "$filepath exists and appears to be complete."
  fi
fi

if [ ! -f $filepath ]; then
  if ! which wget >/dev/null; then
    echo "$0: wget is not installed."
    exit 1;
  fi
  echo "$0: downloading data from $url.  This may take some time, please be patient."

  cd $data
  if ! wget --no-check-certificate $url; then
    echo "$0: error executing wget $url"
    exit 1;
  fi
fi

cd $data

echo "$0: un-tarring downloaded data.  This may take some time, please be patient."
if ! tar -xzf $filepath; then
  echo "$0: error un-tarring archive $filepath"
  exit 1;
fi

touch $data/.complete

echo "$0: Successfully downloaded and un-tarred $filepath"

if $remove_archive; then
  echo "$0: removing $filepath file since --remove-archive option was supplied."
  rm $filepath
fi

if [ -n $(which soxi) ]; then
  for part in train dev test validated invalidated other; do
    echo "$0: adding audio durations to metadata file $part..."
    while read f; do 
      soxi -D clips/$f >> ${part}_durs.txt 2>&1
    done < <(cut -d'       ' -f2 ${part}.tsv)
    if [ $(wc -l < ${part}.tsv) -eq $(wc -l < ${part}_durs.txt) ]; then
      # bad audio files get 0 duration
      paste ${part}.tsv - < <(awk 'NR == 1 && /FAIL/ { print "duration" } NR > 1 && /FAIL/ { print "0" } !/FAIL/ { print $1 }' ${part}_durs.txt) > tmp.tsv
      mv tmp.tsv ${part}.tsv
      rm ${part}_durs.txt
    else
      echo "$0: mismatched number of lines in ${part}.tsv and ${part}_durs.txt, not merging"
    fi
  done
else
  echo "$0: soxi not found, unable to add audio durations to metadata files."
fi

