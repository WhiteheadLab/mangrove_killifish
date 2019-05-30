#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=40000
#SBATCH -J staralignment_last_korea
#SBATCH -a 25941-26018
#SBATCH -t 6:00:00
#SBATCH -p med

module load perlnew/5.18.4
module load star/2.4.2a

outdir=./mangrove_killifish/data/alignment
dir=./mangrove_killifish/data/trim

genome_dir=./mangrove_killifish/data/ref

STAR --genomeDir ${genome_dir} \
	--runThreadN 24 --readFilesCommand zcat --sjdbInsertSave all \
	--readFilesIn ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_1.qc.fq.gz ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_2.qc.fq.gz \
	--outFileNamePrefix ${outdir}/SRR69${SLURM_ARRAY_TASK_ID}
