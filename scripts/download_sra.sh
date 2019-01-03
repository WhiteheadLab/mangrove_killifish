#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J download_sra
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/scripts
#SBATCH -o /home/prvasque/slurm-log/download_sra_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/download_sra_stderr-%j.txt

module load sratoolkit

file=/home/prvasque/projects/mangrove_killifish_project/raw_data/sra/SRR_Acc_List.txt
IFS=$'\n'
DIR="/home/prvasque/projects/mangrove_killifish_project/raw_data/sra/"

cd $DIR

for i in `cat $file`
do
	prefetch $i
done
