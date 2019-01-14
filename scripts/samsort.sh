#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J samsort
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH -a 25941-26018%8


DIR=./mangrove_killifish/data

echo SRR69${SLURM_ARRAY_TASK_ID}

samtools sort -n -o $DIR/sorted/SRR69${SLURM_ARRAY_TASK_ID}_sorted.bam \
	$DIR/bam/SRR69${SLURM_ARRAY_TASK_ID}.bam

echo 'done!'
