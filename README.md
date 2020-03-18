# common-voice-kaldi
Kaldi recipes for multi-accent ASR on the English portion of [Mozilla Common Voice](https://voice.mozilla.org/).

### Models added
After training a baseline [chain TDNN model](https://kaldi-asr.org/doc/chain.html) on all the English data, with no accent-specific information provided, we plan to experiment with the following additions to network inputs during training:

- [x] Baseline chain model pooling all accent data
- [ ] 1-hot accent vector
- [ ] Accent-level i-vectors
- [ ] Embeddings from separate accent ID system (x-vector?)
- [ ] Output probabilities from separate accent ID system

### Corpus preprocessing
We take only the subset of the English portion of MCV for which accent labels are available, and split into train, dev and test sets using the [Mozilla CorporaCreator](https://github.com/mozilla/CorporaCreator) tool, same as the full dataset. 
All text is uppercased, cleaned of punctuation (except apostrophes in contractions) and has accented or other foreign-language characters normalized and transliterated to the 26 characters used in the English alphabet (where simple to do so, e.g. "ß" > "ss").

