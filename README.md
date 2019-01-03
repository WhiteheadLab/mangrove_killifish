# mangrove_killifish
## Work-in-progress!!!

This repository contains information on Yunwei Dong's mangrove killifish project and is currently a work in progress.


## 1. Cloning Github repository to local account
The first step is to clone the repository to your HPC.
*Note* Keep a note of the location of the path to where you downloaded the github clone as this will be important for insuring the paths of all the scripts are constant.
```
git clone https://github.com/prvasquez/mangrove_killifish
```

## 2. Downloading initial data
Downloading the data from NCBI requires the SRA Toolkit. If you're working from a shared cluster, the SRA toolkit may already be installed, if not, here is the [link](https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/).

```
prvasque@farm:~$ vdb-config -i
```

This command brings up the configuration menu. Navagate to the change option in the bottom left and change the directory to 
```
./prvasquez/mangrove_killifish/raw_data/
```

Next we can run the script to download the read data.
```
sbatch ./prvasquez/mangrove_killifish/scripts/download_sra.sh
```

## 3. Run fastqdump
The downloaded files are in the .sra data format. For the next step they need to be in the .fastq format to do that, run the fastqdump script.
```
sbatch ./prvasquez/mangrove_killifish/scripts/fastqdump.sh
```

## 4. Run Trimmomatic
Code to run trimmomatic
```
sbatch ./prvasquez/mangrove_killifish/scripts/trimmomatic.sh
```

## 5. Download reference genome from NCBI
The next step is to download the reference genome files from NCBI.
This step has three commands that should all be run together in order.
```
cd ./prvasquez/mangrove_killifish/data/ref/

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.gff.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.fna.gz

gunzip GCF*
```

## 6. Map reads to reference genome using STAR alignment
```
sbatch ./prvasquez/mangrove_killifish/scripts/starindex_korea_latest.sh
```
## 7. Align sequences with Korea Genome
```
sbatch ./prvasquez/mangrove_killifish/scripts/staralignment_latest_korea.sh
```
## 8. Samtools
```
sbatch ./prvasquez/mangrove_killifish/scripts/sam_to_bam2.sh
```
## 9. Samtools sort
```
sbatch ./prvasquez/mangrove_killifish/scripts/samsort.sh
```
## 10. HTSeq-count
```
sbatch ./prvasquez/mangrove_killifish/scripts/htseq_count.sh
```


