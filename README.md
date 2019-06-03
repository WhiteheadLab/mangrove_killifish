This repository contains the scripts to reproduce the data from a collaborative research project between the Whitehead lab (UC Davis) and the lab of Dr. Patricia Wright (University of Guelph). Professor Yunwei Dong was a visiting scientist from China in the Whitehead lab during 2016-2017, and he collected and analyzed the transcriptomics data described here. Mangrove Killifish is a unique species that is able to leave its aquatic enviornment for damp environments such as mud or the inside of rotting logs. The primary goal of this study is to discover the physiological and genomic mechanisms that support the terrestrial acclimation abilities of Mangrove Killifish (_Kryptolebias Marmoratus_).

Experimental Design: For this experiment, fish were obtained from populations maintained at the Hagen Aqualab, at the University of Guelph. Two strains of fish, HON11 (n=38, from Honduras)) and FW (n=40, from Belize), were maintained in the laboratory in the salinity of their native habitat. Before exposure to air, tissues from fish were sampled as an immersion control at 0 hours. Upon emersion (exposure to air), fish were maintained on moist filter paper in a plastic rearing container and tissues were sampled at 1 hour, 6 hours, 24 hours, 72 hours, and 168 hours post-emersion, for both populations. Each treatment group contained five biological replicates (individual fish), except for HON11 72 hours and HON11 0 hours which had four replicates. A csv with the design matrix is available in the files folder.

RNA was extracted using RNAeasy purification kits and individually-indexed RNA-seq libraries were prepared using the NEBnext RNA library preparation kits for Illumina. All indexed samples were pooled and sequence data were collected across four lanes of Illumina 4000 (PE-150).

Sequence reads were mapped to the K. marmoratus gene set reported in (Rhee et al. 2017) (Whole Genome Shotgun project GenBank accession LWHD00000000, GenBank assembly accession: GCA_001649575.1) using STAR (Dobin et al. 2013), and read counts generated using HTseq (Anders et al. 2015). We retained genes that had greater than 10 read counts for at least four of five biological replicates within any treatment group. Read counts were log2 transformed and normalized for gene length and total library size in EdgeR (Robinson et al. 2010). Differential expression analysis was performed in Limma (Ritchie et al. 2015), where strain (HON, FW)) and time (0hr, 1hr, 6hrs, 24hrs, 72hrs, 168hrs) were specified as main effects, and strain-by-time as an interaction term. We considered genes showing significant main effects or interaction if false discovery rate corrected p-values were <0.01.

This repository contains scripts for the analysis outlined in the previous paragraph. After running the scripts presented in this repo, you will be left with csv files that include geneIDs and a corresponding p-value for the main effects of time, strain, and time-by-strain interaction.



## 1. Cloning Github repository to local account
The first step is to clone the repository to your HPC.
*Note* Keep a note of the location of the path to where you downloaded the github clone as this will be important for insuring the paths of all the scripts are constant.
```
git clone https://github.com/WhiteheadLab/mangrove_killifish
```
It is **VERY** important to remember to return to the directory where you cloned this github repository to before you run each step (except for Step #5 where you download the reference genome).

For example, if you were in the directory /home/prvasque/ when you ran the `git clone` step, you should see the `mangrove_killifish` repository. **Do not** `cd` into this directory to run the scripts. If you do, the paths inside the script will be incorrect and the scripts will not run. 



## 2. Downloading initial data
Downloading the data from NCBI requires the SRA Toolkit. If you're working from a shared cluster, the SRA toolkit may already be installed, if not, here is the [link](https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/).

We need to make the directory that the ncbi data will be downloaded to
```
mkdir ./mangrove_killifish/data/raw_data/
```
Now to change the download directory
```
prvasque@farm:~$ vdb-config -i
```

This command brings up the configuration menu. Navagate to the change option in the bottom right and change the directory to 
```
./mangrove_killifish/data/raw_data/
```

Next we can run the script to download the read data.
```
sbatch ./mangrove_killifish/scripts/download_sra.sh
```

## 3. Run fastqdump
The downloaded files are in the .sra data format. For the next step they need to be in the .fastq format to do that, run the fastqdump script.
```
sbatch ./mangrove_killifish/scripts/fastqdump.sh
```

## 4. Run Trimmomatic
Code to run trimmomatic
```
sbatch ./mangrove_killifish/scripts/trimmomatic.sh
```

## 5. Download reference genome from NCBI
The next step is to download the reference genome files from NCBI.
This step has three commands that should all be run together in order.
```
cd ./mangrove_killifish/data/ref/

wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.gff.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.fna.gz

gunzip GCF*
```

## 6. Index the reference Genome with STAR Index
```
sbatch ./mangrove_killifish/scripts/starindex_korea_latest.sh
```
## 7. Align sequences to the Reference Genome with STAR Alignment
```
sbatch ./mangrove_killifish/scripts/staralignment_latest_korea.sh
```
## 8. Samtools

Originally, the each sample was split into 4 different lanes for sequencing. They were then combined using the `samtools merge` command. This involved converting the data to a .bam file type and adding read groups. The dataset you downloaded from NCBI earlier in this pipeline consists of all the data so merging is not required.

The next step involve changing the `Aligned.sam` output files from STAR alignment into a `.bam` output then sorting them. However, because we do not need to merge the data this step is actually redundant and you could skip it by including the flag `--outSAMtype BAM SortedByCoordinate` in the STAR alignment step. The files would then be ready for quantification using HTSeq.

**However**, to keep with the original script, we will run samtools independantly of STAR Alignment.

The `sam_to_bam2.sh` script will convert the `Aligned.sam` files from STAR alignment to a sorted `.bam` output

```
sbatch ./mangrove_killifish/scripts/sam_to_bam2.sh
```

## 9. HTSeq-count
```
sbatch ./mangrove_killifish/scripts/htseq_count.sh
```
## 10. File formatting for Rstudio
In the folder of the outputs from the previous step run this code. This will prepare the two files to be downloaded to a local computer to use the Rscript on.
```
cd ./mangrove_killifish/data/counts


paste *.txt  | tail -n +2 |awk '{OFS="\t";for(i=2;i<=NF;i=i+2){printf "%s ", $i}{printf "%s", RS}}' >test.out.txt
cat SRR6925941count.txt | cut -f 1| tail -n +2| paste - test.out.txt | tr ' ' \\t > test2.out.txt 
touch test.names.txt
ls SRR* | sed 's/count\.txt//g' | tr '\n' \\t > test.names.txt
```
## 11. Rscript
For the Rstudio part of this analysis, there are four files that need to be downloaded. The path to these files is listed below
```
./mangrove_killifish/data/counts/test2.out.txt
./mangrove_killifish/data/counts/test.names.txt
./mangrove_killifish/scripts/final_r_script.R
./mangrove_killifish/files/design.matrixSRR08282018.csv
```
To download these files you can use the `scp` command to move the files from a cluster to your personal machine.
A sample is provided below on how to use scp.
```
scp prvasque@farm.cse.ucdavis.edu:/home/prvasque/projects/test_fish/mangrove_killifish/data/counts/test2.out.txt ~/Desktop/
scp [location of file on cluster] [location you want to download the file to on your personal machine]
```

NOTE: For the Rscript, make sure to change the paths of the files in the script to the path to the files on your local computer.

