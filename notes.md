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


7/13/18

# Script for running fastq-dump on all my .sra files

Fastq-dump is a command in sratoolkit that changes files into the .fastq format which is needed for fastqc analysis.
For this script:
1. Import sratoolkit module which contains fastq-dump command
2. Run fastq-dump on all my .sra files (for \*.sra in /home/prvasque/projects/mangrove_killifish_project/raw_data/sra/)
3. Output .fastq files to a directory (/home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/)

**Notes:**
The .sra files are currently paired and for fastqc analysis I need to unpair them. --split-files flag will split each read into a seperate file.
-I flag will add a .1 or .2 to end of file to signify read id. Don't know if necessary but it seems useful.
-O <path> will signify where I want the output to go. However, default is current working directory so it may be better to just `cd $DIR` beforehand
In Yunwei's fastqc script all his files end with .fastq.gz to gzip all the files I can also use the flag --gzip to automate the process in the script.
 
 

```
fastqdump.sh
```
```
#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J fastqdump
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/
#SBATCH -o /home/prvasque/slurm-log/fastqdump_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/fastqdump_stderr-%j.txt

module load sratoolkit

DIR="/home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/"

cd $DIR

for file in /home/prvasque/projects/mangrove_killifish_project/raw_data/sra/*.sra
do 
 fastq-dump -I --split-files --gzip $file
done
```
I assume this will work.
First, log into a node on farm cluster

**NEED TO CREATE A DIRECTORY FOR THE #SBATCH -e and -o**
(Didn't do this for the first script so I may have lost the logs, rip)


```
prvasque@farm:~/projects/mangrove_killifish_project/scripts$ sbatch -p high -t 6:00:00 fastqdump.sh
```
Job is running!
`23520363      high fastqdum prvasque  R        0:05      1 6   16000M c8-62`
And stuff is appearing in my /raw_data/fastq/
```
prvasque@farm:~/projects/mangrove_killifish_project/raw_data/fastq$ ls
SRR6925941_1.fastq.gz  SRR6925941_2.fastq.gz
```
So my script is running but these are still the only files in /fastq/ after 6 minutes. Hopefully fastq-dump just takes a while. BUT, the files that are there are in the correct format. Yay.
Soooo turns out using gzip takes a ton of time. Which is probably responsible for why it is taking so long.
In 45 minutes, only about 4Gb of the SRR*.fastq.gz has been written
Turns out that gziping does take a very long time.
Emailed the help support to see what is the maximum amount of memory I could use to do this in a faster way.
Turns out the best way to do this is to copy the files into /scratch/, on a node to do the `fastq-dump -I --gzip` there. Then copy the return files from that to my ~/fastq directory. All of this can be done with the script and using arrays.

```
fastqdump.sh
```
```
#!/bin/bash -l
#SBATCH -J fastqdump
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/
#SBATCH -o /home/prvasque/slurm-log/fastqdump_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/fastqdump_stderr-%j.txt
#SBATCH -t 12:00:00
#SBATCH -c 2

module load sratoolkit

DIR=/scratch/prvasque/$SLURM_JOBIDls
mkdir -p $DIR

cp /home/prvasque/projects/mangrove_killifish_project/raw_data/sra/SRR69$SLURM_ARRAY_TASK_ID.sra $DIR

fastq-dump -I --split-files --gzip $DIR/SRR69$SLURM_ARRAY_TASK_ID.sra 

cp $DIR/*.fastq.gz /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/

# rm -rf /scratch/prvasque/$SLURM_JOBID
```
I will run this script with this command `sbatch --array=25941-26018 fastqdump.sh`

Shout out the help people for farm for this major help.
Analysis: For this script what it does is it makes a new job for EACH of the .sra files.
For each .sra file:
1. make a unique directory in a nodd for the .sra file
2. copy the .sra to the directory in step 1
3. preform the fastq-dump command as well as gzip it
4. copy the output .fastq.gz file to my ~/fastq/ directory
5. delete the unique directory in step 1

So now I SHOULD have all my .fastq.gz files in my ~/fastq/ directory

It didnt work, but its because my pathing was all messed up.

Now it works! Please disregard past messages.
All the .fastq.gz files are in the correct directory. Next step is to run fastqc analysis.


7/18/18

# Running Fastqc
My current fastqc version is v0.11.5

The basic fastqc command looks like
`fastqc (-o output directory) (name of sequence file)`

So I think this command should work
`fastqc -o ~/projects/mangrove_killifish_project/raw_data/fastqc/ ~/projects/mangrove_killifish_project/raw_data/fastq/*.fastq.gz`

Command worked but it will probably take a while so I will just write a script to run in background.
```
fastqc.sh
```
```
#!/bin/bash -l
#SBATCH -J fastqc
#SBATCH -o /home/prvasque/slurm-log/fastqc-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/fastqc-stderr-%j.txt
#SBATCH --mem=6000
#SBATCH -c 2
#SBATCH -t 6:00:00

module load fastqc

DIR=/home/prvasque/projects/mangrove_killifish_project/raw_data

fastqc -o $DIR/fastqc/ $DIR/fastq/SRR69$SLURM_ARRAY_TASK_ID*.fastq.gz
```
So I should be able to run this command with 
```
sbatch --array=25941-26018 fastqc.sh
```
Okay it's running, will return later to see results.
`Submitted batch job 23706861`

Yay it worked all my fastqc.zip and fastqc.html files are in 
`~/projects/mangrove_killifish_project/raw_data/fastqc`

Now to run trimmomatic to trim them down.

## Running Trimmomatic
So to run trimmomatic I need to take both pairs of a read (the \_1.fastq.gz and \_2.fastq.gz) as well as the location of the trimmomatic.jar file which is `/share/apps/Trimmomatic-0.36/trimmomatic.jar`

My command will look like this
Assuming I am in the directory of all the untrimmed files
```
java -jar /share/apps/Trimmomatic-0.36/trimmomatic.jar PE (*_1.fastq.gz) (*_2.fastq.gz) \
(Out directory/*_1.qc.fq.gz) (Out directory/s1_se) (Out directory/*_2.qc.fq.gz) \ 
(Out directory/s2_se) ILLUMINACLIP:(What ever the adaptors is):2:40:15 LEADING:2 \ 
TRAILING:2 SLIDINGWINDOW:4:2 MINLEN:25
```
This will leave me with 4 different file types in my out directory, my two trimmed files for every pair as well as orphans.
So I need to move the s1_se and s2_se files to their out directory because they are orphans then delete the files
```
gzip -9c (out directory/s1_se) (out directory/s2_se) >> (out directory/orphans.fq.gz
rm -f (out directory/s1_se) (out directory/s2_se)
```


Copied the adaptor over to my cluster
```
prvasque@farm:/home/ywdong/bin/Trimmomatic-0.36/adapters$ cp NEBnextAdapt.fa /home/prvasque/projects/mangrove_killifish_project/trim/adapters/
```

Okay so I should be able to run one of the samples with no errors with this command
```
java -jar /share/apps/Trimmomatic-0.36/trimmomatic.jar PE SRR6925941_1.fastq.gz SRR6925941_2.fastq.gz /home/prvasque/projects/mangrove_killifish_project/trim/data/SRR6925941_1.qc.fq.gz /home/prvasque/projects/mangrove_killifish_project/trim/data/s1_se /home/prvasque/projects/mangrove_killifish_project/trim/data/SRR6925941_2.qc.fq.gz /home/prvasque/projects/mangrove_killifish_project/trim/data/s2_se ILLUMINACLIP:/home/prvasque/projects/mangrove_killifish_project/trim/adaptors/NEBnextAdapt.fa:2:40:15 LEADING:2 TRAILING:2 SLIDINGWINDOW:4:2 MINLEN:25
```
Got an error right off the bat 
```
java.io.FileNotFoundException: /home/prvasque/projects/mangrove_killifish_project/trim/adaptors/NEBnextAdapt.fa (No such file or directory)
```
Okay I misspelled adapters oops. Rerunning with adapters correctly spelled.

Seems like it will work, Ill write up a script now to have it run overnight.

#### Moved script below

Some weird things I notice before I run the script. 1: gzip -9c command is not apart of the java command to run trimmomatic on my script. 2: the gzip is going to write the s1_se and s2_se of every file to the orphans.fq.gz (I think). Some weird stuff may happen with the orphans.fq.gz file will have to check after it is done.
```
sbatch -p high -t 24:00:00 trimmmomatic.sh
```

Will return tomorrow to see results! fingers crossed it works.


7/19/18

# Trimmomatic

Trimmomatic was still running when I returned. Each file was taking ~1 hour to complete. So I canceled the job and will rewrite the script so it uses an array so they will all run at once and make the process quicker.

Some good info from Elias: Because trimmomatic is already loaded on farm cluster, I don't need to say `module load trimmomatic`
Also after the $SLURM_ARRAY stuff use a backslash (\\) so the \_1 and \_2 are not apart of the $SLURM_ARRAY
NOTE: removed the --array flag from script because I was getting an error message. JUST KIDDING slurm doesnt support arrays over a certain size so I can just reduce the size of my array from 6925941-6926018
```
trimmomatic.sh
```
```
#!/bin/bash -l
#SBATCH -c 6
#SBATCH --mem=16000
#SBATCH -J trimmomatic
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/
#SBATCH -o /home/prvasque/slurm-log/trimmomatic_stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/trimmomatic_stderr-%j.txt
#SBATCH --array=25941-26018
#SBATCH --time=12:00:00
#SBATCH -p med

DIR=/home/prvasque/projects/mangrove_killifish_project/raw_data/fastq/
outdir=/home/prvasque/projects/mangrove_killifish_project/trim/data/

cd $DIR

java -jar /share/apps/Trimmomatic-0.36/trimmomatic.jar PE SRR69$SLURM_ARRAY_TASK_ID\_1.fastq.gz \
        SRR69$SLURM_ARRAY_TASK_ID\_2.fastq.gz $outdir/SRR69$SLURM_ARRAY_TASK_ID\_1.qc.fq.gz \
        $outdir/orphans/69$SLURM_ARRAY_TASK_ID\_1_se $outdir/SRR69$SLURM_ARRAY_TASK_ID\_2.qc.fq.gz \
        $outdir/orphans/69$SLURM_ARRAY_TASK_ID\_2_se \
        ILLUMINACLIP:/home/prvasque/projects/mangrove_killifish_project/trim/adapters/NEBnextAdapt.fa:2:40:15 \
        LEADING:2 TRAILING:2 SLIDINGWINDOW:4:2 MINLEN:25
```
To test that this works I will run
```
sbatch trimmomatic.sh
```
All jobs were submitted!

7/23/18

All my trimmomatic jobs completed. Next step is to export the trim results to a table. I do not know what the purpose of this is except for looking at data afterwards. All the trimmomatic output files have the extension .qc.fq.gz is that the same as .qc.fastq.gz?

I think I will skip the export trim results step until I am in need of a result table. So the next step is to download the reference genome from NCBI

# Downloading reference genome from NCBI
Downloaded the gff and fna files from NCBI for Kryptolebias Marmoratus
```
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.gff.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.fna.gz
```
.fna file is a FastA format file containing Nucleotide sequence (DNA)
.gff file is a general feature format containing genomic regions, the "genes, transcripts, etc"
Got these two descriptions from a biostars forum.


# Mapping reads to reference genome using STAR
First step is to index the reference genome with the latest gff file.
We will use the program STAR. STAR maps large sets of high-throughput sequencing reads to a reference genome for RNA transcripts.
NOTE: REMEMBER TO GUNZIP THE FILES THAT WERE DOWNLOADED
While in directory of the files I downloaded I ran
```
gunzip *.gz
```
This unzipped the files to prepare them for STAR indexing


SCript for STAR indexing
```
starindex_korea_latest.sh
```
```
#!/bin/bash -l
#SBATCH --mem=40000
#SBATCH --cpus-per-task=24
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/scripts/
#SBATCH -o /home/prvasque/slurm-log/starindex/starindex-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/starindex/starindex-stderr-%j.txt
#SBATCH -J starindex_korea_latest
#SBATCH -t 6:00:00

module load perlnew/5.18.4
module load star/2.4.2a

DIR=/home/prvasque/projects/mangrove_killifish_project/raw_data/reference_genome/

cd $DIR

STAR --runMode genomeGenerate --genomeDIR $DIR --genomeFastaFiles GCF_001649575.1_ASM164957v1_genomic.fna \
--sjdbGTFtagExonParentTranscript Parent --sjdbGTFfile GCF_001649575.1_ASM164957v1_genomic.gff \
--sjdbOverhang 99

echo "genome indexed"
```
Ran on farm cluster with 
```
sbatch -p med starindex_korea_latest.sh
```


A lot of scripts are in the processes of running on the farm cluster so my script is low in the que. RIP.


7/24/18
Output of star indexing
```
Jul 23 16:48:38 ..... Started STAR run
Jul 23 16:48:38 ... Starting to generate Genome files
Jul 23 16:49:04 ... starting to sort  Suffix Array. This may take a long time...
Jul 23 16:49:11 ... sorting Suffix Array chunks and saving them to disk...
Jul 23 17:05:22 ... loading chunks from disk, packing SA...
Jul 23 17:06:15 ... Finished generating suffix array
Jul 23 17:06:15 ... starting to generate Suffix Array index...
Jul 23 17:09:56 ..... Processing annotations GTF
Jul 23 17:10:08 ..... Inserting junctions into the genome indices
Jul 23 17:17:12 ... writing Genome to disk ...
Jul 23 17:17:17 ... writing Suffix Array to disk ...
Jul 23 17:17:37 ... writing SAindex to disk
Jul 23 17:17:42 ..... Finished successfully
genome indexed
```
And no errors

# Aligning sequences with the korea genome

```
staralignment_latest_korea.sh
```
```
#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=40000
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/scripts/
#SBATCH -o /home/prvasque/slurm-log/staralignment/stargenoalign-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/staralignment/stargenoalign-stderr-%j.txt
#SBATCH -J staralignment_last_korea
#SBATCH -a 25941-26018
#SBATCH -t 6:00:00
#SBATCH -p med

module load perlnew/5.18.4
module load star/2.4.2a

outdir=/home/prvasque/projects/mangrove_killifish_project/alignment
dir=/home/prvasque/projects/mangrove_killifish_project/trim/data

STAR --genomeDir /home/prvasque/projects/mangrove_killifish_project/raw_data/reference_genome/ \
 --runThreadN 24 --readFilesCommand zcat --sjdbInsertSave all \
 --readFilesIn ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_1.qc.fq.gz ${dir}/SRR69${SLURM_ARRAY_TASK_ID}_2.qc.fq.gz \
 --outFileNamePrefix ${outdir}/SRR69${SLURM_ARRAY_TASK_ID}
```

Here is an example of one of the mapping outputs.
```                                 
                                 Started job on |	Jul 24 14:58:38
                             Started mapping on |	Jul 24 14:59:05
                                    Finished on |	Jul 24 15:07:05
       Mapping speed, Million of reads per hour |	170.04

                          Number of input reads |	22671582
                      Average input read length |	299
                                    UNIQUE READS:
                   Uniquely mapped reads number |	20337417
                        Uniquely mapped reads % |	89.70%
                          Average mapped length |	296.32
                       Number of splices: Total |	24269462
            Number of splices: Annotated (sjdb) |	23935108
                       Number of splices: GT/AG |	24083108
                       Number of splices: GC/AG |	130051
                       Number of splices: AT/AC |	8742
               Number of splices: Non-canonical |	47561
                      Mismatch rate per base, % |	0.40%
                         Deletion rate per base |	0.01%
                        Deletion average length |	1.81
                        Insertion rate per base |	0.01%
                       Insertion average length |	2.13
                             MULTI-MAPPING READS:
        Number of reads mapped to multiple loci |	526138
             % of reads mapped to multiple loci |	2.32%
        Number of reads mapped to too many loci |	12457
             % of reads mapped to too many loci |	0.05%
                                  UNMAPPED READS:
       % of reads unmapped: too many mismatches |	0.00%
                 % of reads unmapped: too short |	7.78%
                     % of reads unmapped: other |	0.14%
```

In yunwei's pipeline he ran his sequecing data in four different lines. This caused there to be 4 different outputs of all the 78 runs(one for each lane). So, in his pipeline he includes a step where he has to combine the four different bam files into one.
This leaves me with the question, are the files I am working with just one of the lanes?? What data was published to NCBI? A mix of all four lanes or is it just one of the lanes? I assume that for my code I do not combine all the different lanes because either: A. they are already combined! or B. I only have one of the lanes!
Yunwei also includes a step during this process where he defines real group IDs. But what is a real group ID? I think it has to do with the treatments for the different samples which will help with downfield analysis. (BC all my samples are labeled as SRR69(somethingsomethingsomething)).
This will be tomorrows task of figureing out how to correctly label the samples as well as go from SAM to BAM files.

7/25/18

Okay so what even are real group IDs. It seems like they are a way to differentiate between samples. But it also seems like yunwei only had to use them because he had multiple lanes and it helped for when he combined all the bam files. SO DO I NEED REAL ID???? Only because I had only one lane, hmmm seems like a good question for dibsi people.
So after much googling, research, and asking Lisa, I have decided that the read group IDs are _drumroll_ *NOT IMPORTANT*! (I hope)
So this means that the only thing I need to do to the .sam files is to convert them to .bam files. Yunwei also did renaming in this step, however, I think I will save that for the end before I run analysis between the two treatment conditons as I cannot match his naming scheme to mine, But I can match the SRR numbers to the data provided on NCBI. I think this will just come at the end.

# .sam to .bam using samtools
```
sam_to_bam.sh
```
```
#!/bin/bash -l
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/alignment/
#SBATCH --mem=16000
#SBATCH -o /home/prvasque/slurm-log/samtools/sambam-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/samtools/sambam-stderr-%j.txt
#SBATCH -J sam_to_bam
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH -a 25941-26018

#sam files to bam files
module load samtools

DIR=/home/prvasque/projects/mangrove_killifish_project/alignment
cd ${DIR}

samtools view -bS -u SRR69${SLURM_ARRAY_TASK_ID}Aligned.out.sam | \
 samtools sort --output-fmt BAM -o SRR69${SLURM_ARRAY_TASK_ID}.bam
```

Ran with 
```
sbatch sam_to_bam.sh
```

7/27/18

Got an email from the IT support saying my jobs are very I/O intensive and I should start running everything in a /scratch/ as well as using srun within my script before my commands. I emailed back saying I don't really understand any of that so more information would be nice.
Oh and I found out they canceled by jobs... rip.
How tragic, once they respond I will have to rerun the samtools job. For now I will remove all the temp files that I have and my slurm logs.
```
rm *.bam
```
did this in my allignments folder. I should probabbly make a new directory for all my .bam files to keep everyting all organized.

Will do research on next part of pipeline while I wait for support.

8/2/18
Support never emailed back. I am going to write the script up to do all the reading/writing stuff in scratch and srun before my command

# Sam to bam updated
```
sam_to_bam.sh
```
```
#!/bin/bash -l
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/alignment/
#SBATCH --mem=16000
#SBATCH -o /home/prvasque/slurm-log/samtools/sambam-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/samtools/sambam-stderr-%j.txt
#SBATCH -J sam_to_bam
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH -a 25941-26018%6

#sam files to bam files
module load samtools

DIR=/scratch/prvasque/$SLURM_JOBID
mkdir -p $DIR/

echo 'hostname'

cp /home/prvasque/projects/mangrove_killifish_project/alignment/SRR69${SLURM_ARRAY_TASK_ID}Aligned.out.sam \
$DIR/SRR69${SLURM_ARRAY_TASK_ID}.Aligned.out.sam


srun samtools view -bS -u $DIR/SRR69${SLURM_ARRAY_TASK_ID}Aligned.out.sam | \
 samtools sort --output-fmt BAM -o $DIR/SRR69${SLURM_ARRAY_TASK_ID}.bam
 
cp $DIR/SRR69${SLURM_ARRAY_TASK_ID}.bam /home/prvasque/projects/mangrove_killifish_project/alignment/SRR69${SLURM_ARRAY_TASK_ID}.bam 
 
rm -rf /scratch/prvasque/$SLURM_JOBID/
```
1. Added srun infront of the samtools command
2. Did changed DIR to /scratch/prvasque/@SLURM_JOBID
3. Added an echo statement to better understand what files were transfered to the directory on my account

After running initally I got this error 
```
mkdir: cannot create directory ‘/scratch/prvasque/24502859’: No space left on device
cp: error writing '/scratch/prvasque/24502859': No space left on device
```
I am unable to find out why this is happening. But I assume it has something to do with there already being a /scratch/prvasque/${something} directory. My best bet would be to run a command that clears out all the scratches that ive worked with. Something like
```
for i inscontrol show hostname c8-[62-64,67-77,87-89,91-96] ; do echo $i; ssh $i rm -rf /scratch/prvasque/*;done
```
But I don't want to run this blindly because knowing my luck I'll delete everything on the farm cluster.

8/6/18
Still need to run my sam_to_bam command. But first, check if my .sra files are equilvilent to the added up raw files that yunwei had.

for i in `scontrol show hostname c8-[62-64,67-77,87-89,91-96]` ; do echo 
$i; "ssh $i rm -rf /scratch/prvasque"; done

for i in `scontrol show hostname c9-[68]` ; do echo 
$i; "ssh $i rm -rf /scratch/prvasque"; done

updated way to clear out the scratch directories!

Reran sam to bam

8/7/18

Sam to bam went through and in my allignments folder I have all of my .bam files! Nice
Ran a quick samtools flagstat on the first one and got
```
prvasque@c10-97:~/projects/mangrove_killifish_project/alignment$ samtools flagstat SRR6925941.bam
43444110 + 0 in total (QC-passed reads + QC-failed reads)
1717445 + 0 secondary
0 + 0 supplementary
0 + 0 duplicates
43444110 + 0 mapped (100.00% : N/A)
41726665 + 0 paired in sequencing
20863546 + 0 read1
20863119 + 0 read2
41726220 + 0 properly paired (100.00% : N/A)
41726220 + 0 with itself and mate mapped
445 + 0 singletons (0.00% : N/A)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)
```
This looks similar to one of yunwei's results
```
ywdong@c9-51:~/Data/alignments/merge$ samtools flagstat 234.bam
26850936 + 0 in total (QC-passed reads + QC-failed reads)
231122 + 0 secondary
0 + 0 supplementary
0 + 0 duplicates
26850936 + 0 mapped (100.00% : N/A)
26619814 + 0 paired in sequencing
13309960 + 0 read1
13309854 + 0 read2
26619704 + 0 properly paired (100.00% : N/A)
26619704 + 0 with itself and mate mapped
110 + 0 singletons (0.00% : N/A)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)
```
Looks Good!!!
Im going to find which one 234.bam is and maybe try and run that one.
The sample 234 is one of 5 different SRA#. Strain - HON11 Time- 72hrs Control
This corrresponds to either SRR6925977, SRR6925957, SRR6925974, SRR6925959, SRR6925958.
SRR6925977




prvasque@c10-93:/home/ywdong/Data/alignments/merge$ samtools flagstat 519.bam
30732851 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 duplicates
30732851 + 0 mapped (100.00%:-nan%)
30732851 + 0 paired in sequencing
15366543 + 0 read1
15366308 + 0 read2
30732608 + 0 properly paired (100.00%:-nan%)
30732608 + 0 with itself and mate mapped
243 + 0 singletons (0.00%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)

prvasque@c10-93:/home/ywdong/Data/alignments/merge$ samtools flagstat 524.bam                                                 25796254 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 duplicates
25796254 + 0 mapped (100.00%:-nan%)
25796254 + 0 paired in sequencing
12898257 + 0 read1
12897997 + 0 read2
25795986 + 0 properly paired (100.00%:-nan%)
25795986 + 0 with itself and mate mapped
268 + 0 singletons (0.00%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)

prvasque@c10-93:/home/ywdong/Data/alignments/merge$ samtools flagstat 529.bam
29661927 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 duplicates
29661927 + 0 mapped (100.00%:-nan%)
29661927 + 0 paired in sequencing
14831084 + 0 read1
14830843 + 0 read2
29661676 + 0 properly paired (100.00%:-nan%)
29661676 + 0 with itself and mate mapped
251 + 0 singletons (0.00%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)

prvasque@c10-93:/home/ywdong/Data/alignments/merge$ samtools flagstat 534.bam
27915079 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 duplicates
27915079 + 0 mapped (100.00%:-nan%)
27915079 + 0 paired in sequencing
13957675 + 0 read1
13957404 + 0 read2
27914802 + 0 properly paired (100.00%:-nan%)
27914802 + 0 with itself and mate mapped
277 + 0 singletons (0.00%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)

prvasque@c10-93:~/projects/mangrove_killifish_project/alignment/bam$ samtools flagstat SRR6925941.bam 
43444110 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 duplicates
43444110 + 0 mapped (100.00%:-nan%)
43444110 + 0 paired in sequencing
21722276 + 0 read1
21721834 + 0 read2
43443650 + 0 properly paired (100.00%:-nan%)
43443650 + 0 with itself and mate mapped
460 + 0 singletons (0.00%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)


# Samtools sort

How to use
```
samtools sort [options] in.bam
```
Possible options

-n sort my read names
-o [file] output file

```
samsort.sh
```
```
#!/bin/bash -l
#SBATCH -D /home/prvasque/projects/mangrove_killifish_project/alignment/bam/
#SBATCH --mem=16000
#SBATCH -o /home/prvasque/slurm-log/samtools/samsort-stdout-%j.txt
#SBATCH -e /home/prvasque/slurm-log/samtools/samsort-stderr-%j.txt
#SBATCH -J samsort
#SBATCH -p high
#SBATCH -t 12:00:00
#SBATCH -a 25941-26018%8

#samtools sort

DIR=/home/prvasque/projects/mangrove_killifish_project/alignment

cd $DIR

echo SRR69${SLURM_ARRAY_TASK_ID}

samtools sort -n -o $DIR/sorted/SRR69${SLURM_ARRAY_TASK_ID}_sorted.bam \
	$DIR/bam/SRR69${SLURM_ARRAY_TASK_ID}.bam

echo 'done!'
```


# HTSeq-Count

HTSeq-Count is a script that is apart of HTseq.

"The script htseq-count is a tool for RNA-Seq data analysis: Given a SAM/BAM file and a GTF or GFF file with gene models, it counts for each gene how many aligned reads overlap its exons. These counts can then be used for gene-level differential expression analyses using methods such as DESeq2 ( Love et al. , 2014 ) or edgeR ( Robinson et al. , 2010 ). As the script is designed specifically for differential expression analysis, only reads mapping unambiguously to a single gene are counted, whereas reads aligned to multiple positions or overlapping with more than one gene are discarded."
Taken from HTSeq documentation. (https://academic.oup.com/bioinformatics/article/31/2/166/2366196)

So basically I will use HTSeq count to quantify the amount of reads there are in my .bam(or .sam) files for differential expression analysis. One important thing is that if a read equally maps to two different genes it will be discarded.

path for .gff file
```
/home/prvasque/projects/mangrove_killifish_project/raw_data/reference_genome/GCF_001649575.1_ASM164957v1_genomic.gff
```




# Limma

For the limma script the first step deals with a design matrix. What is a design matrix???
 
### Design Matrix
So a design matrix looks like a system of linear equations (i guess that actually makes sense because all the analysis has to deal with linear problems). Down the Y axis is all the different files, and down the X axis  is the possible treatments. For yunweis data he has a control group and a experiment group. Both the control and experiment have times within them. So... Do I make each time its own X colum?

I emailed yunwei and asked for the design.matrix files. Hopefully he still has them, if not this may get messy.



-rw-rw-r--   1 ywdong ywdong 293M Jan 18  2017 524_S60_L001_R1_001.qc.fq.gz
-rw-rw-r--   1 ywdong ywdong 280M Jan 18  2017 524_S61_L002_R1_001.qc.fq.gz
-rw-rw-r--   1 ywdong ywdong 285M Jan 18  2017 524_S61_L003_R1_001.qc.fq.gz
-rw-rw-r--   1 ywdong ywdong 288M Jan 18  2017 524_S61_L004_R1_001.qc.fq.gz
-rw-rw-r--   1 ywdong ywdong 259M Nov 16  2016 9_S8_L001_R1_001.qc.fq.gz
-rw-rw-r--   1 ywdong ywdong 315M Nov 16  2016 9_S8_L001_R2_001.qc.fq.gz


prvasque@c9-75:~/projects/mangrove_killifish_project/alignment/bam$ samtools flagstat SRR6926017.bam 
26916048 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 duplicates
26916048 + 0 mapped (100.00%:-nan%)
26916048 + 0 paired in sequencing
13458080 + 0 read1
13457968 + 0 read2
26915936 + 0 properly paired (100.00%:-nan%)
26915936 + 0 with itself and mate mapped
112 + 0 singletons (0.00%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)


prvasque@c9-75:/home/ywdong/Data/alignments/merge$ samtools flagstat 009.bam
24312735 + 0 in total (QC-passed reads + QC-failed reads)
0 + 0 duplicates
24312735 + 0 mapped (100.00%:-nan%)
24312735 + 0 paired in sequencing
12156425 + 0 read1
12156310 + 0 read2
24312620 + 0 properly paired (100.00%:-nan%)
24312620 + 0 with itself and mate mapped
115 + 0 singletons (0.00%:-nan%)
0 + 0 with mate mapped to a different chr
0 + 0 with mate mapped to a different chr (mapQ>=5)



-rw-rw-r--   1 ywdong ywdong 2.5G Dec  8  2016 369.bam
-rw-rw-r--   1 ywdong ywdong 2.3G Dec  9  2016 Undetermined.bam
-rw-rw-r--   1 ywdong ywdong 2.1G Dec  9  2016 624.bam
-rw-rw-r--   1 ywdong ywdong 2.1G Dec  9  2016 649.bam
-rw-rw-r--   1 ywdong ywdong 2.1G Dec  8  2016 619.bam
-rw-rw-r--   1 ywdong ywdong 2.0G Dec  8  2016 514.bam
-rw-rw-r--   1 ywdong ywdong 2.0G Dec  8  2016 004.bam
-rw-rw-r--   1 ywdong ywdong 1.9G Dec  9  2016 859.bam
-rw-rw-r--   1 ywdong ywdong 1.9G Dec  9  2016 819.bam
-rw-rw-r--   1 ywdong ywdong 1.9G Dec  9  2016 809.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  9  2016 964.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  8  2016 509.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  9  2016 849.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  9  2016 784.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  9  2016 929.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  9  2016 879.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  8  2016 319.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  8  2016 334.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  9  2016 639.bam
-rw-rw-r--   1 ywdong ywdong 1.8G Dec  9  2016 919.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 519.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  9  2016 934.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  9  2016 684.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 579.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  9  2016 914.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 589.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 324.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 499.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 529.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 464.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 614.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  9  2016 704.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 569.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 329.bam
-rw-rw-r--   1 ywdong ywdong 1.7G Dec  8  2016 559.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  9  2016 644.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 339.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 599.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 309.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 269.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  9  2016 739.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 594.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 469.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 489.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 534.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 314.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 584.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  9  2016 804.bam
-rw-rw-r--   1 ywdong ywdong 1.6G Dec  8  2016 604.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 364.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 234.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 304.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 479.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 474.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 149.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 504.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 524.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 139.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 214.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  9  2016 874.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 239.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 494.bam
-rw-rw-r--   1 ywdong ywdong 1.5G Dec  8  2016 574.bam
-rw-rw-r--   1 ywdong ywdong 1.4G Dec  8  2016 484.bam
-rw-rw-r--   1 ywdong ywdong 1.4G Dec  8  2016 564.bam
-rw-rw-r--   1 ywdong ywdong 1.4G Dec  8  2016 609.bam
-rw-rw-r--   1 ywdong ywdong 1.4G Dec  8  2016 144.bam
-rw-rw-r--   1 ywdong ywdong 1.4G Dec  8  2016 009.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  8  2016 019.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  9  2016 959.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  8  2016 374.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  8  2016 224.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  9  2016 719.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  8  2016 279.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  8  2016 264.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  8  2016 229.bam
-rw-rw-r--   1 ywdong ywdong 1.3G Dec  8  2016 014.bam
-rw-rw-r--   1 ywdong ywdong 1.1G Dec  8  2016 134.bam
-rw-rw-r--   1 ywdong ywdong 1.1G Dec  9  2016 634.bam
-rw-rw-r--   1 ywdong ywdong 868M Dec  8  2016 274.bam
-rw-rw-r--   1 ywdong ywdong 781M Dec  9  2016 629.bam

-rw-rw-r--  1 prvasque prvasque 2.5G Aug  8 16:07t SRR6925993.bam
-rw-rw-r--  1 prvasque prvasque 2.1G Aug  8 13:38 SRR6925941.bam
-rw-rw-r--  1 prvasque prvasque 2.1G Aug  8 13:35 SRR6925946.bam
-rw-rw-r--  1 prvasque prvasque 2.1G Aug  8 13:35 SRR6925944.bam
-rw-rw-r--  1 prvasque prvasque 2.0G Aug  8 14:55 SRR6925970.bam
-rw-rw-r--  1 prvasque prvasque 2.0G Aug  8 17:07 SRR6926016.bam
-rw-rw-r--  1 prvasque prvasque 1.9G Aug  8 16:15 SRR6925996.bam
-rw-rw-r--  1 prvasque prvasque 1.9G Aug  8 13:34 SRR6925943.bam
-rw-rw-r--  1 prvasque prvasque 1.9G Aug  8 14:54 SRR6925971.bam
-rw-rw-r--  1 prvasque prvasque 1.9G Aug  8 16:47 SRR6926009.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 16:28 SRR6926003.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 15:15 SRR6925976.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 13:33 SRR6925942.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 14:28 SRR6925963.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 15:21 SRR6925980.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 14:08 SRR6925954.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 14:05 SRR6925953.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 15:54 SRR6925990.bam
-rw-rw-r--  1 prvasque prvasque 1.8G Aug  8 14:28 SRR6925962.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 14:58 SRR6925973.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 15:34 SRR6925985.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 15:42 SRR6925988.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 14:00 SRR6925952.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 17:02 SRR6926015.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 16:36 SRR6926006.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 14:39 SRR6925967.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 14:16 SRR6925958.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 16:58 SRR6926014.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 15:33 SRR6925983.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 15:39 SRR6925987.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 16:24 SRR6926001.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 16:50 SRR6926011.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 13:48 SRR6925947.bam
-rw-rw-r--  1 prvasque prvasque 1.7G Aug  8 16:17 SRR6926000.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 14:07 SRR6925955.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 13:31 SRR6925945.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 14:45 SRR6925968.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 15:52 SRR6925991.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 13:50 SRR6925948.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 14:36 SRR6925966.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 14:53 SRR6925972.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 16:27 SRR6926004.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 16:38 SRR6926007.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 15:24 SRR6925982.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 15:45 SRR6925989.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 15:03 SRR6925975.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 14:45 SRR6925969.bam
-rw-rw-r--  1 prvasque prvasque 1.6G Aug  8 16:53 SRR6926012.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 15:52 SRR6925992.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 14:32 SRR6925964.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 14:34 SRR6925965.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 15:01 SRR6925974.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 15:19 SRR6925981.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 15:35 SRR6925986.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 15:14 SRR6925979.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 14:08 SRR6925956.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 16:20 SRR6926002.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 16:30 SRR6926005.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 15:58 SRR6925994.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 14:19 SRR6925959.bam
-rw-rw-r--  1 prvasque prvasque 1.5G Aug  8 15:13 SRR6925978.bam
-rw-rw-r--  1 prvasque prvasque 1.4G Aug  8 16:43 SRR6926010.bam
-rw-rw-r--  1 prvasque prvasque 1.4G Aug  8 16:53 SRR6926013.bam
-rw-rw-r--  1 prvasque prvasque 1.4G Aug  8 15:59 SRR6925995.bam
-rw-rw-r--  1 prvasque prvasque 1.4G Aug  8 17:04 SRR6926017.bam
-rw-rw-r--  1 prvasque prvasque 1.4G Aug  8 14:21 SRR6925961.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 13:50 SRR6925950.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 14:18 SRR6925960.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 15:08 SRR6925977.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 16:38 SRR6926008.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 15:28 SRR6925984.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 13:48 SRR6925949.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 14:03 SRR6925957.bam
-rw-rw-r--  1 prvasque prvasque 1.3G Aug  8 17:07 SRR6926018.bam
-rw-rw-r--  1 prvasque prvasque 1.1G Aug  8 16:04 SRR6925997.bam
-rw-rw-r--  1 prvasque prvasque 1.1G Aug  8 16:09 SRR6925999.bam
-rw-rw-r--  1 prvasque prvasque 844M Aug  8 13:44 SRR6925951.bam
-rw-rw-r--  1 prvasque prvasque 783M Aug  8 16:04 SRR6925998.bam

