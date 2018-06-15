#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x

#
# Fetch input mappings
#
name=`dx describe "$sorted_bam" --name`
dx download "$sorted_bam" -o "$name"
input="$name"

#
# Fetch and uncompress resources
#
mkdir resources
dx download "$tuxedo_resource_targz" -o resource.tar.gz
tar zxvf resource.tar.gz -C resources

# Link some inputs
ln -s resources/genes.gtf genes.gtf
ln -s resources/genome/*.fa genome.fa
ln -s resources/genome/*.fa.fai genome.fa.fai
test -e genes.gtf || dx-jobutil-report-error "Genes GTF file not found in Tuxedo resources"
test -e genome.fa || dx-jobutil-report-error "Genome FASTA file not found in Tuxedo resources"

# Add some options
opts=""
if [ "$library_type" != "" ]; then
  opts="$opts --library-type $library_type"
fi

#
# Run cufflinks
#
cufflinks -p `nproc` -o output $opts $advanced_options -u -g genes.gtf -b genome.fa $input

#
# Upload results
#
for file in output/*
do
  file_id=`dx upload "$file" --brief`
  dx-jobutil-add-output --array results "$file_id"
done
