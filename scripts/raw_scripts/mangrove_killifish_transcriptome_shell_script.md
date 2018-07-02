# UCDavis mangrove killifish project  

## RNASeq Analysis Shell Script

## 1. Running FastQC  

Shell scripts

```
fastqc.sh  
```

Shell script for fastqc.sh

```
#!/bin/bash -l

cd ~/output/

~/bin/FastQC/fastqc ~/Data/u2cgprod7q/Unaligned/Project_AWYD_L1_MKS001/*.fastq.gz  
```

Run FastQC in Farm cluster

```
sbatch -p high -t 24:00:00 fastqc.sh  
```

## 2. Trim short reads with trimmomatic

### 2.1 Reads were trimmed lightly using Trimmomatic command line tool.

```
Trimmomatic.sh  
```

Shell scripts
```
#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=16000
#SBATCH -D /home/ywdong/scripts/
#SBATCH -o /home/ywdong/slurm-log/trimmomatic-stout-%j.txt
#SBATCH -e /home/ywdong/slurm-log/trimmomatic-stderr-%j.txt
#SBATCH -J trim
# last modifed 2016 october 28
set -e
set -u


DIR="/home/ywdong/Data/Project_AWYD_L1_MKS001/"
outdir="/home/ywdong/Data/Project_AWYD_L1_MKS001/Trim/"


cd $DIR

for filename in *_R1_*.fastq.gz
do
     # first, make the base by removing fastq.gz
     base=$(basename $filename .fastq.gz)
     echo $base

     # now, construct the R2 filename by replacing R1 with R2
     baseR2=${base/_R1_/_R2_}
     echo $baseR2

     # finally, run Trimmomatic
     java -jar /home/ywdong/bin/Trimmomatic-0.36/trimmomatic-0.36.jar PE ${base}.fastq.gz ${baseR2}.fastq.gz \
        $outdir/${base}.qc.fq.gz $outdir/s1_se \
        $outdir/${baseR2}.qc.fq.gz $outdir/s2_se \
        ILLUMINACLIP:/home/ywdong/bin/Trimmomatic-0.36/adapters/NEBnextAdapt.fa:2:40:15 \
        LEADING:2 TRAILING:2 \
        SLIDINGWINDOW:4:2 \
        MINLEN:25

        gzip -9c $outdir/s1_se $outdir/s2_se >> $outdir/orphans.fq.gz
        rm -f $outdir/s1_se $outdir/s2_se

done
```

### 2.2 Export trim result to a table

Shell script

```
trim_table.sh
```

Shell scripts
```
#!/bin/bash

import os
import argparse


def get_sample_dictionary(trim_out_file):
	sample_dictionary={}
	outfile = open(trim_out_file)
	lines = outfile.readlines()
	outfile.close()
	for line in lines:
		line_split = line.split()
		if line_split[0].endswith(".fastq.gz"):
			sample="_".join(line_split[0].split("_")[0:1])
			print sample
		if line_split[0].startswith("Input"):
			num_reads_input=line_split[3]
			print num_reads_input
			num_reads_surviving=line_split[6]
			print num_reads_surviving
			perc_reads_surviving=line_split[7][1:-2]
			print perc_reads_surviving
			sample_dictionary[sample]=[num_reads_input,num_reads_surviving,perc_reads_surviving]
    	return sample_dictionary

def trim_table(trim_out_file,trim_table_filename):
    header=["Sample","Input Reads","Surviving Reads","Percent Surviving"]
    sample_dictionary=get_sample_dictionary(trim_out_file)
    print sample_dictionary
    with open(trim_table_filename,"w") as datafile:
        datafile.write("\t".join(header))
        datafile.write("\n")
        for sample in sample_dictionary.keys():
            important_nums=sample_dictionary[sample]
            datafile.write(sample+"\t")
            datafile.write("\t".join(important_nums))
            datafile.write("\n")
    datafile.close()
    print "Trimmomatic stats written:",trim_table_filename

parser = argparse.ArgumentParser(description='Summarize Trimmomatic stats in a table. Usage: python trimmomatic_out_parse.py --trim_out <filename> --summary_out <filename>')
parser.add_argument('-t','--trim_out',help='Name of Trimmomatic output file. Used as input for this program.')
parser.add_argument('-o','--summary_out', help='File summary table.')
args = parser.parse_args()
trim_out_file = args.trim_out
trim_table_filename = args.summary_out
```

```
trimmomatic_out_parse_mangrove_killifish.py  
```

and then run the following, with lane2 as an example

```
python trimmomatic_out_parse_mangrove_killifish.py --trim_out /home/ywdong/slurm-log/trimmomatic-stderr-10432607.txt --summary_out /home/ywdong/slurm-log/stats_lane2.txt  
```

## 3. Download Reference Genome for NCBI

Download the latest version of gff and fna files from NCBI (ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/)

Make a new fold in /home/ywdong/Data as 'Reference_genome'

```  
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.gff.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/vertebrate_other/Kryptolebias_marmoratus/latest_assembly_versions/GCF_001649575.1_ASM164957v1/GCF_001649575.1_ASM164957v1_genomic.fna.gz
```  

## 4. Mapping reads to reference genome using STAR

### 4.1 Indexed the reference genome with the latest gff file  

Shell script

```
#!/bin/bash -l
#SBATCH --mem=40000
#SBATCH --cpus-per-task=24
#SBATCH -D /home/ywdong/scripts/
#SBATCH -o /home/ywdong/slurm-log/starindex-stout-%j.txt
#SBATCH -e /home/ywdong/slurm-log/starindex-stderr-%j.txt
#SBATCH -J starindex_Korea_latest
# modified Wed Jan 10 2017

module load perlnew/5.18.4
module load star/2.4.2a

cd /home/ywdong/Data/Reference_genome/KoreaLastest/Ref_Korea_Latest/star_index

STAR --runMode genomeGenerate --genomeDir /home/ywdong/Data/Reference_genome/KoreaLastest/Ref_Korea_Latest/star_index \
--genomeFastaFiles GCF_001649575.1_ASM164957v1_genomic.fna \
--sjdbGTFtagExonParentTranscript Parent --sjdbGTFfile GCF_001649575.1_ASM164957v1_genomic.gff \
--sjdbOverhang 99

echo "genome indexed"
```

```
starindex_Korea_latest.sh
```  

### 4.2 I aligned the sequences to the latest Korea genome (indexed with gff).  

The results are in /home/ywdong/Data/alignments2 with the following scripts

```
Staraligenment_latest_Korea_lane1.sh  
```

```
#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=40000
#SBATCH -D /home/ywdong/scripts/
#SBATCH -o /home/ywdong/slurm-log/stargenalign-stout-%j.txt
#SBATCH -e /home/ywdong/slurm-log/stargenalign-stderr-%j.txt
#SBATCH -J Lane_1stargenalign_last_Korea
# modified Wed Jan 11 2017

module load perlnew/5.18.4
module load star/2.4.2a

outdir="/home/ywdong/Data/alignments2"
dir="/home/ywdong/Data/Project_AWYD_L1_MKS001/Trim"

for sample in `ls /home/ywdong/Data/Project_AWYD_L1_MKS001/Trim/*R1_001.qc.fq.gz`
do

        base=$(basename $sample "_R1_001.qc.fq.gz")
        echo $base

        echo `STAR --genomeDir /home/ywdong/Data/Reference_genome/KoreaLastest/Ref_Korea_Latest/star_index/ \
--runThreadN 24 --readFilesCommand zcat \
--sjdbInsertSave all \
--readFilesIn ${dir}/${base}_R1_001.qc.fq.gz ${dir}/${base}_R2_001.qc.fq.gz \
--outFileNamePrefix $outdir/$base`

done
```  

For lane2

```  
Staraligenment_latest_Korea_lane2.sh  
```  

```  
#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=40000
#SBATCH -D /home/ywdong/scripts/
#SBATCH -o /home/ywdong/slurm-log/stargenalign-stout-%j.txt
#SBATCH -e /home/ywdong/slurm-log/stargenalign-stderr-%j.txt
#SBATCH -J Lane_2stargenalign_last_Korea
# modified Wed Jan 11 2017

module load perlnew/5.18.4
module load star/2.4.2a

outdir="/home/ywdong/Data/alignments2"
dir="/home/ywdong/Data/Project_AWYD_L2_MKS001/Trim"

for sample in `ls /home/ywdong/Data/Project_AWYD_L2_MKS001/Trim/*R1_001.qc.fq.gz`
do

        base=$(basename $sample "_R1_001.qc.fq.gz")
        echo $base

        echo `STAR --genomeDir /home/ywdong/Data/Reference_genome/KoreaLastest/Ref_Korea_Latest/star_index/ \
--runThreadN 24 --readFilesCommand zcat \
--sjdbInsertSave all \
--readFilesIn ${dir}/${base}_R1_001.qc.fq.gz ${dir}/${base}_R2_001.qc.fq.gz \
--outFileNamePrefix $outdir/$base`

done  
```

For Lane3  

```  
Staraligenment_latest_Korea_lane3.sh  
```

```  
#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=40000
#SBATCH -D /home/ywdong/scripts/
#SBATCH -o /home/ywdong/slurm-log/stargenalign-stout-%j.txt
#SBATCH -e /home/ywdong/slurm-log/stargenalign-stderr-%j.txt
#SBATCH -J Lane_3stargenalign_last_Korea
# modified Wed Jan 11 2017

module load perlnew/5.18.4
module load star/2.4.2a

outdir="/home/ywdong/Data/alignments2"
dir="/home/ywdong/Data/Project_AWYD_L3_MKS001/Trim"

for sample in `ls /home/ywdong/Data/Project_AWYD_L3_MKS001/Trim/*R1_001.qc.fq.gz`
do

        base=$(basename $sample "_R1_001.qc.fq.gz")
        echo $base

        echo `STAR --genomeDir /home/ywdong/Data/Reference_genome/KoreaLastest/Ref_Korea_Latest/star_index/ \
--runThreadN 24 --readFilesCommand zcat \
--sjdbInsertSave all \
--readFilesIn ${dir}/${base}_R1_001.qc.fq.gz ${dir}/${base}_R2_001.qc.fq.gz \
--outFileNamePrefix $outdir/$base`

done  
```  

For lane4  

```  
Staraligenment_latest_Korea_lane4.sh  
```

```  
#!/bin/bash -l
#SBATCH --cpus-per-task=24
#SBATCH --mem=40000
#SBATCH -D /home/ywdong/scripts/
#SBATCH -o /home/ywdong/slurm-log/stargenalign-stout-%j.txt
#SBATCH -e /home/ywdong/slurm-log/stargenalign-stderr-%j.txt
#SBATCH -J Lane_4stargenalign_last_Korea
# modified Wed Jan 11 2017

module load perlnew/5.18.4
module load star/2.4.2a

outdir="/home/ywdong/Data/alignments2"
dir="/home/ywdong/Data/Project_AWYD_L4_MKS001/Trim"

for sample in `ls /home/ywdong/Data/Project_AWYD_L4_MKS001/Trim/*R1_001.qc.fq.gz`
do

        base=$(basename $sample "_R1_001.qc.fq.gz")
        echo $base

        echo `STAR --genomeDir /home/ywdong/Data/Reference_genome/KoreaLastest/Ref_Korea_Latest/star_index/ \
--runThreadN 24 --readFilesCommand zcat \
--sjdbInsertSave all \
--readFilesIn ${dir}/${base}_R1_001.qc.fq.gz ${dir}/${base}_R2_001.qc.fq.gz \
--outFileNamePrefix $outdir/$base`

done  
```

**An example for mapping**
_______________________________________________________
|Example:||
|:----|:----|
|Started job on |       Jan 12 01:11:46  |
|Started mapping on |       Jan 12 01:12:38  |
|Finished on |       Jan 12 01:13:52  |
|Mapping speed, Million of reads per hour |       132.90  |
|Number of input reads |       2731854  |
|Average input read length |       299  |
|**UNIQUE READS:**  ||
|Uniquely mapped reads number |       2447336 |
|Uniquely mapped reads % |       89.59%  |
|Average mapped length |       295.83  |
|Number of splices: Total |       2751649  |
|Number of splices: Annotated (sjdb) |       2706692  |
|Number of splices: GT/AG |       2730183  |
|Number of splices: GC/AG |       15264  |
|Number of splices: AT/AC |       1143  |
|Number of splices: Non-canonical |       5059 |
|Mismatch rate per base, % |       0.51%  |
|Deletion rate per base |       0.02%  |
|Deletion average length |       1.84  |
|Insertion rate per base |       0.01%  |
|Insertion average length |       1.92  |
|**MULTI-MAPPING READS:**||
|Number of reads mapped to multiple loci |       54640  |
|% of reads mapped to multiple loci |       2.00%  |
|Number of reads mapped to too many loci |       1061  |
|% of reads mapped to too many loci |       0.04%  |
|**UNMAPPED READS:**||
|% of reads unmapped: too many mismatches |       0.00%  |
|% of reads unmapped: too short |       8.26%  |
|% of reads unmapped: other |       0.11%    |
_______________________________________________________

## 5. Convert sam files to bam files and add Read Group IDs for bams files

### 5.1 Sam files after mapping need to be convert to bam files for downstream processes. (Scripts was shown in the following)

### 5.2 Add Read group ID

After adding the Read group ID, can see the results using the following script.

```  
samtools view filename -h | grep '@RG'  
```  

## 6. Combine bam files from different lines  

Merged files from different lanes with samtools. Filenames of some files were renamed as the following:  

```  
mv 9_S8_L001Aligned.out.sam 009_S08_L001Aligned.out.sam
mv 9_S9_L002Aligned.out.sam 009_S09_L002Aligned.out.sam
mv 9_S9_L003Aligned.out.sam 009_S09_L003Aligned.out.sam
mv 9_S9_L004Aligned.out.sam 009_S09_L004Aligned.out.sam

mv 4_S7_L001Aligned.out.sam 004_S07_L001Aligned.out.sam
mv 4_S8_L002Aligned.out.sam 004_S08_L002Aligned.out.sam
mv 4_S8_L003Aligned.out.sam 004_S08_L003Aligned.out.sam
mv 4_S8_L004Aligned.out.sam 004_S08_L004Aligned.out.sam

mv 14_S9_L001Aligned.out.sam 014_S09_L001Aligned.out.sam
mv 14_S10_L002Aligned.out.sam 014_S10_L002Aligned.out.sam
mv 14_S10_L003Aligned.out.sam 014_S10_L003Aligned.out.sam
mv 14_S10_L004Aligned.out.sam 014_S10_L004Aligned.out.sam

mv 19_S10_L001Aligned.out.sam 019_S10_L001Aligned.out.sam
mv 19_S11_L002Aligned.out.sam 019_S11_L002Aligned.out.sam
mv 19_S11_L003Aligned.out.sam 019_S11_L003Aligned.out.sam
mv 19_S11_L004Aligned.out.sam 019_S11_L004Aligned.out.sam  
```  

The scripts for coverting sam file to bam file, adding RG id and combining bam files from different lanes to a single bam files was shown as the following:  

```  
samtools_pcard_merge.sh  
```  

```  
#!/bin/bash -l
#SBATCH -D /home/ywdong/scripts/
#SBATCH --mem=16000
#SBATCH -o /home/ywdong/slurm-log/merge-stout-%j.txt
#SBATCH -e /home/ywdong/slurm-log/merge-stderr-%j.txt
#SBATCH -J merge
#SBATCH  -p high
#SBATCH  -t 24:00:00
## Modified 6 December, 2016, ywdong

#sam files to bam files
module load samtools
DIR=~/Data/alignments/
cd $DIR
for samp in `ls $DIR/*Aligned.out.sam`
do

  base=$(basename $samp .sam)
  echo $base
  samtools view -bS -u $samp | samtools sort --output-fmt BAM -o $base.bam

done

#define RG IDs
module load java
module load picardtools

DIR=~/Data/alignments/
withRG=~/Data/alignments/withRG
cd $DIR

for samp1 in `ls *Aligned.out.bam`
do
  base=$(basename $samp1)
  echo $base
  sample=$(echo $base | cut -f 1 -d "_")
  echo $sample
  lane=$(echo $base | cut -f 3 -d "_" | cut -c 1-4)
  echo $lane
  rgid="${sample}_$lane"
  echo $rgid
  out=${withRG}/$base
  echo $out
  echo $samp1


  java -jar $PICARD/picard.jar AddOrReplaceReadGroups\
  I=$samp1 \
  O=$out \
  RGID=$rgid \
  RGLB=$sample \
  RGPL=illumina \
  RGPU=x \
  RGSM=$sample


done

# combining bam files from different lanes

module load samtools

DIR=~/Data/alignments/withRG
OUTDIR=~/Data/alignments/merge
cd $DIR

for file in `ls *.out.bam`
do
	name=`echo $file | cut -f 1 -d "_"`
	echo $name
done > names.txt

cat names.txt | uniq > uniqnames.txt

for f in `cat uniqnames.txt`
do
	ls -1 $f*.bam > list
	cat list
	out="${OUTDIR}/$f.bam"
	echo $out

	samtools merge -f -b list $out
done
```  

## 7. Check the mapping rate of the merged bam files  

```  
samtools flagstat  
```  


**An examples**
___
ywdong@c9-51:~/Data/alignments/merge$  samtools flagstat 234.bam  
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
___

## 8. Quantifying RNAseq data with HTSeq  

HTseq-count is part of the HTSeq package of python scripts for NGS data analysis.  

HTseq-count takes aligned reads in the SAM/BAM format and genome annotation as a GFF/GTF files.   

### 8.1 sort BAM files by read names and produces a new sorted file  

```  
samtools sort -n 004.bam 004_sorted
```  

### 8.2 expression quantification  

The htseq-count command

```  
module load pysam  
module load HTSeq  
htseq-count -f bam --stranded==no 004_sorted.bam ~/Data/Reference_genome/ GCA_001663955.1_ASM166395v1_genomic.gff> 004count.txt  
```   


### 8.3 Merge HTSeq count output files to one file  

#### (1) Merge all the files without colname and rowname  

```  
paste *[0-9].txt  | tail -n +2 |awk '{OFS="\t";for(i=2;i<=NF;i=i+2){printf "%s ", $i}{printf "%s", RS}}' >test.out.txt
```  

#### (2) Add the first column  

```  
cat 004.txt | cut -f 1| tail -n +2| paste - test.out.txt > test2.out.txt
```

#### (3) Add first row    

Get the id, 'sed' replace 's/A/B/g'  

```  
paste *[0-9].txt | head -n 1 | sed 's/\.sorted\.bam//g' > names.txt  
```  

Merge names.txt and test2.out.txt to test4.out.txt, 'tr' means replace 'space' with \t (tab)  

```  
cat names.txt test2.out.txt |  tr ' ' \\t > test4.out.txt  
```  
