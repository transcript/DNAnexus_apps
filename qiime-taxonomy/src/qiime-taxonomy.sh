#!/bin/bash
# qiime 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of sequences: '${sequences[@]}'"
    echo "Value of barcodes: '$barcodes'"
    echo "Value of metadata: '$metadata'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    mkdir starting_seqs/
    for file in "${sequences[@]}"; do
      dx download "$file" -o starting_seqs/
    done
    if [ -n "$metadata" ]
    then
        dx download "$metadata" -o metadata
    else
        echo "Creating metadata file."
        touch metadata
        echo "sample-id" > metadata
        for file in starting_seqs/*; do
          short=$(basename $file)
          echo $short
          echo "$short" >> metadata
        done
    fi
    if [ -n "$barcodes" ]
    then
        dx download "$barcodes" -o starting_seqs/
    fi

    # setup/installation of QIIME
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b -p "$HOME"/miniconda
    export PATH="$HOME/miniconda/bin:$PATH"
    unset PYTHONPATH
#    conda update conda
    wget https://data.qiime2.org/distro/core/qiime2-2019.4-py36-linux-conda.yml
    conda env create -n qiime2-2019.4 --file qiime2-2019.4-py36-linux-conda.yml --quiet
    source activate qiime2-2019.4

    # running QIIME
    # importing the sequences into QIIME
    if [ -n "$barcodes" ]; then
      qiime tools import --type EMPSingleEndSequences --input-path starting_seqs --output-path sequences.qza
    else
      qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path starting_seqs --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path sequences.qza
    fi

    # Demultiplexing, if necessary
    if [ -n "$barcodes" ]; then
      qiime demux emp-single --i-seqs sequences.qza --m-barcodes-file metadata --m-barcodes-column BarcodeSequence --o-per-sample-sequences demux.qza
    else
      cp sequences.qza demux.qza
    fi

    # Quality Score correction/cleaning reads
    qiime quality-filter q-score --i-demux demux.qza --o-filtered-sequences demux-filtered.qza --o-filter-stats demux-filter-stats.qza
#    qiime deblur denoise-16S --i-demultiplexed-seqs demux-filtered.qza --p-trim-length 120 --o-representative-sequences rep-seqs.qza --o-table table.qza --p-sample-stats --o-stats deblur-stats.qza
    qiime dada2 denoise-single --i-demultiplexed-seqs demux.qza --p-trim-left 0 --p-trunc-len 120 --o-representative-sequences rep-seqs.qza --o-table table.qza --o-denoising-stats stats-dada2.qza

    # Creating a visualization of the quality correction
    qiime metadata tabulate --m-input-file demux-filter-stats.qza --o-visualization demux-filter-stats.qzv

    # Taxonomy classification
    # Greengenes default classifier
    wget -O "gg-13-8-99-515-806-nb-classifier.qza" "https://data.qiime2.org/2019.4/common/gg-13-8-99-nb-classifier.qza" --quiet
    qiime feature-classifier classify-sklearn --i-classifier gg-13-8-99-515-806-nb-classifier.qza --i-reads rep-seqs.qza --o-classification taxonomy.qza
    qiime metadata tabulate --m-input-file taxonomy.qza --o-visualization taxonomy.qzv

    # making the barplot
    qiime taxa barplot --i-table table.qza --i-taxonomy taxonomy.qza --m-metadata-file metadata --o-visualization taxa-bar-plots.qzv

    # Switching back over to normal Python paths
    source deactivate qiime2-2019.4
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
    export PYTHONPATH=/usr/share/dnanexus/lib/python2.7/site-packages:/usr/share/dnanexus/lib/python2.7/site-packages:/usr/share/dnanexus/lib/python2.7/site-packages:/usr/share/dnanexus/lib/python2.7/site-packages:

    # Returning outputs
    rep_seqs=$(dx upload rep-seqs.qza --brief)
    feature_table=$(dx upload table.qza --brief)
    taxonomy=$(dx upload taxonomy.qza --brief)
    taxa_bar_plots=$(dx upload taxa-bar-plots.qzv --brief)
    metadata_out=$(dx upload metadata --brief)

    # Adding job outputs
    dx-jobutil-add-output rep_seqs "$rep_seqs" --class=file
    dx-jobutil-add-output feature_table "$feature_table" --class=file
    dx-jobutil-add-output taxonomy "$taxonomy" --class=file
    dx-jobutil-add-output taxa_bar_plots "$taxa_bar_plots" --class=file
    dx-jobutil-add-output metadata  "$metadata_out" --class=file
}