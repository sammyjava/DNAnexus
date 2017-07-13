# Tuxedo Protocol Resource Builder

*Please read this important information before running this app.*

## What does this app do?

This app prepares a resource archive (genome and transcriptome sequences and indices) that can be
used by the Tuxedo protocol apps.

## What are typical use cases for this app?

Run this app if you have a custom genome or custom gene annotations that you need to supply to the
Tuxedo protocol apps.

## What data are required for this app to run?

The app requires a Bowtie2 reference genome index (which is the result of
running a reference genome sequence through the Bowtie2 FASTA Indexer app):

- If you are using the human genome, you can choose from preexisting Bowtie2 human reference
genome indices, which are provided as suggestions.
- If you have a custom genome sequence in gzipped FASTA format, please
run the Bowtie2 FASTA Indexer app first.

This app also requires gene annotations in gzipped GTF format. The sequence names in these annotations need
to match the names in the reference genome sequence index.

## What does this app output?

This app outputs a Tuxedo resource archive (which can be subsequently given as input to
the Tuxedo protocol apps).

## How does this app work?

This app uses several utilities from the Bowtie 2 and TopHat 2 packages, in order to extract
and index the transcriptome (the sequences corresponding to genes). For general information,
consult the Bowtie 2 and TopHat 2 manuals at:

http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml

http://tophat.cbcb.umd.edu/manual.shtml

