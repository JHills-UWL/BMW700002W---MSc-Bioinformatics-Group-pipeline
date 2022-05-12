#!/usr/bin/env nextflow

/* A WGS pipeline using nextflow.

    The input to the pipeline is a path to a directory (input_dir) that contains .fq read pairs.
    The read pairs are formatted: NAME_1.fq,  NAME_2.fq

    The output of the pipeline is stored in the output directory (output_dir) defined below

    The structure of the pipeline's workflow:
(input) fastq read pair --> fastq_to_fasta --> annotate --> output txt file
                               \--> qc_fastq --> output html report
*/


/* User Config
    The lines of codes that can be edited to setup a nextflow run
    These lines specify where the samples for analysed are located and where the output is saved to
*/

input_dir = "$PWD/samples/"  		// Directory that contains samples
output_dir = "$PWD/output/"  		// Output samples
threads = 4                  			// Use to setup certain jobs

/* Setup
    Preparation before starting the pipeline
*/

// Pairs read files together, to allow passing through the pipeline together in pairs
read_pairs = Channel.fromFilePairs("$input_dir/*_{1,2}.fastq", flat: true)


/* Process Definitions */

// Quality control. Produces two fastqc files from two fastq files, representing the read pair
process qc {
    publishDir "$output_dir/$name/"
    tag "$name"

    input:
        tuple val(name), path(read_1), path(read_2)

    output:
        path('*')

    script:
    """
        mkdir fastqc/
        mkdir multiqc/

        # Execute FastQC
        fastqc --outdir fastqc/ --threads ${threads} $read_1 $read_2

        # Execute MultiQC
        multiqc fastqc/ --outdir multiqc/
    """
}

// Clean Reads                                                         /*using Fastp program*/
process clean {
    publishDir "$output_dir/$name/"
    tag "$name"

    input:
        tuple val(name), path(read_1), path(read_2)

    output:
        tuple val(name), path("preprocessed_1.fastq.gz"), path("preprocessed_2.fastq.gz")

    script:
    """
        # Execute fastp
        fastp -i $read_1 \
            -I $read_2 -o preprocessed_1.fastq.gz \
            -O preprocessed_2.fastq.gz \
            -j fastp.json \
            -h fastp.html \
            -q 30 \                              /* Specified by user to define base call accuracy ~ 99.9% accuracy */
            --trim_poly_g \              /* Adapter sequence removal for Illumina technologies*/
            --length_required 80 \ /*Minimum length of read 80bp */
            --thread ${threads}      /* Number of threads utilised by CPU */
    """
}

// Assemble                                                          /*using Unicycler program*/
process assemble {
    publishDir "$output_dir/$name/"
    tag "$name"

    input:
        tuple val(name), path(read_1), path(read_2) /* The reads input are the output from the clean read process */

    output:
        tuple val(name), path("assembly.fasta")

    script:
    """
        # Execute Unicycler
        unicycler -1 ${read_1} -2 ${read_2} -o ./ --threads ${threads}
    """
}

// Annotate                                                /*using Prokka program*/
process annotate {
    publishDir "$output_dir/$name/prokka/"
    tag "$name"

    input:
        tuple val(name), path('genome.fasta')

    output:
        path('*')

    script:
    """
        # Execute Prokka
        mkdir results/
        prokka --force genome.fasta
    """
}

/* Workflow

Defines how all the steps of the pipeline connect.

Structure of pipeline's workflow is:
    read pairs channel --> qc_fastq --> fastq_to_fasta --> annotate
*/
workflow {
    qc(read_pairs)
    clean(read_pairs)
    assemble(clean.out)
    annotate(assemble.out)
}

