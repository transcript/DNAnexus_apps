#!/bin/bash
# humann2 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.

main() {

    echo "Value of input file: '${fastq_input_name}'"
    echo "Database used: '$database'"
    echo "Value of mpa_pkl: '$mpa_pkl'"
    echo "Value of ignore_markers: '$ignore_markers'"
    echo "Value of custom_db: '$custom_db'"
    echo "Value of num_cores: '$num_cores'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    addnl_commands='"'

    dx download "$fastq_input"
    if [ -n "$mpa_pkl" ]
    then
        dx download "$mpa_pkl" -o mpa_pkl
        addnl_commands=$addnl_commands"--mpa_pkl mpa_pkl "
    fi
    if [ -n "$ignore_markers" ]
    then
        dx download "$ignore_markers" -o ignore_markers
        addnl_commands=$addnl_commands"--ignore_markers ignore_markers "
    fi
    if [ -n "$custom_db" ]
    then
        dx download "$custom_db" -o custom_db
        addnl_commands=$addnl_commands"--bowtie2db custom_db "
    fi
    addnl_commands=$addnl_commands"--nproc "$num_cores'"'
    echo "Additional commands used:  "$addnl_commands

    export PATH=$PATH:/metaphlan2/

    # database download
    mkdir databases/
    humann2_databases --download uniref $database databases/
    # HUMAnN2 has its config file automatically updated to point at this database.
    # The ChocoPhlAn database is pre-downloaded as an asset, but the config needs to be updated to point to it.
    sudo humann2_config --update database_folders nucleotide /databases/chocophlan

    # running HUMAnN2
    mkdir output_folder/
    echo "Command used: humann2 --input $fastq_input_name --output output_folder --metaphlan-options ""${addnl_commands}"
    humann2 --input $fastq_input_name --output output_folder --metaphlan-options "${!addnl_commands}"

    # To report any recognized errors in the correct format in
    # $HOME/job_error.json and exit this script, you can use the
    # dx-jobutil-report-error utility as follows:
    #
    #   dx-jobutil-report-error "My error message"
    #
    # Note however that this entire bash script is executed with -e
    # when running in the cloud, so any line which returns a nonzero
    # exit code will prematurely exit the script; if no error was
    # reported in the job_error.json file, then the failure reason
    # will be AppInternalError with a generic error message.

    # The following line(s) use the dx command-line tool to upload your file
    # outputs after you have created them on the local file system.  It assumes
    # that you have used the output field name for the filename for each output,
    # but you can change that behavior to suit your needs.  Run "dx upload -h"
    # to see more options to set metadata.

    gene_families=$(dx upload output_folder/*genefamilies.tsv --brief)
    pathway_abundance=$(dx upload output_folder/*pathabundance.tsv --brief)
    pathway_coverage=$(dx upload output_folder/*pathcoverage.tsv --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output gene_families "$gene_families" --class=file
    dx-jobutil-add-output pathway_abundance "$pathway_abundance" --class=file
    dx-jobutil-add-output pathway_coverage "$pathway_coverage" --class=file
}