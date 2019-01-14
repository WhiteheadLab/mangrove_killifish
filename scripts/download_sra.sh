#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J download_sra
#SBATCH -t 12:00:00


module load sratoolkit

file="./mangrove_killifish/SRR_Acc_List.txt"
# IFS=$'\n' Do i need this?
DIR="./mangrove_killifish/data/raw_data/"

cd $DIR

for i in `cat $file`
do
	prefetch $i
done
