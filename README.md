# common-voice-kaldi
Kaldi recipes for multi-accent ASR on the English portion of [Mozilla Common Voice](https://voice.mozilla.org/).

### Models added
After training a baseline [chain TDNN model](https://kaldi-asr.org/doc/chain.html) on all the English data, with no accent-specific information provided, we plan to experiment with the following additions to network inputs during training:

- [x] Baseline chain model pooling all accent data
- [x] 1-hot accent vector
- [ ] Accent-level i-vectors
- [x] Embeddings from separate accent ID system (x-vector?)
- [ ] Output probabilities from separate accent ID system

### Corpus preprocessing
We take only the subset of the English portion of MCV for which accent labels are available, and split into train, dev and test sets using the [Mozilla CorporaCreator](https://github.com/mozilla/CorporaCreator) tool, same as the full dataset. 
All text is uppercased, cleaned of punctuation (except apostrophes in contractions) and has accented or other foreign-language characters normalized and transliterated to the 26 characters used in the English alphabet (where simple to do so, e.g. "ß" > "ss").

### Data summary

#### Train

| Accent         | Duration  | Utterances | Speakers |
| :------------- | --------: | ---------: | -------: |
| US             | 100.5 hrs |      68527 |      886 |
| England        |  26.1 hrs |      18280 |      291 |
| Australia      |  18.0 hrs |      12046 |      102 |
| Canada         |  13.4 hrs |       8883 |      127 |
| Scotland       |   6.6 hrs |       3716 |       25 |
| Ireland        |   2.5 hrs |       1612 |       18 |
| African        |   2.0 hrs |       1366 |       31 |
| Philippines    |  59.0 min |        691 |       12 |
| Singapore      |  45.1 min |        489 |        6 |
| Malaysia       |  16.7 min |        205 |        6 |
| Wales          |  13.7 min |        150 |        9 |
| Hong Kong      |   1.5 min |         21 |        5 |
| South Atlantic |   0.4 min |          7 |        1 |
| Bermuda        |   0.4 min |          6 |        4 |
| **TOTAL**      | 171.4 hrs |     115729 |     1523 |

#### Dev

| Accent         | Duration  | Utterances | Speakers |
| :------------- | --------: | ---------: | -------: |
| US             |  12.5 hrs |       8609 |      804 |
| England        |   4.2 hrs |       2836 |      271 |
| Australia      |   1.4 hrs |        974 |       86 |
| Canada         |   1.2 hrs |        840 |       90 |
| Scotland       |  23.5 min |        243 |       17 |
| Ireland        |  20.8 min |        232 |       18 |
| African        |  23.7 min |        247 |       30 |
| Philippines    |  15.0 min |        177 |       14 |
| Singapore      |  10.6 min |        119 |       10 |
| Malaysia       |  15.7 min |        164 |       13 |
| Wales          |   2.7 min |         28 |        3 |
| Hong Kong      |   5.4 min |         57 |        5 |
| South Atlantic |   0.0 min |          0 |        0 |
| Bermuda        |   2.1 min |         22 |        3 |
| **TOTAL**      |  21.4 hrs |      14548 |     1364 |

#### Test

| Accent         | Duration  | Utterances | Speakers |
| :------------- | --------: | ---------: | -------: |
| US             |  13.2 hrs |       9026 |     2050 |
| England        |   3.7 hrs |       2488 |      590 |
| Australia      |  55.2 min |        631 |      154 |
| Canada         |   1.5 hrs |        998 |      215 |
| Scotland       |  15.5 min |        178 |       41 |
| Ireland        |  28.0 min |        253 |       57 |
| African        |  31.9 min |        344 |       77 |
| Philippines    |  16.2 min |        173 |       43 |
| Singapore      |   5.5 min |         58 |       18 |
| Malaysia       |  11.9 min |        134 |       30 |
| Wales          |   9.7 min |        110 |       22 |
| Hong Kong      |   7.5 min |         82 |       22 |
| South Atlantic |   1.2 min |         14 |        4 |
| Bermuda        |   5.3 min |         59 |       19 |
| _India_        |   3.1 hrs |       2003 |      624 |
| _New Zealand_  |  10.9 min |        120 |       34 |
| **TOTAL**      |  24.8 hrs |      16671 |     4000 |

