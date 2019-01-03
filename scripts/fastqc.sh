#!/bin/bash -l
#SBATCH -J fastqc
#SBATCH -o /home/prvasque/slurm-log/fastqc-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/fastqc-stderr-%j.txt
#SBATCH --mem=6000
#SBATCH -c 2
#SBATCH -t 6:00:00

module load fastqc

DIR=/home/prvasque/projects/mangrove_killifish_project/raw_data

fastqc -o $DIR/fastqc/ $DIR/fastq/SRR69$SLURM_ARRAY_TASK_ID*.fastq.gz
