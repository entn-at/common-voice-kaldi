#!/usr/bin/perl
#
# Copyright 2017   Ewald Enzinger
# Apache 2.0
#
# Usage: data_prep.pl /export/data/cv_corpus_v1 train data/train

if (@ARGV != 4) {
  print STDERR "Usage: $0 <path-to-commonvoice-corpus> <path-to-meta> <dataset> <out-dir>\n";
  print STDERR "e.g. $0 /export/data/cv_en_1488h_20191210 data train data/train\n";
  exit(1);
}

($db_base, $meta_base, $dataset, $out_dir) = @ARGV;
mkdir $out_dir unless -d $out_dir;

open(TSV, "<", "$meta_base/$dataset.tsv") or die "cannot open dataset TSV file";
open(SPKR,">", "$out_dir/utt2spk") or die "Could not open the output file $out_dir/utt2spk";
open(GNDR,">", "$out_dir/utt2gender") or die "Could not open the output file $out_dir/utt2gender";
open(LANG,">", "$out_dir/utt2lang") or die "Could not open the output file $out_dir/utt2lang";
open(TEXT,">", "$out_dir/text") or die "Could not open the output file $out_dir/text";
open(WAV,">", "$out_dir/wav.scp") or die "Could not open the output file $out_dir/wav.scp";
my $header = <TSV>;
while(<TSV>) {
  chomp;
  ($client_id, $filepath, $text, $upvotes, $downvotes, $age, $gender, $accent) = split("\t", $_);
  # TODO: these are empty files, ideally should exclude before sampling data
  next if $filepath =~ /common_voice_en_194119(6[5-8]|7[4-8]|8[4-9]|9[02])\.mp3/;
  # TODO: gender information is probably not used anywhere?
  if ($gender eq "female") {
    $gender = "f";
  } else {
    # Use male as default if not provided (no reason, just adopting the same default as in voxforge)
    $gender = "m";
  }
  # Assume client ID uniquely identifies speakers (i.e. nobody shared a recording device)
  $spkr = $client_id;
  # Prefix filename with client ID so that everything sorts together as it should
  # n.b. these are VERY LONG without creating a new mapping from client ID to snappier speaker ID
  $uttId = "$client_id-$filepath";
  $uttId =~ s/\.mp3//g;
  $uttId =~ tr/\//-/;
  print TEXT "$uttId"," ","$text","\n";
  print GNDR "$uttId"," ","$gender","\n";
  print LANG "$uttId"," ","$accent","\n";
  # This will be read as a Kaldi pipe to downsample audio
  print WAV "$uttId"," sox $db_base/clips/$filepath -t wav -r 16k -b 16 -e signed - |\n";
  print SPKR "$uttId"," $spkr","\n";
}
close(SPKR) || die;
close(TEXT) || die;
close(WAV)  || die;
close(GNDR) || die;
close(LANG) || die;
close(WAVLIST);

if (system(
  "utils/utt2spk_to_spk2utt.pl $out_dir/utt2spk >$out_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_dir";
}
if (system(
  "utils/utt2spk_to_spk2utt.pl $out_dir/utt2lang >$out_dir/lang2utt") != 0) {
  die "Error creating lang2utt file in directory $out_dir";
}
system("env LC_COLLATE=C utils/fix_data_dir.sh $out_dir");
if (system("env LC_COLLATE=C utils/validate_data_dir.sh --no-feats $out_dir") != 0) {
  die "Error validating directory $out_dir";
}
