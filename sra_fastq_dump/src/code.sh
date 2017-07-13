#!/bin/bash

set -e -x -o pipefail

mkdir out
mkdir out/output_fastqs

fastq-dump --gzip --split-files --outdir out/output_fastqs --accession $srr_accession

dx-upload-all-outputs --parallel
