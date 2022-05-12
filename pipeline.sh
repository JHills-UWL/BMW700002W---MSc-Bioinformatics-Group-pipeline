#!/bin/bash


### Boilerplate


# Error handling
# This command ensures that pipeline will exit if any errors are encountered
set -eo pipefail


### User Config


# Set global parameters (edit these parameters)
threads=4
baseDir=$PWD
read1=SRR11947553_sub_1.fq.gz
read2=SRR11947553_sub_2.fq.gz


### Setup


# Create new directory to store all results
mkdir $baseDir/bash_results
resultsDir=$baseDir/bash_results


# Create new directories for each task
mkdir $resultsDir/1.fastqc_results
mkdir $resultsDir/2.clean_reads
mkdir $resultsDir/3.genome_assembly
mkdir $resultsDir/4.annotate_genome


# Define paths to directories
fastqcDir=$resultsDir/1.fastqc_results
cleanDir=$resultsDir/2.clean_reads
assemblyDir=$resultsDir/3.genome_assembly
annotateDir=$resultsDir/4.annotate_genome


### Run Pipeline


# To run this script, navigate to the baseDir and type this command:
# bash pipeline-script.sh
# Note: The name of file is pipeline-script.sh




# -------------------
# 1. Run FastQC and MultiQC
#--------------------


# Execute FastQC
fastqc --outdir $fastqcDir --threads ${threads} $baseDir/${read1} $baseDir/${read2} 


# Execute MultiQC
multiqc $fastqcDir --outdir $fastqcDir




# -------------------
# 2. Clean reads using fastp
#--------------------


# Execute fastp
fastp -i $baseDir/${read1} -I $baseDir/${read2} -o $cleanDir/${read1} -O $cleanDir/${read2} -j $cleanDir/fastp.json -h $cleanDir/fastp.html -q 30 --trim_poly_g --length_required 80 --thread ${threads}




# -------------------
# 3. Assemble clean reads using Unicycler
#--------------------


# Execute Unicycler
unicycler -1 $cleanDir/${read1} -2 $cleanDir/${read2} -o $assemblyDir --threads ${threads}




# -------------------
# 4. Annotate assembly using Prokka
#--------------------


# Execute Prokka
# conda activate prokka
prokka --outdir $annotateDir --force --prefix ${read1%_sub*} $assemblyDir/assembly.fasta
