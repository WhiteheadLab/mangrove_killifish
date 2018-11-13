# Final Script
NOTE: Not completed

## Index
 0.1 - Introduction
 1.1 - Get Data
 1.1.1 - Downloading Read Data off NCBI
 1.1.2 - Downloading Reference Genome off NCBI
 1.2 - Fastqc
 1.3 - Trimmomatic
 1.4 - Map Reads to reference genome
 1.4.1 - Index Reference genome
 1.4.2 - Align sequence data to the Indexed Reference Genome
 1.5 - Converting to Bam file
 1.6 - Quantifying RNAseq data
 1.6.1 - HTSeq Count for expression quantification
 1.6.2 - Merge HTSeq count outputs to one file for data analysis
 
 
 
 
 ### 1.1 - Getting the Data
 
First step is to download the list of SRR Accension numbers. The text file used in this script can be found [here](https://github.com/prvasquez/mangrove_killifish/blob/master/SRR_Acc_List.txt).

Downloading the data from NCBI requires the SRA Toolkit. If you're working from a shared cluster, the SRA toolkit may already be installed, if not, here is the [link](https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/).

To direct the download of the data off of NCBI, we have to configure the SRA toolkit and change the download directory.
```
prvasque@farm:~$ vdb-config -i
```
This command brings up the configuration menu. Navagate to the change option and change the directory to where you want the data to be downloaded. More info can be found [here](https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?view=toolkit_doc&f=std).

To download all the data off of NCBI I used this script.
```
#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J download_sra
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/scripts
#SBATCH -o /home/prvasque/slurm-log/download_sra_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/download_sra_stderr-%j.txt

# Load the sratoolkit module
module load sratoolkit

# File that contains the SRA accension numbers for the data we want
file=/home/prvasque/projects/mangrove_killifish_project/raw_data/sra/SRR_Acc_List.txt

# Removes spaces between the accension numbers
IFS=$'\n'

# Directory where data will be downloaded (may not be needed because of above step)
DIR="/home/prvasque/projects/mangrove_killifish_project/raw_data/sra/"

cd $DIR

# Code that iterates through list and downloads the data as .sra files.
for i in `cat $file`
do
	prefetch $i
done
```

### 1.2 Fastqc

Files are downloaded as .sra, however, they need to be .fastq for the next step. To do this I used this script.

```
#!/bin/bash -l
#SBATCH -J fastqdump
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/
#SBATCH -o /home/prvasque/slurm-log/fastqdump_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/fastqdump_stderr-%j.txt
#SBATCH -t 12:00:00
#SBATCH -c 2
#SBATCH --array=25941-26018

# Loads the sratoolkit
module load sratoolkit

# Because this process involves a lot of reading and writing on the computers part, I created a sratch directory in a node so less I/O has to happen
DIR=/scratch/prvasque/$SLURM_JOBID
mkdir -p $DIR

# Copies each .sra file to the scratch directory
cp /home/prvasque/projects/mangrove_killifish_project/raw_data/sra/SRR69$SLURM_ARRAY_TASK_ID.sra $DIR

# Splits the files and gzipps them
fastq-dump -I --split-files --gzip $DIR/SRR69$SLURM_ARRAY_TASK_ID.sra 

cp $DIR/*.fastq.gz /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/

# rm -rf /scratch/prvasque/$SLURM_JOBID
```



 
 
 
 https://trace.ncbi.nlm.nih.gov/Traces/study/?acc=SRP136920
 
