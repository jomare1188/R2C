#!/bin/bash
#$ -N nf_RNAseq_quality
#$ -cwd
#$ -V
#$ -pe smp 1
#$ -q all.q

# Load required modules (adjust as needed for your cluster)

module load miniconda3
conda activate R2C

# Set up environment
export NXF_OPTS='-Xms1g -Xmx4g'

# Run the pipeline
nextflow run workflows/RNAseq_quality.nf -process.maxForks 6 -c config/nextflow.config \
    -resume
