#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x

#
# Fetch and analyze input mappings
#
for i in "${!sorted_bams[@]}"; do
  dx download "${sorted_bams[$i]}" -o "input-$i.bam"
  dx describe --name "${sorted_bams[$i]}" >>sample-files.txt
done

ruby1.9.1 /analyze-sample-names.rb < sample-files.txt > results.json

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

#
# Check if genes contain tss_id / p_id, otherwise run cuffcompare
# to generate these fields
#
if ! ( grep -q tss_id genes.gtf && grep -q p_id genes.gtf )
then
  cuffcompare -s genome.fa -CG -r genes.gtf genes.gtf
  mv genes.gtf genes.gtf.old
  mv cuffcmp.combined.gtf genes.gtf
  rm -fr cuffcmp*
fi

#
# Set up options
#
opts=""
if [ "$frag_bias_correct" == "true" ]; then
  opts="$opts -b genome.fa"
fi
if [ "$multi_read_correct" == "true" ]; then
  opts="$opts -u"
fi
if [ "$treat_as_time_series" == "true" ]; then
  opts="$opts -T"
fi
if [ "$fdr" != "" ]; then
  opts="$opts --FDR $fdr"
fi
if [ "$library_type" != "" ]; then
  opts="$opts --library-type $library_type"
fi
if [ "$library_norm_method" != "" ]; then
  opts="$opts --library-norm-method $library_norm_method"
fi
if [ "$dispersion_method" != "" ]; then
  opts="$opts --dispersion-method $dispersion_method"
fi
if [ "$extra_options" != "" ]; then
  opts="$opts $extra_options"
fi

input=`jq -r .inputs < results.json`
labels=`jq -r .labels < results.json`

cuffdiff -p `nproc` -L "$labels" -o output $opts "genes.gtf" $input

vennt.py --cuffdiff output/gene_exp.diff >vennt-report.html

#
# Upload results
#
for file in output/*
do
  file_id=`dx upload "$file" --brief`
  dx-jobutil-add-output --array results "$file_id"
done

file_id=`dx upload vennt-report.html --brief`
dx-jobutil-add-output vennt_html "$file_id"
