#!/bin/bash
# blastn 0.0.1
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

    echo "Value of db_fasta_gz: '$db_fasta_gz'"
    echo "Value of query_fasta_gz: '$query_fasta_gz'"
    echo "Value of outfmt: '$outfmt'"
    echo "Value of evalue: '$evalue'"
    echo "Value of perc_identity: '$perc_identity'"
    echo "Value of culling_limit: '$culling_limit'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$db_fasta_gz" -o db.fasta.gz
    dx download "$query_fasta_gz" -o query.fasta.gz

    # Fill in your application code here.
    #
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

    # set up options
    opts="-outfmt $outfmt"
    if [ "$evalue" != "" ]; then
	opts="$opts -evalue $evalue"
    fi
    if [ "$perc_identity" != "" ]; then
	opts="$opts -perc_identity $perc_identity"
    fi
    if [ "$culling_limit" != "" ]; then
	opts="$opts -culling_limit $culling_limit"
    fi

    # uncompress the input FASTAs
    echo "Unzipping FASTA files..."
    gunzip db.fasta.gz
    gunzip query.fasta.gz
    echo "...done."

    # index the db FASTA
    echo "Indexing database FASTA..."
    makeblastdb -dbtype nucl -in db.fasta
    echo "...done."

    # run blastn on all the available cores
    cores=`nproc`
    echo "Running blastn with $cores cores..."
    blastn -num_threads $cores -db db.fasta -query query.fasta $opts > output
    echo "...done."

    # compress the output file
    echo "Compressing output file..."
    gzip output
    echo "...done."

    # The following line(s) use the dx command-line tool to upload your file
    # outputs after you have created them on the local file system.  It assumes
    # that you have used the output field name for the filename for each output,
    # but you can change that behavior to suit your needs.  Run "dx upload -h"
    # to see more options to set metadata.

    output_gz=$(dx upload output.gz --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    dx-jobutil-add-output output_gz "$output_gz" --class=file
}
