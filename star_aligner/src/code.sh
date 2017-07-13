#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download the reads
#
dx-download-all-inputs --except genomeindex_tar

#
# Fetch and uncompress the genome
#
mkdir ./genome
dx cat "$genomeindex_tar" | tar xvf - -C ./genome

#
# Set up options
#
opts="--outSAMstrandField intronMotif --quantMode TranscriptomeSAM GeneCounts --twopassMode Basic --readFilesIn ./in/reads_fastqgz/*"
if [ "$reads2_fastqgz" != "" ]; then
  opts="$opts ./in/reads2_fastqgz/*"
fi
if [ "$out_filter_intron_motifs" != "" ]; then
  opts="$opts --outFilterIntronMotifs $out_filter_intron_motifs"
fi

STAR --version
STAR --genomeDir ./genome/ --runThreadN `nproc` --readFilesCommand zcat --outReadsUnmapped Fastx --outStd SAM $opts $extra_options | samtools view -u -S - | samtools sort -m 256M -@ `nproc` - output

#
# Upload results
#

name=`dx describe "$reads_fastqgz" --name`
name="${name%.gz}"
name="${name%.fastq}"
name="${name%.fq}"
name="${name%_1}"
if [ "$sample_name" != "" ]; then
  name="$sample_name"
fi

mkdir ./out/
mkdir ./out/sorted_bam
mkdir ./out/sj_tsv
mkdir ./out/unmapped_fastx
mkdir ./out/quant

mv output.bam ./out/sorted_bam/"$name".bam
mv SJ.out.tab ./out/sj_tsv/"$name".splice_junctions.tsv
mv Unmapped.out.mate1 ./out/unmapped_fastx/"$name".Unmapped.out.mate1.fastq
mv Unmapped.out.mate2 ./out/unmapped_fastx/"$name".Unmapped.out.mate2.fastq
mv ReadsPerGene.out.tab ./out/quant/"$name".ReadsPerGene.out.tab
mv Aligned.toTranscriptome.out.bam ./out/quant/"$name".Aligned.toTranscriptome.out.bam

# send 'em up!
dx-upload-all-outputs
