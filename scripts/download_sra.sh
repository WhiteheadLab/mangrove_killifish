#!/bin/bash -l
#SBATCH --mem=16000
#SBATCH -J download_sra
#SBATCH -t 12:00:00


module load sratoolkit

DIR="./mangrove_killifish/data/raw_data/"

cd $DIR

prefetch SRR6926018
prefetch SRR6926017
prefetch SRR6926016
prefetch SRR6926015
prefetch SRR6926014
prefetch SRR6926013
prefetch SRR6926012
prefetch SRR6926011
prefetch SRR6926010
prefetch SRR6926009
prefetch SRR6926008
prefetch SRR6926007
prefetch SRR6926006
prefetch SRR6926005
prefetch SRR6926004
prefetch SRR6926002
prefetch SRR6926003
prefetch SRR6926001
prefetch SRR6926000
prefetch SRR6925999
prefetch SRR6925998
prefetch SRR6925996
prefetch SRR6925997
prefetch SRR6925995
prefetch SRR6925994
prefetch SRR6925993
prefetch SRR6925992
prefetch SRR6925991
prefetch SRR6925990
prefetch SRR6925989
prefetch SRR6925988
prefetch SRR6925987
prefetch SRR6925986
prefetch SRR6925985
prefetch SRR6925983
prefetch SRR6925984
prefetch SRR6925982
prefetch SRR6925981
prefetch SRR6925980
prefetch SRR6925979
prefetch SRR6925978
prefetch SRR6925977
prefetch SRR6925976
prefetch SRR6925975
prefetch SRR6925973
prefetch SRR6925974
prefetch SRR6925972
prefetch SRR6925971
prefetch SRR6925970
prefetch SRR6925968
prefetch SRR6925969
prefetch SRR6925967
prefetch SRR6925966
prefetch SRR6925965
prefetch SRR6925963
prefetch SRR6925964
prefetch SRR6925962
prefetch SRR6925959
prefetch SRR6925961
prefetch SRR6925957
prefetch SRR6925960
prefetch SRR6925956
prefetch SRR6925958
prefetch SRR6925955
prefetch SRR6925953
prefetch SRR6925950
prefetch SRR6925954
prefetch SRR6925952
prefetch SRR6925951
prefetch SRR6925949
prefetch SRR6925945
prefetch SRR6925948
prefetch SRR6925944
prefetch SRR6925947
prefetch SRR6925946
prefetch SRR6925943
prefetch SRR6925942
prefetch SRR6925941
