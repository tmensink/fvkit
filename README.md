# FV-Kit
**Fisher Vector Extraction Kit** provides a Matlab implementation to extract Fisher Vectors from images


This `FVKit` package provides a Matlab implementation to extract Fisher Vectors from images/videos. It is written with a two fold reasoning: First to provide an easy to understand extraction pipeline for visual features. Second, for extensive experiments with FV. (This second motivation is somewhat outdated with the raise of ConvNets).

The `FVKit` is written completely in Matlab, and only have dependencies for SVM classification and for extraction the local SIFT features (see below).

The `FVKit` has been used to extract the features for the [Rijksmuseum Challnge Github](https://github.com/tmensink/rijkschallenge), introduced in [mensink14icmr].

## Demo and Comparison on Pascal VOC 2007
The package contains a demo script (`demo_voc2007`) to show the usage and to run some experiments on the Pascal VOC 2007 dataset.

##### Download Pascal VOC 2007
Download [Pascal VOC2007](http://host.robots.ox.ac.uk/pascal/VOC/voc2007/) dataset to the `data/voc2007` directory.
* See download (and extraction) script in data directory
* The IMDB file -which provides the ground truth and training and testing splits- provided in the `data/voc2007` directory is obtained from:
  * [Encoding methods evaluation toolkit](http://www.robots.ox.ac.uk/~vgg/software/enceval_toolkit/)
  * Used in the paper [chatfield11bmvc]

##### Experiments  
Below the results are shown for some different parameters.
As baseline system we follow largely the paper of [sanchez13ijcv]:
* Extract SIFT from grey valued images
* PCA to 60 dimensions + 4 dimensions for location, SIFT norm and scale
* Gaussian Mixture Model with 256 components
* FV with closed form approximation of FIM, and derivatives with respect to mean and variance
* Pooling: extract one FV per image
* LibSVM with linear kernel, cross-validate value of C (single C value for all classes)

**Experiments with PCA, Color SIFT and Pooling**

PCA dimension | mAP       | Color SIFT    | mAP       | Pooling | mAP     |
--------------|-----------|---------------|-----------|---------|---------|
32 (28+4)     | 57.70     |**Intensity**  |**61.23**  |**Full** |**61.23**
**64 (60+4)** |**61.23**  | Opponent      | 58.16     |F+Horiz  | 61.71
128 (124+4)   | 62.29     | Hue           | 56.61     |FH+Quad  | 62.23

**Experiments with number of GMM components**

GMM Components | 16   |  32   | 64    | 128   | 256       |
---------------|------|-------|-------|-------|-----------|
**mAP**        |53.12 |	56.19 | 58.12 | 59.63 | **61.23**


The settings to run these experiments is available in `demo_voc2007.m`

**Comparison to other implementations**
We compare to two other papers, including results on Pascal VOC 2007 and indicate some of the key differences
* [sanchez13ijcv] they do not provide code, but one of the core reasons for the initial development of the  `FVKit` package was to reprocude their results
* [chatfield11bmvc] they do provide code, for many more (old-fashioned) visual encodings, yet especially the FV code is not very clear/intuitive to use nor to extend for other research in Fisher Vectors.

Paper / Package     | mAP   |
--------------------|-------|
 [sanchez13ijcv]    | 61.8  | (Table 1, page 8)
 [chatfield11bmvc]  | 61.7  | (Table 1, page 7)
 `FVKit` Matlab     | 62.2  | (See above)

 Results differ, among others, due to:
 * different PCA dimensions (64 vs 80);
 * different SIFT extraction code (proprietary vs VL-Feat);
 * use of LNS encoding and square rooting (this package);
 * differences due to implementation (eg EM, SVM, etc)

## Demo and Comparison on Rijksmusem Challenge 2014
The package contains a demo script (`demo_RMC`) to extract FV for the RMC challenge and evaluate the performance on the Creator challenge

For more information about the Rijksmusem Challenge:
* [Rijksmuseum Challenge Github](https://github.com/tmensink/rijkschallenge)
* [RMC14 dataset](https://figshare.com/articles/Rijksmuseum_Challenge_2014/5660617)

The demo script extract FV and then run the Creator challenge. It obtains the following results

Creator Challenge MCA:  | all   | 374   | 300   | 200   | 100   |
------------------------|-------|-------|-------|-------|-------|
FV Kit demo             | 55.6  | 69.3  | 71.5  | 75.4  | 79.8
[mensink14icmr]         | 51.0  | 65.5  | 67.6  | 71.2  | 75.8

These differences are (likely) due to square rooting of SIFT features and the LNS encoding of projected features. The features used in [mensink14icmr] are available for download (see above)

## References
##### Citations
When using this code, please cite the following papers

    @INPROCEEDINGS{mensink14icmr,
      author = {Thomas Mensink and Jan van Gemert},
      title = {The Rijksmuseum Challenge: Museum-Centered Visual Recognition},
      booktitle = {ACM International Conference on Multimedia Retrieval (ICMR)},
      year = {2014}
      }

    @ARTICLE{sanchez13ijcv,
       author = {Jorge S&aacute;nchez and Florent Perronnin and Thomas Mensink and Jakob Verbeek},
       title = {Image Classification with the Fisher Vector: Theory and Practice},
       journal = {International Journal on Computer Vision (IJCV)},
       year = {2013},
      }      


##### References
1. [chatfield11bmvc] **Chatfield et al.**, *The devil is in the details: an evaluation of recent feature encoding methods*, **BMVC 2011**
1. [mensink14icmr] **Mensink and van Gemert**, *The Rijksmuseum Challenge: Museum-Centered Visual Recognition*, **ICMLR 2014** ([pdf](https://staff.fnwi.uva.nl/t.e.j.mensink/publications/mensink14icmr.pdf))
1. [sanchez13ijcv] **Sanchez et al.**, *The Fisher Vector: Theory and Practice*, **IJCV 2014** ([pdf](https://staff.fnwi.uva.nl/t.e.j.mensink/publications/sanchez13ijcv.pdf))


### Copyright (2013-2018)
Thomas Mensink, University of Amsterdam, thomas.mensink@uva.nl:
