#!/bin/bash -l
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/alignment/bam/
#SBATCH --mem=16000
#SBATCH -o /home/prvasque/slurm-log/samtools/samsort-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/samtools/samsort-stderr-%j.txt
#SBATCH -J samsort
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH -a 25941-26018%8

#samtools sort

DIR=/home/prvasque/projects/mangrove_killifish_project/alignment

cd $DIR

echo SRR69${SLURM_ARRAY_TASK_ID}

samtools sort -n -o $DIR/sorted/SRR69${SLURM_ARRAY_TASK_ID}_sorted.bam \
	$DIR/bam/SRR69${SLURM_ARRAY_TASK_ID}.bam

echo 'done!'
