#!/bin/bash
#

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download inputs
#
mark-section "downloading inputs"
dx-download-all-inputs --parallel

#
# Set up options
#
mark-section "running flexbar"
opts=("-u" "$max_uncalled" "-q" "$trim_quality_threshold" "-x" "$trim_left" "-y" "$trim_right" "-m" "$min_length")
if [[ "$phred64" == "true" ]]; then
    opts+=("-f" "i1.3")
else
    opts+=("-f" "sanger")
fi
if [[ "$advanced_options" != "" ]]; then
    opts=()
fi

#
# Add read files
#
input=("-r" "$reads_fastqgz_path")
if [[ "$reads2_fastqgz" != "" ]]; then
    input+=("-p" "$reads2_fastqgz_path")
fi

#
# Optionally trim uploaded adapters
#
if [[ "$adapters_fasta" != "" ]]; then
    input+=("-a" "$adapters_fasta_path")
    if [[ "$adapters2_fasta" != "" ]]; then
        input+=("-a2" "$adapters2_fasta_path")
    fi
fi

flexbar "${input[@]}" -n `nproc` -t output -z GZ "${opts[@]}" $advanced_options

#
# Upload outputs (paired or unpaired)
#
mark-section "uploading outputs"
if [[ "$reads2_fastqgz" == "" ]]; then
    mkdir -p ./out/trimmed_reads_fastqgz
    mv output.fastq.gz ./out/trimmed_reads_fastqgz/"$reads_fastqgz_prefix"_trimmed.fastq.gz
else
    mkdir -p ./out/trimmed_reads_fastqgz ./out/trimmed_reads2_fastqgz
    mv output_1.fastq.gz ./out/trimmed_reads_fastqgz/"$reads_fastqgz_prefix"_trimmed.fastq.gz
    mv output_2.fastq.gz ./out/trimmed_reads2_fastqgz/"$reads2_fastqgz_prefix"_trimmed.fastq.gz
fi
dx-upload-all-outputs --parallel
mark-success
