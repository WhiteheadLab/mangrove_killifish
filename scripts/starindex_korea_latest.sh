#!/bin/bash -l
#SBATCH --mem=40000
#SBATCH --cpus-per-task=24
#SBATCH -J starindex_korea_latest
#SBATCH -t 6:00:00

module load perlnew/5.18.4
module load star/2.4.2a

DIR=./mangrove_killifish/data/ref/

cd $DIR

STAR --runMode genomeGenerate --genomeDir $DIR --genomeFastaFiles GCF_001649575.1_ASM164957v1_genomic.fna \
	--sjdbGTFtagExonParentTranscript Parent --sjdbGTFfile GCF_001649575.1_ASM164957v1_genomic.gff \
	--sjdbOverhang 99

echo "genome indexed"
