#!/bin/bash -l
#SBATCH -c 6
#SBATCH --mem=16000
#SBATCH -J trimmomatic
#SBATCH --time=12:00:00
#SBATCH -p med
#SBATCH -a 25941-26018

DIR=./mangrove_killifish/data/fastq/
outdir=./mangrove_killifish/data/trim

adapter=./mangrove_killifish/files/NEBnextAdapt.fa

cd $DIR

java -jar /share/apps/Trimmomatic-0.36/trimmomatic.jar PE SRR69$SLURM_ARRAY_TASK_ID\_1.fastq.gz \
	SRR69$SLURM_ARRAY_TASK_ID\_2.fastq.gz $outdir/SRR69$SLURM_ARRAY_TASK_ID\_1.qc.fq.gz \
	$outdir/orphans/69$SLURM_ARRAY_TASK_ID\_1_se $outdir/SRR69$SLURM_ARRAY_TASK_ID\_2.qc.fq.gz \
	$outdir/orphans/69$SLURM_ARRAY_TASK_ID\_2_se \
	ILLUMINACLIP:${adapter}:2:40:15 \
	LEADING:2 TRAILING:2 SLIDINGWINDOW:4:2 MINLEN:25
