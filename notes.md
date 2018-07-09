7/5/18
# Downloading raw data off ncbi
Following instructions on https://www.ncbi.nlm.nih.gov/books/NBK158899/#SRA_download.when_to_use_a_command_line
First to see if wget works for a single read

```
wget ftp://ftp-trace.ncbi.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/SRR692/SRR6926018/SRR6926018.sra
```

Worked as expected but downloaded file as a .sra which makes sense
Don't know what file type it should be downloaded as (maybe .gz?)

7/9/18

# Downlaoding raw data off ncbi
Turns out to get files that are ready for fastqc, the files must be in .fastq format. ~~To do this I have to use the sratools module to correctly download the files from ncbi as a .fastq format.~~
```
prvasque@farm:~$ module load sratoolkit
Module sratoolkit/2.8.2 loaded
```
Sratoolkit is good for using fastq-dump to convert from .sra to .fastq. However, it is better to first download all the .sra files from ncbi then on the cluster use SRAtools to convert to .fastq using fastq-dump.

### vdb-config
vdb-config is used to help direct the download of the sra files to the cluster
```
vdb-config -i
```
This command opens a GUI that i used to change my default import path. I changed it to /home/prvasque/projects/mangrove_killifish_project/raw_data

### Actually downloading fastq files
Because there are only ~80 reads, I will manually download all the reads using the accession numbers. (File can be found in github called SRR_Acc_List.txt which contains all the accession numbers) **Probably can come back and create a recursive funtion to do it all automatically using the list**
