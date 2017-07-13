#!/bin/bash

# The following line causes bash to exit at any point if there is any error
# and to output each line as it is executed -- useful for debugging
set -e -x -o pipefail

#
# Download the inputs (genome, and optionally the genes)
#
dx cat "$genome_fastagz" | zcat > genome.fa
if [[ "$genes_gtfgz" != "" ]]
then
  dx cat "$genes_gtfgz" | zcat > genes.gtf
  opts="--sjdbGTFfile genes.gtf --sjdbOverhang $overhang"
fi

mkdir ./genome

STAR --version
STAR --runMode genomeGenerate --genomeDir ./genome/ --genomeFastaFiles ./genome.fa --runThreadN `nproc` $opts $extra_options

#
# Upload results
#
name=`dx describe "$genome_fastagz" --name`
name="${name%.gz}"

cd ./genome
mkdir -p ~/out/index_tar
tar cf ~/out/index_tar/"$name".star-index.tar *

dx-upload-all-outputs
