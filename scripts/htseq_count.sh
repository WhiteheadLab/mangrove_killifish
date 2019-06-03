#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J hts_count
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH -a 25941-26018%10


module load bio

echo SRR${SLURM_ARRAY_TASK_ID}

DIR=./mangrove_killifish/data/bam

REF_DIR=./mangrove_killifish/data/ref

OUT_DIR=./mangrove_killifish/data/counts

htseq-count --type=gene -i Dbxref -f bam -s no $DIR/SRR69${SLURM_ARRAY_TASK_ID}.bam \
	$REF_DIR/GCF_001649575.1_ASM164957v1_genomic.gff > \
	$OUT_DIR/SRR69${SLURM_ARRAY_TASK_ID}count.txt

echo finished
