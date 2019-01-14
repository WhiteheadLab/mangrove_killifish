#!/bin/bash -l
#SBATCH -J fastqc
#SBATCH --mem=6000
#SBATCH -c 2
#SBATCH -t 6:00:00
#SBATCH --array=25941-26018

module load fastqc

DIR=./mangrove_killifish/data/

fastqc -o $DIR/fastqc/ $DIR/fastq/SRR69${SLURM_ARRAY_TASK_ID}.fastq.gz
