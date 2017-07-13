#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x

#
# Fetch and uncompress genome (inside a directory called "genome")
#
mkdir genome
dx download "$genomeindex_targz" -o genome.tar.gz
tar zxvf genome.tar.gz -C genome    # => genome/<ref>.1.bt2l, genome/<ref>.rev.1.bt2l, genome/<ref>.2.bt2l, genome/<ref>.3.bt2l, etc.
genome_file=`ls genome/*.3.bt2l`     # Locate a file called <ref>.3.bt2l
genome_file="${genome_file%.3.bt2l}" # Remove the suffix to keep the <ref>

#
# Fetch and uncompress genes
#
dx download "$genes_gtfgz" -o genes.gtf.gz
gunzip genes.gtf.gz

#
# Reconstitute genome if needed
#
if [[ ! -e "${genome_file}.fa" ]]
then
  bowtie2-inspect "${genome_file}" > "${genome_file}.fa"
fi
if [[ ! -e "${genome_file}.fa.fai" ]]
then
  samtools faidx "${genome_file}.fa"
fi

#
# Index the transcriptome
#
tophat -G genes.gtf --transcriptome-index=transcriptome/genes "${genome_file}"

#
# Archive everything
#
tar zcvf tuxedo_resource.tar.gz genes.gtf genome/ transcriptome/

#
# Upload result
#
name=`dx describe "$genes_gtfgz" --name`
name="${name%.gz}"
name="${name%.gtf}"
file_id=`dx upload tuxedo_resource.tar.gz -o "$name".tuxedo_resource.tar.gz --brief`
dx-jobutil-add-output tuxedo_resource_targz "$file_id"
