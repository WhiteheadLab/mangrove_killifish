#!/bin/bash -l
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/scripts/
#SBATCH --mem=16000
#SBATCH -o /home/prvasque/slurm-log/htseq/hts_count-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/htseq/hts_count-stderr-%j.txt
#SBATCH -J hts_count
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH -a 25941-26018%10

#Modified as of August 11, 2018

#module load pysam
#module load python
#module load HTSeq

module load bio

echo SRR${SLURM_ARRAY_TASK_ID}

DIR=/home/prvasque/projects/mangrove_killifish_project/alignment/sorted
REF_DIR=/home/prvasque/projects/mangrove_killifish_project/raw_data/reference_genome
OUT_DIR=/home/prvasque/projects/mangrove_killifish_project/alignment/counts

htseq-count --type=gene -i Dbxref -f bam -s no $DIR/SRR69${SLURM_ARRAY_TASK_ID}_sorted.bam \
	$REF_DIR/GCF_001649575.1_ASM164957v1_genomic.gff > \
	$OUT_DIR/SRR69${SLURM_ARRAY_TASK_ID}count.txt

echo finished
