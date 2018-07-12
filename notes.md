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
 

7/11/18

# Bash script to download all the .sra files

First move the SRR_Acc_List.txt to my farm account
```
scp -P 2022 SRR_Acc_List.txt prvasque@farm.cse.ucdavis.edu:/home/prvasque/projects/mangrove_killifish_project/raw_data/sra
```
I need to take every line in the SRR_acc_list and make a prefetch command.
1. open SRR_acc
2. split into lines?
3. Take each line and run prefetch on the line
4. Output to ~/projects/mangrove_killifish_project/raw_data/sra


```
Download_sra.sh
```
```
#!/bin/bash -l
     # Why -l?
#SBATCH --mem=16000
#SBATCH -J download_sra
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/scripts
#SBATCH -o /home/prvasque/projects/mangrove_killifish_project/raw_data/sra
#SBATCH -e /home/prvasque/projects/mangrove_killifish_project/raw_data/sra/error

# Load sratoolkit so prefetch works
module load sratoolkit

# File that has all the SRA numbers for the files I wish to download
file=/home/prvasque/projects/mangrove_killifish_project/raw_data/sra/SRR_Acc_List.txt

# Makes sure there is no accidental space entered
IFS=$'\n'

# working directory
DIR="/home/prvasque/projects/mangrove_killifish_project/raw_data/sra/"

cd $DIR

#Logic for downloading files
for i in `cat $file`
do
 prefetch $i
done
```
First script, will it work?
No.

```
prvasque@farm:~/projects/mangrove_killifish_project/scripts$ srun -p med -t 6:00:00 download_sra.sh
srun: job 23513890 queued and waiting for resources
srun: job 23513890 has been allocated resources
slurmstepd: error: execve(): download_sra.sh: Permission denied
srun: error: c8-63: task 0: Exited with exit code 13
```
Seems like a permission error. Is it a permission with the script or with running a scirpt?
Emailed the help people to try to get a response.

Permission error with script
```
chmod +x ./download_sra.sh
```
Fixed it.

Now it seems the files are unable to download
```
prvasque@farm:~/projects/mangrove_killifish_project/scripts$ srun -p med -t 6:00:00 download_sra.sh
srun: job 23513893 queued and waiting for resources
srun: job 23513893 has been allocated resources
Module slurm/17.11.5 loaded 
Module openmpi/3.0.1 loaded 
Module gcc/7.3.0 loaded 
Module sratoolkit/2.8.2 loaded 

2018-07-11T22:57:03 prefetch.2.8.2: 1) Downloading 'SRR6926018'...
2018-07-11T22:57:03 prefetch.2.8.2:  Downloading via https...
2018-07-11T23:07:50 prefetch.2.8.2 sys: error unknown while reading file within network system module - mbedtls_ssl_read returned -76 ( NET - Reading information from the socket failed )
2018-07-11T23:07:50 prefetch.2.8.2 int: error unknown while reading file within network system module - ?Ar: Cannot KStreamRea
2018-07-11T23:07:50 prefetch.2.8.2: 1) failed to download SRR6926018
```
Maybe a problem with connection? 
Some SRA downloads are working and some are not. Will post list and update as it goes to make sure I get all the files correctly downloaded. Only first 3 failed?? But first three are the same as all the other files on ncbi? Maybe dependances were missing origionally so they failed and now they're all downloaded so the rest are working? Seems like a manual download of the first three will fix things

SRR6926018 -failed
```
sys: error unknown while reading file within network system module - mbedtls_ssl_read returned -76 ( NET - Reading information from the socket failed )
2018-07-11T23:07:50 prefetch.2.8.2 int: error unknown while reading file within network system module - ?Ar: Cannot KStreamRea
```
SRR6926017 -failed
```
sys: error unknown while reading file within network system module - mbedtls_ssl_read returned -76 ( NET - Reading information from the socket failed )
2018-07-11T23:17:09 prefetch.2.8.2 int: error unknown while reading file within network system module - ?
```
SRR6926016 -failed
```
int: incomplete while <INVALID-CONTEXT> within network system module - ?AH: Cannot KStreamRea
```
SRR6926015 -worked
SRR6926014 -worked
SRR6926013 -worked
SRR6926012 -worked
SRR6926011 -worked
SRR6926010 -worked
SRR6926009 -worked
SRR6926008 -worked
SRR6926007 -worked
SRR6926006 -worked
SRR6926005 -worked
SRR6926004 -worked
SRR6926002 -worked
SRR6926003 -worked
SRR6926001 -worked
SRR6926000 -worked
SRR6925999 -worked
SRR6925998 -worked
SRR6925996 -worked

SRR6925997 -failed
SRR6925995 -failed
SRR6925994 -failed
SRR6925993 -failed
Error code was same for the above 4
```
sys: error unexpected while resolving tree within virtual file system module - failed to resolve accession 'SRR6925997' - Cannot get server name from load balancer 'SRA_READ' : errmsg='Service name not found in LB' ( 500 )
2018-07-11T23:43:45 prefetch.2.8.2 err: path not found while resolving tree within virtual file system module - 'SRR6925997' cannot be found.
```
SRR6925992 -worked
SRR6925991 -worked
SRR6925990 -worked
SRR6925989 -worked
SRR6925988 -worked
SRR6925987 -worked
SRR6925986 -worked
SRR6925985 -worked
SRR6925983 -worked
SRR6925984 -worked
SRR6925982 -worked
SRR6925981 -worked
SRR6925980 -worked
SRR6925979 -worked
SRR6925978 -worked
SRR6925977 -worked
SRR6925976 -worked
SRR6925975 -worked
SRR6925973 -worked
SRR6925974 -worked
SRR6925972 -worked
SRR6925971 -worked
SRR6925970 -worked
SRR6925968 -worked
SRR6925969 -worked
SRR6925967 -worked
SRR6925966 -worked
SRR6925965 -worked
SRR6925963 -worked
SRR6925964 -worked
SRR6925962 -worked
SRR6925959 -worked
SRR6925961 -worked
SRR6925957 -worked
SRR6925960 -worked
SRR6925956 -worked
SRR6925958 -worked
SRR6925955 -worked
SRR6925953 -worked
SRR6925950 -worked
SRR6925954 -worked
SRR6925952 -worked
SRR6925951 -worked
SRR6925949 -worked
SRR6925945 -worked
SRR6925948 -worked
SRR6925944 -worked
SRR6925947 -worked
SRR6925946 -worked
SRR6925943 -worked
SRR6925942 -worked
SRR6925941 -worked

Most of them worked and are in /home/prvasque/projects/mangrove_killifish_project/raw_data/sra as .sra files.
The ones that did not work do not have a file. Will manually prefetch all of those.
First `srun -p high -t 24:00:00 --mem=20000 --pty bash`
Next `prefetch` all the ones that failed during the script
SRR6926018 - worked
SRR6926017 - worked
SRR6926016 - worked
SRR6925997 - worked
SRR6925995 - worked
SRR6925994 - worked
SRR6925993 - worked

YAY!! All the data is now downloaded from ncbi to my farm account. Next step is to use fastq-dump to make all the .sra files into .fastq files so i can run fastqc on them.





