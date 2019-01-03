#!/bin/bash -l
#SBATCH -c 6
#SBATCH --mem=16000
#SBATCH -J trimmomatic
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/
#SBATCH -o /home/prvasque/slurm-log/trimmomatic/trimmomatic_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/trimmomatic/trimmomatic_stderr-%j.txt
#SBATCH --time=12:00:00
#SBATCH -p med
#SBATCH -a 25941-26018

DIR=./prvasquez/mangrove_killifish/data/fastq/
outdir=./prvasquez/mangrove_killifish/data/trim/

adapter=./prvasquez/mangrove_killifish/NEBnextAdapt.fa

cd $DIR

java -jar /share/apps/Trimmomatic-0.36/trimmomatic.jar PE SRR69$SLURM_ARRAY_TASK_ID\_1.fastq.gz \
	SRR69$SLURM_ARRAY_TASK_ID\_2.fastq.gz $outdir/SRR69$SLURM_ARRAY_TASK_ID\_1.qc.fq.gz \
	$outdir/orphans/69$SLURM_ARRAY_TASK_ID\_1_se $outdir/SRR69$SLURM_ARRAY_TASK_ID\_2.qc.fq.gz \
	$outdir/orphans/69$SLURM_ARRAY_TASK_ID\_2_se \
	ILLUMINACLIP:${adapter}:2:40:15 \
	LEADING:2 TRAILING:2 SLIDINGWINDOW:4:2 MINLEN:25
