<!-- dx-header -->
# Trinity (DNAnexus Platform App)

Perform a de novo assembly of paired RNA-seq reads using the Trinity pipeline.

This is the source code for an app that runs on the DNAnexus Platform.
For more information about how to run or modify it, see
https://wiki.dnanexus.com/.
<!-- /dx-header -->

Trinity is a pipeline for de novo assembly of paired RNA-seq reads which combines three applications:
Chrysalis, Inchworm and Butterfly. The output is a gzipped tarball of the entire trinity_out_dir, which is huge and contains,
most importantly, Trinity.fasta - the de novo assembly.

Reads should be trimmed, adapter sequences removed, etc. before running this protocol.

Trinity was published in <a href="http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3571712/">Nature Biotechnology</a>. The protocol for transcriptome
assembly and downstream analysis was published in <a href="http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3875132/">Nature Protocols</a>.
