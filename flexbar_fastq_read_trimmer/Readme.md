# Flexbar Read Trimmer

## What does this app do?

This app trims reads (paired or unpaired) by quality and/or position.

## What are typical use cases for this app?

This app can be used as a pre-processing step, prior to mapping reads to a reference genome. In most sequencing technologies,
the ability to faithfully call a base deteriorates toward the end of the read. The ends of reads may contain low-quality
bases that are incorrectly called, and these often cause worse performance for certain read mapping software: mis-called
bases map incorrectly or not at all. Sometimes, trimming low-quality bases, or trimming a fixed number of bases from the
end of a read can lead to better mapping results.

## What data are required for this app to run?

This app requires reads files in gzipped fastq format (`*.fastq.gz`), such as those typically produced by Illumina
instruments. A single file is needed for unpaired reads, and two files (left and right read mates) are required for paired reads.

Moreover, the app needs to know the way in which quality scores are encoded in the input files. There are two conventions,
PHRED-33 and PHRED-64. PHRED-33 is produced by Sanger sequencing as well as Illumina (version 1.8 and above), whereas
PHRED-64 was produced by older Illumina versions (1.3 to 1.5).

## What does this app output?

This app outputs the trimmed reads file, in gzipped fastq format. A single file is output for unpaired reads, or two files
(left and right read mates) for paired reads.

## How does this app work?

This app uses Flexbar, a software to preprocess high-throughput sequencing data efficiently. For general information, consult the flexbar manual at:

http://sourceforge.net/p/flexbar/wiki/Manual/

The Flexbar executable is invoked in order to trim reads by position and/or by quality. Depending on the supplied parameters, it will perform one or more of the following:

- Filter out reads that have too many uncalled bases (too many occurrences of `N` or `.`). The `max_uncalled` parameter ("Maximum number of Ns tolerated per read") controls the threshold above which a read is filtered.

- Trim low-quality bases from the 3' (right) end of each read. The `trim_quality_threshold` parameter ("Trim 3' bases lower than quality") is a number, and bases whose quality score is lower than that number will be trimmed. A quality score of 40 represents a base call accuracy of 99.99%; 30 is 99.9%; 20 is 99%; and 10 is 90% (so, a threshold of 10 will remove all bases whose base call accuracy is less than 90%).

- Trim a fixed number of bases from the 5' (left) end of each read. The `trim_left` parameter ("Number of bases to trim from 5'") controls how many bases to trim.

- Trim a fixed number of bases from the 3' (right) end of each read. The `trim_right` parameter ("Number of bases to trim from 3'") controls how many bases to trim.

- Discard reads (and their mates) which, after trimming, became too short. The `min_length` parameter ("Minimum read length allowed") controls the minimum size required so that a read is not discarded.

