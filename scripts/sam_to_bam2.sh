#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J sam_to_bam
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH --array=25941-26018%6


module load samtools

DIR=./mangrove_killifish/data

name=SRR69${SLURM_ARRAY_TASK_ID}
echo $name

srun samtools view -bS -u ${DIR}/alignment/SRR69${SLURM_ARRAY_TASK_ID}Aligned.out.sam | \
 samtools sort --output-fmt BAM -o ${DIR}/bam/SRR69${SLURM_ARRAY_TASK_ID}.bam
