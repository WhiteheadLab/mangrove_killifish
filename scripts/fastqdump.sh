#!/bin/bash -l
#SBATCH -J fastqdump
#SBATCH -t 12:00:00
#SBATCH -c 2
#SBATCH --array=25941-26018

module load sratoolkit

DIR=./mangrove_killifish/data/raw_data/

fastq-dump -I --split-files --gzip -o ./prvasquez/mangrove_killifish/data/fastq/SRR69${SLURM_ARRAY_TASK_ID}.fastq.gz $DIR/SRR69${SLURM_ARRAY_TASK_ID}.sra 
