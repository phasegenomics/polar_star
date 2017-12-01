# Polar Star

This code analyzes the read depth along long-read contigs and finds outliers. 

## Dependencies  



The Polar Star pipeline installs several common bioinformatics tools:
1.	Htslib
2.	Samtools
3.	Bedtools
4.	Vcflib
5.	Minimap2

These codebases have serval system library dependencies. There is a shell script that installs the dependencies (for Amazon EC2 instance). If you’re not using Amazon EC2 the setup script should help you figure out which libraries you need. 

### Polar Star installs specific commits of code so that the pipeline won’t be broken as command line tools change.

The pipeline is run by snakemake: http://snakemake.readthedocs.io/en/stable/ 

## Setup

edit the config.json file. 

```
{
	    "threads"     : "4",             #the number of threads available 
	    "opts"        : "-x map-pb -a",  #minimap2 options (advanced)
	    "name"        : "sample_name",   #output prefix
	    "lib"         : "la",            #a library name for the bam (most can ignore)
	    "low_depth"   : "2",             #low depth cutoff
	    "times_mean"  : "3",             #high depth cutoff = mean * (times_mean)
	    "fasta_name"  : "PGA1_jelly_arrow_pilon_pallidicuale.gapsplit.fasta", #full fasta name
	    "fastq_names" : "m54120_170710_225913.subreads.fasta,m54120_170711_085749.subreads.fasta,m54120_170711_190715.subreads.fasta" #comma separated list of long-reads to align
	}

```

## Running

```
 snakemake -p -s Snakefile
```
