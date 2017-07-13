#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x

#
# Fetch and uncompress resources
#
mkdir resources
dx cat "$tuxedo_resource_targz" | tar zxvf - -C resources
genome_index=`ls resources/genome/*.3.bt2*` # Locate a file called <ref>.3.bt2 or <ref>.3.bt2l
genome_index="${genome_index%.3.bt2}"       # Remove the suffix to keep the <ref>
genome_index="${genome_index%.3.bt2l}"      # (The suffix could be either .3.bt2 or .3.bt2l)
transcriptome_index="resources/transcriptome/genes"

#
# Fetch reads
#
input=""
for i in "${!reads_fastqgz[@]}"; do
  dx download "${reads_fastqgz[$i]}" -o "input-$i.fq.gz"
  input="$input input-$i.fq.gz"
done
# Tophat wants the files given as comma-separated
input=`echo "$input" | sed 's/ /,/g' | cut -c2-`

if [ "$reads2_fastqgz" != "" ]; then
  input2=""
  for i in "${!reads2_fastqgz[@]}"; do
    dx download "${reads2_fastqgz[$i]}" -o "input2-$i.fq.gz"
    input2="$input2 input2-$i.fq.gz"
  done
  input2=`echo "$input2" | sed 's/ /,/g' | cut -c2-`
  input="$input $input2"
fi

#
# Set up options
#
opts=""
if [ "$mate_inner_dist" != "" ]; then
  opts="$opts -r $mate_inner_dist"
fi
if [ "$library_type" != "" ]; then
  opts="$opts --library-type $library_type"
fi
if [ "$phred64" == "true" ]; then
  opts="$opts --solexa1.3-quals"
fi
if [ "$preset" != "" ]; then
  opts="$opts --b2-$preset"
fi
if [ "$transcriptome_only" == "true" ]; then
  opts="$opts --transcriptome-only"
fi
if [ "$no_novel_juncs" == "true" ]; then
  opts="$opts --no-novel-juncs"
fi
if [ "$extra_options" != "" ]; then
  opts="$opts $extra_options"
fi

tophat -p `nproc` -o output --transcriptome-index "$transcriptome_index" $opts "$genome_index" $input

#
# Upload result
#
name=`dx describe "$reads_fastqgz" --name`
name="${name%.gz}"
name="${name%.fastq}"
name="${name%.fq}"
name="${name%_1}"
if [ "$sample_name" != "" ]; then
  name="$sample_name"
fi
if [ "$replicate_index" != "" ]; then
  name="$name.replicate-$replicate_index"
fi
summary_name="${name}.align_summary.txt"
file_id=`dx upload output/align_summary.txt -o "$summary_name" --brief`
dx-jobutil-add-output summary_txt "$file_id"
name="${name}.bam"
file_id=`dx upload output/accepted_hits.bam -o "$name" --brief`
dx-jobutil-add-output sorted_bam "$file_id"
