#!/usr/bin/perl
#
# Copyright 2017   Ewald Enzinger
# Apache 2.0
#
# Usage: data_prep.pl /export/data/cv_corpus_v1 train data/train

if (@ARGV != 3) {
  print STDERR "Usage: $0 <path-to-commonvoice-corpus> <dataset> <out-dir>\n";
  print STDERR "e.g. $0 /export/data/cv_en_1488h_20191210 train data/train\n";
  exit(1);
}

($db_base, $dataset, $out_dir) = @ARGV;
#mkdir data unless -d data;
mkdir $out_dir unless -d $out_dir;

open(TSV, "<", "$db_base/$dataset.tsv") or die "cannot open dataset TSV file";
open(SPKR,">", "$out_dir/utt2spk") or die "Could not open the output file $out_dir/utt2spk";
open(GNDR,">", "$out_dir/utt2gender") or die "Could not open the output file $out_dir/utt2gender";
open(TEXT,">", "$out_dir/text") or die "Could not open the output file $out_dir/text";
open(WAV,">", "$out_dir/wav.scp") or die "Could not open the output file $out_dir/wav.scp";
my $header = <TSV>;
while(<TSV>) {
  chomp;
  ($client_id, $filepath, $text, $upvotes, $downvotes, $age, $gender, $accent) = split("\t", $_);
  # TODO: gender information is probably not used anywhere?
  if ("$gender" eq "female") {
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
  # TODO: these are obnoxious, do we still need this/any transcript cleaning?
  #$text =~ s/ said 'eat when/ said eat when/g;
  #$text =~ s/'and this is what your son said'/and this is what your son said/g;
  #$text =~ s/^'m /i'm /g;
  #$text =~ s/'mummy'/mummy/g;
  #$text =~ s/'poppy'/poppy/g;
  #$text =~ s/'every/every/g;
  #$text =~ s/'super fun playground'/super fun playground/g;
  #$text =~ s/'under construction'/under construction/g;
  # Uppercase all transcripts
  $text =~ tr/a-z/A-Z/;
  print TEXT "$uttId"," ","$text","\n";
  print GNDR "$uttId"," ","$gender","\n";
  # This will be read as a Kaldi pipe to downsample audio
  print WAV "$uttId"," sox $db_base/clips/$filepath -t wav -r 16k -b 16 -e signed - |\n";
  print SPKR "$uttId"," $spkr","\n";
}
close(SPKR) || die;
close(TEXT) || die;
close(WAV) || die;
close(GNDR) || die;
close(WAVLIST);

if (system(
  "utils/utt2spk_to_spk2utt.pl $out_dir/utt2spk >$out_dir/spk2utt") != 0) {
  die "Error creating spk2utt file in directory $out_dir";
}
system("env LC_COLLATE=C utils/fix_data_dir.sh $out_dir");
if (system("env LC_COLLATE=C utils/validate_data_dir.sh --no-feats $out_dir") != 0) {
  die "Error validating directory $out_dir";
}
