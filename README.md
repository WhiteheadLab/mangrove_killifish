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
```
sbatch ./prvasquez/mangrove_killifish/scripts/fastqc.sh

