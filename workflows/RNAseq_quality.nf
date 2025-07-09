#!/usr/bin/env nextflow
nextflow.enable.dsl=2

// include only needed modules
include { fastqc as raw_fastqc      } from "../modules/fastqc.nf"
include { multiqc as raw_multiqc    } from "../modules/multiqc.nf"
include { bbduk                     } from "../modules/bbduk.nf"
include { fastqc as trimmed_fastqc  } from "../modules/fastqc.nf"
include { multiqc as trimmed_multiqc} from "../modules/multiqc.nf"
include { salmonIndex               } from "../modules/salmonIndex.nf"
include { salmonQuant               } from "../modules/salmonQuant.nf"
include { salmonQuantMerge          } from "../modules/salmonQuantMerge.nf"

workflow {
    /*
     * Look for files like sample1_R1.fastq.gz and sample1_R2.fastq.gz,
     * grouped by 'sample1'
     * Adjust the path and pattern to your filenames if needed.
     */
    fastq_ch = Channel.fromFilePairs('/Storage/data1/jorge.munoz/DOLORES/RAWDATA/*_{R1,R2}_001.fastq.gz')

    // run fastqc on raw data
    raw_fastqc_ch = fastq_ch | raw_fastqc
    raw_fastqc.out.view{ "raw_fastqc: $it" }

    // group only fastqc directories and run multiqc 
    raw_multiqc_ch = raw_fastqc_ch.map{ sample, dir -> dir }.collect() | raw_multiqc
    raw_multiqc.out.view{ "raw_multiqc: $it" }

    // run bbduk
    ref_files = ["/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/adapters.fa",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/rfam-5.8s-database-id98.fasta",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/rfam-5s-database-id98.fasta",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/silva-arc-16s-id95.fasta",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/silva-arc-23s-id98.fasta",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/silva-bac-16s-id90.fasta",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/silva-bac-23s-id98.fasta",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/silva-euk-18s-id95.fasta",
				"/Storage/data1/jorge.munoz/DOLORES/nf/R2C/data/silva-euk-28s-id98.fasta"
		]

    trimmed_fastq_ch = fastq_ch.map{ sample_name, fastq_list -> [ sample_name, fastq_list, ref_files ] } | bbduk

    // trimmed_fastq_ch = fastq_ch.combine(ref_files) | bbduk   
    bbduk.out.view{ "bbduk: $it" }

    // run fastqc on trimmed data 
    trimmed_fastqc_ch = trimmed_fastq_ch | trimmed_fastqc
    trimmed_fastqc.out.view{ "trimmed_fastqc: $it" }

    // group only fastqc directories and run multiqc 
    trimmed_multiqc_ch = trimmed_fastqc_ch.map{ sample, dir -> dir }.collect() | trimmed_multiqc
    trimmed_multiqc.out.view{ "trimmed_multiqc: $it" }
    
    // run salmonIndex on reference genome 
    salmon_index_ch = salmonIndex(params.ref_genome)
    salmonIndex.out.view{ "salmonIndex: $it" }
    
    // run salmonQuant on reference genome 
    salmon_quant_ch = trimmed_fastq_ch.combine(salmon_index_ch) | salmonQuant
    salmonQuant.out.view{ "salmonQuant: $it" } 
    
    // combine all quantification files into a single expression matrix
    salmon_quantmerge_ch = salmon_quant_ch.map{ sample, quant -> file(quant.getParent()) }.collect() | salmonQuantMerge
    salmonQuantMerge.out.view{ "salmonQuantMerge: $it" }
}
