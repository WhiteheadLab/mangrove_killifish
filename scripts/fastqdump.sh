#!/bin/bash -l
#SBATCH -J fastqdump
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/
#SBATCH -o /home/prvasque/slurm-log/fastqdump_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/fastqdump_stderr-%j.txt
#SBATCH -t 12:00:00
#SBATCH -c 2

module load sratoolkit

DIR=./prvasquez/mangrove_killifish/data/raw_data/

fastq-dump -I --split-files --gzip -o ./prvasquez/mangrove_killifish/data/fastq/ $DIR/SRR69$SLURM_ARRAY_TASK_ID.sra 


