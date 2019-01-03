#!/bin/bash -l
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/alignment/
#SBATCH --mem=16000
#SBATCH -o /home/prvasque/slurm-log/samtools/sambam-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/samtools/sambam-stderr-%j.txt
#SBATCH -J sam_to_bam
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH --array=25941-26018%6

#sam files to bam files
# Modified Aug 8, 2018

module load samtools

DIR=./prvasquez/mangrove_killifish/data

name=SRR69${SLURM_ARRAY_TASK_ID}
echo $name

srun samtools view -bS -u ${DIR}/alignment/SRR69${SLURM_ARRAY_TASK_ID}Aligned.out.sam | \
 samtools sort --output-fmt BAM -o ${DIR}/bam/SRR69${SLURM_ARRAY_TASK_ID}.bam
