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

    echo "Value of input file: '$qza_file_name'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".


    dx download "$qza_file"

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
    mkdir exported_feature_table
    qiime tools export --input-path "$qza_file_name" --output-path exported_feature_table/

    # Switching back over to normal Python paths
    source deactivate qiime2-2019.4
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
    export PYTHONPATH=/usr/share/dnanexus/lib/python2.7/site-packages:/usr/share/dnanexus/lib/python2.7/site-packages:/usr/share/dnanexus/lib/python2.7/site-packages:/usr/share/dnanexus/lib/python2.7/site-packages:

    # Returning outputs
    ls exported_feature_table/
    result=$(dx upload exported_feature_table/*.tsv --brief)

    # Adding job outputs
    dx-jobutil-add-output result "$result" --class=file
}