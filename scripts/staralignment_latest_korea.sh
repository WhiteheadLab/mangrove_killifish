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

outdir=/home/prvasque/projects/mangrove_killifish_project/alignment
dir=/home/prvasque/projects/mangrove_killifish_project/trim/data

STAR --genomeDir /home/prvasque/projects/mangrove_killifish_project/raw_data/reference_genome/ \
	--runThreadN 24 --readFilesCommand zcat --sjdbInsertSave all \
	--readFilesIn ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_1.qc.fq.gz ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_2.qc.fq.gz \
	--outFileNamePrefix ${outdir}/SRR69${SLURM_ARRAY_TASK_ID}
