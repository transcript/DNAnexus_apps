<!-- dx-header -->
# QIIME2 (DNAnexus Platform App)

A next-generation microbiome bioinformatics platform that is extensible, free, open source, and community developed.

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://wiki.dnanexus.com/.
<!-- /dx-header -->

### What is QIIME2?

QIIME 2 is a powerful, extensible, and decentralized microbiome analysis package with a focus on data and analysis transparency. QIIME 2 enables researchers to start an analysis with raw DNA sequence data and finish with publication-quality figures and statistical results.

(From [https://docs.qiime2.org](https://docs.qiime2.org))

### What steps are performed by this app?

This QIIME2 app is designed to handle the core taxonomy analysis of one or more input samples.  The app performs the following steps:

* Demultiplexing, if a barcodes file is provided    
(skipped if already-demultiplexed in CasavaOneEight format)
* Quality score correction and read cleaning, using dada2
* Taxonomy classification using the default GreenGenes classifier
* Barplot generation of taxonomy assignments

### What are the inputs for the app?

Necessary:

* One or more sequence files, in fastq.gz format.

Optional:

* A barcodes file (if supplying files that have not been demultiplexed)
* A metadata file, containing a row for each sample-id.  If a metadata file is not supplied, one will be created (containing only the file names).

### What are the outputs of the app?

1. rep-seqs.qza - a QIIME2 artifact containing the quality-corrected and filtered, cleaned reads.
2. taxonomy.qza - a QIIME2 artifact containing the taxonomy assignments for the data.
3. table.qza - a QIIME2 artifact containing the feature table for the data.
4. taxa-bar-plots.qzv - a QIIME2 visualization of the taxonomy assignments for all of the submitted sequence files.  This can be viewed on [http://view.qiime2.org](http://view.qiime2.org).
5. metadata - a plain-text file containing the metadata used by QIIME2.

### Where can I find more information on using QIIME2?

A good place to start is [the QIIME2 documentation, which is extensive.](https://docs.qiime2.org/2019.1/)
