# HUMAnN2 - the HMP Unified Metabolic Analysis Network

### What does this app do?

HUMAnN is a pipeline for efficiently and accurately profiling the presence/absence and abundance of microbial pathways in a community from metagenomic or metatranscriptomic sequencing data (typically millions of short DNA/RNA reads). This process, referred to as functional profiling, aims to describe the metabolic potential of a microbial community and its members. More generally, functional profiling answers the question "What are the microbes in my community-of-interest doing (or capable of doing)?"

### What are the inputs and outputs for this app?

**Inputs**    

* Input file -  a file containing the reads to be analyzed. This input file may be provided either in FASTQ format, if providing raw reads, or in SAM/BAM format, if providing reads that have already been mapped to a pangenome through MetaPhlAn2/Bowtie2.

Additional optional inputs (only relevant if providing a FASTQ formatted input):    

* MetaPhlAn2 pickle file - a metadata [pickled](https://docs.python.org/2/library/pickle.html) MetaPhlAn file. For more information, see the [MetaPhlAn2 documentation.](https://bitbucket.org/biobakery/metaphlan2)
* Ignore markers file - a file containing a list of markers for MetaPhlAn to ignore. 
* Custom MetaPhlAn2 database - a custom database provided to Bowtie2.

Additional settings found under the HUMAnN2 configuration options:

* HUMAnN2 database file - will download this reference database. Options include:
	* uniref90_diamond
	* uniref90_ec_filtered_diamond
	* uniref50_diamond
	* uniref50_ec_filtered_diamond    
If uncertain, it's recommended that the full UniRef90 unfiltered database be used.    
* Number of cores - can be increased for greater speed if using a larger instance size.

**Outputs**

* Gene families output file - the abundance of each gene family in the community. Gene families are groups of evolutionarily-related protein-coding sequences that often perform similar functions.
* Pathway abundance file - the abundance of each pathway in the community as a function of the abundances of the pathway's component reactions, computed as the sum over abundances of genes catalyzing the reaction.
* Pathway coverage file - a description of the presence (1) or the absence (0) of pathways in a community, independent of their quantitative abundance, based on an assigned confidence score.

### How does this app work?

In a full run, when starting from a FASTQ file, HUMAnN2 performs the following steps:

1. Taxonomic profiling of the input reads with MetaPhlAn2
2. Nucleotide-level pangenome mapping with Bowtie2 and the ChocoPhlAn database
3. Attempts to annotate any unmapped reads through a translated DIAMOND search against the selected protein reference database
4. Uses core algorithms to condense data and annotate into pathways through MetaCyc
5. Provides gene family abundance, pathway abundance, and pathway coverage as outputs, stratified by organism.

If the input to HUMAnN2 is a SAM/BAM file, HUMAnN2 will skip the first 3 steps listed above, performing only steps 4 and 5.

### Citation information

Franzosa EA, McIver LJ, Rahnavard G, Thompson LR, Schirmer M, Weingart G, Schwarzberg Lipson K, Knight R, Caporaso JG, Segata N, Huttenhower C. Species-level functional profiling of metagenomes and metatranscriptomes. Nat Methods 15: 962-968 (2018).