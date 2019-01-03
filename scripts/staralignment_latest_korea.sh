#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=40000
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/scripts/
#SBATCH -o /home/prvasque/slurm-log/staralignment/stargenoalign-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/staralignment/stargenoalign-stderr-%j.txt
#SBATCH -J staralignment_last_korea
#SBATCH -a 25943-26018
#SBATCH -t 6:00:00
#SBATCH -p med

module load perlnew/5.18.4
module load star/2.4.2a

outdir=./prvasquez/mangrove_killifish/data/alignment
dir=./prvasquez/mangrove_killifish/data/trim

genome_dir=./prvasquez/mangrove_killifish/ref/

STAR --genomeDir ${genome_dir} \
	--runThreadN 24 --readFilesCommand zcat --sjdbInsertSave all \
	--readFilesIn ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_1.qc.fq.gz ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_2.qc.fq.gz \
	--outFileNamePrefix ${outdir}/SRR69${SLURM_ARRAY_TASK_ID}
