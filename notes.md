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
Two options:
1. Download .sra files using prefetch (an sratool) then convert to .fastq using fastq-dump
2. Download .fastq files directly from ncbi using fastq-dump

```
prvasque@c11-42:~$ module load sratoolkit
Module sratoolkit/2.8.2 loaded 
prvasque@c11-42:~$ cd projects/mangrove_killifish_project/raw_data/
prvasque@c11-42:~/projects/mangrove_killifish_project/raw_data$ fastq-dump --split-files SRR6926018
```
Fastq-dump command is taking a while. Will probably have to create an iteration. Will probably download all the .sra files then convert on cluster.
I canceled the command early using ^C and looked at the files that appeared. SRR6926018_1.fastq has over 10,000 lines each with a length of 150. I don't know if this is the fully downloaded version or not because it continues to scroll forever.

~~# Download guide~~
~~https://wiki.ncsa.illinois.edu/download/attachments/44958475/SRA_Download_BW.%20Final.Aug18_2017.pdf?version=1&modificationDate=1505510727000&api=v2~~

~~This document is a step-by-step guide for downloading very large datasets and I will try to follow it.~~
~~### 1. vdb-config~~
```
vdb-config -i
```
~~Changed the project space location to /home/prvasque/projects/mangrove_killifish_project/raw_data~~

~~### 2. Refseq download~~
~~Created a textfile of all the names of all the different refseq files called list_all_refseqs.txt (There are around 9600)~~
~~Sent that file to my farm cluster.~~
```
scp -P 2022 list_all_refseqs.txt prvasque@farm.cse.ucdavis.edu:/home/prvasque/projects/
```
~~Then I moved the file to the mangrove_killifish folder~~
```
mv list_all_refseqs.txt ~/projects/mangrove_killifish_project/refseq_download
```
~~There are two different scripts for the next part.~~
~~One that is shell /reseq_download/download_parallel_wrapper.sh~~
~~One that is python /refseq_download/download_reseqs_parallel.py~~

~~download_parallel_wrapper.sh~~

~~This script runs the python script multiple times so that the whole process goes by faster (probably more useful for bigger data sets, don't know if necessary)~~

~~download_refseqs_parallel.py~~

 
 Just kidding I do not have aspera on my farm cluster account. rip
 
 Will manually use prefetch on all the files.
 
 ```
 prvasque@farm:~/projects/mangrove_killifish_project/raw_data/sra$ prefetch SRR6925941

2018-07-09T22:49:44 prefetch.2.8.2: 1) Downloading 'SRR6925941'...
2018-07-09T22:49:44 prefetch.2.8.2:  Downloading via https...
2018-07-09T22:51:25 prefetch.2.8.2: 1) 'SRR6925941' was downloaded successfully
2018-07-09T22:51:25 prefetch.2.8.2: 'SRR6925941' has 0 unresolved dependencies
prvasque@farm:~/projects/mangrove_killifish_project/raw_data/sra$ ls
SRR6925941.sra
```
Prefetch works to get the .sra file. Tomorrow I will create a script that uses prefetch to download ALL the .sra files that I need.

baby steps
 











