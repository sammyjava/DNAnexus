# Cuffdiff

*Please read this important information before running this app.*

## What does this app do?

This app performs differential analysis to identify significant changes in transcript expression, splicing, and promoter use.

## What are typical use cases for this app?

Use this app when you have performed transcriptome sequencing on two or more biological conditions (samples), and want to
quantify the expression of reference gene annotations (and compare that across samples).

When used in conjunction with the Tophat (Known Genes) app, this app implements the Tuxedo protocol. The Tuxedo protocol is
an RNA-Seq protocol for comparing the transcriptome profiles of two or more biological conditions (samples), such as a wild-type
versus mutant or control versus knockdown experiments. It is described in the Nature Protocols publication titled
[Differential gene and transcript expression analysis of RNA-seq experiments with TopHat and Cufflinks](http://www.nature.com/nprot/journal/v7/n3/full/nprot.2012.016.html).
Specifically, what is implemented is the alternative protocol, which performs quantification of reference annotations only
(without any gene or transcript discovery).

## What data are required for this app to run?

This app requires two or more coordinate-sorted BAM files (as output by Tophat) containing the fragment
alignments to be analyzed. Each file will be regarded as a separate sample/condition, except for filenames matching
the pattern `<samplename>.replicate-<N>.bam` (where `<N>` is a replicate index), which will be regarded as replicates
of the same sample. At least two distinct samples (with or without replicates) are required to perform this analysis.
Samples will be analyzed in the same order as they appear in the input.

The app also requires a Tuxedo resource archive (`*.tuxedo_resource.tar.gz`). This is an archive containing the reference genome
and the reference gene annotations that will be used in the analysis. Several popular datasets (from the Illumina iGenomes collection)
are provided as suggested inputs. If you need to use a custom genome or custom gene annotations, refer to the Tuxedo Protocol Resource Builder app.

### Library type

Cuffdiff tries to automatically infer the platform and protocol used to generate input reads. However, in cases where this cannot
be determined, the library type can be provided manually. The following section, copied from the Cuffdiff manual, summarizes
the possible options:

<table>
<tr><td>Library Type</td><td>Examples</td><td>Description</td></tr>
<tr><td>fr-unstranded</td><td>Standard Illumina</td><td>Reads from the left-most end of the fragment (in transcript coordinates) map to the transcript strand, and the right-most end maps to the opposite strand.</td></tr>
<tr><td>fr-firststrand</td><td>dUTP, NSR, NNSR</td><td>Same as above except we enforce the rule that the right-most end of the fragment (in transcript coordinates) is the first sequenced (or only sequenced for single-end reads). Equivalently, it is assumed that only the strand generated during first strand synthesis is sequenced.</td></tr>
<tr><td>fr-secondstrand</td><td>Directional Illumina (Ligation), Standard SOLiD</td><td>Same as above except we enforce the rule that the left-most end of the fragment (in transcript coordinates) is the first sequenced (or only sequenced for single-end reads). Equivalently, it is assumed that only the strand generated during second strand synthesis is sequenced.</td></tr>
</table>

### Library normalization method

Cuffdiff can normalize library sizes (i.e. sequencing depths) in a number of different ways. The following section, copied from
the Cuffdiff manual, summarizes the possible options:

<table>
<tr><td>Normalization Method</td><td>Description</td></tr>
<tr><td>classic-fpkm</td><td>Library size factor is set to 1 - no scaling applied to FPKM values or fragment counts.</td></tr>
<tr><td>geometric</td><td>FPKMs and fragment counts are scaled via the median of the geometric means of fragment counts across all libraries, as described in Anders and Huber (Genome Biology, 2010). This is the default Cuffdiff policy, and is also identical to the one used by DESeq.</td></tr>
<tr><td>quartile</td><td>FPKMs and fragment counts are scaled via the ratio of the 75 quartile fragment counts to the average 75 quartile value across all libraries.</td></tr>
</table>

### Dispersion method

(The following section is copied from the Cuffdiff manual.)

Cuffdiff works by modeling the variance in fragment counts across replicates as a function of the mean fragment count across replicates.
Strictly speaking, it models a quantity called dispersion -- the variance present in a group of samples beyond what is expected from
a simple Poisson model of RNA-Seq. You can control how Cuffdiff constructs its model of dispersion in locus fragment counts.
Each condition that has replicates can receive its own model, or Cuffdiff can use a global model for all conditions.
All of these policies are identical to those used by DESeq (Anders and Huber, Genome Biology, 2010).

<table>
<tr><td>Dispersion Method</td><td>Description</td></tr>
<tr><td>pooled</td><td>Each replicated condition is used to build a model, then these models are averaged to provide a single global model for all conditions in the experiment. (Default)</td></tr>
<tr><td>per-condition</td><td>Each replicated condition receives its own model. Only available when all conditions have replicates.</td></tr>
<tr><td>blind</td><td>All samples are treated as replicates of a single global "condition" and used to build one model.</td></tr>
<tr><td>poisson</td><td>The Poisson model is used, where the variance in fragment count is predicted to equal the mean across replicates. Not recommended.</td></tr>
</table>

- - -

Which method you choose largely depends on whether you expect variability in each group of samples to be similar. For example,
if you are comparing two groups, A and B, where A has low cross-replicate variability and B has high variability, it may be best
to choose per-condition. However, if the conditions have similar levels of variability, you might stick with the default, which
sometimes provides a more robust model, especially in cases where each group has few replicates. Finally, if you only have a
single replicate in each condition, you must use blind, which treats all samples in the experiment as replicates of a single
condition. This method works well when you expect the samples to have very few differentially expressed genes. If there are
many differentially expressed genes, Cuffdiff will construct an overly conservative model and you may not get any significant
calls. In this case, you will need more replicates in your experiment.

## What does this app output?

This app outputs several files, including FPKM and fragment counts for each transcript, primary transcript and gene in each sample.
Results also include several differential expression tests (at the transcript, gene, primary transcript and coding sequence level),
differential splicing tests, differential coding output, differential promoter use, etc. For a full explanation of all the files
produced, refer to the following link:

http://cufflinks.cbcb.umd.edu/manual.html#cuffdiff_output

The app also outputs an HTML file as produced by Vennt. This HTML file can be viewed inside a web browser, and presents
an interactive interface for examining the results. For more information, refer to the following link:

http://drpowell.github.io/vennt/

## How does this app work?

This app runs Cuffdiff. For general information, consult the Cuffdiff manual at:

http://cufflinks.cbcb.umd.edu/manual.html#cuffdiff

