#!/bin/bash
data=$1

set -euo pipefail

if [ ! $(which create-corpora) ]; then
  echo "$0: Mozilla CorporaCreator tool not installed. Get it here to prepare" 
  echo "dataset with accent labels for all utterances: https://github.com/mozilla/CorporaCreator"
  exit 1
fi

# We must repurpose existing metadata files to recreate clips.tsv file
# dumped from Common Voice database expected by CorporaCreator.

cd $data

if [ ! -d orig_meta ]; then
  echo "$0: moving original metadata files to $data/orig_meta"
  mkdir orig_meta
  mv *.tsv orig_meta
fi

echo "$0: creating clips.tsv containing only accent-labelled utterances"
awk 'BEGIN {
  FS="\t";
  OFS="\t";
}
# Grab header only from first file
FNR==1 && NR!=1 {
  while (/^client_id/) getline;
}
# Add fields expected by CorporaCreator
NR==1 {
    print $0, "locale", "bucket"
}
# Skip rows with no or accent label "other", and empty transcriptions
NR>1 && $8!="" && $8!="other" && $3!="" {
    print $0, "en", ""
}' orig_meta/{validated.tsv,invalidated.tsv,other.tsv} > clips.tsv

echo "$0: preparing train-dev-test partitions using CorporaCreator"
create-corpora -d $data -f clips.tsv

mv en/*tsv .
rmdir en

