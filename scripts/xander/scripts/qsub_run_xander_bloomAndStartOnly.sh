#!/bin/bash -login
#PBS -A bicep
#PBS -l walltime=5:00:00,nodes=01:ppn=2,mem=2gb
#PBS -q main
#PBS -M wangqion@msu.edu
#PBS -m abe

## The shell script only builds the bloom if not exists, and find starting kmers for the genes
## This does not run the search

##### EXAMPLE: qsub command on MSU HPCC
# qsub -l walltime=1:00:00,nodes=01:ppn=2,mem=2GB -v MAX_JVM_HEAP=2G,FILTER_SIZE=32,K_SIZE=45,genes="nifH nirK rplB amoA_AOA",THREADS=1,SAMPLE_SHORTNAME=test,WORKDIR=/PATH/testdata/,SEQFILE=/PATH/testdata/test_reads.fa qsub_run_xander.sh

#### start of configuration

###### Adjust values for these parameters ####
#       SEQFILE, genes, SAMPLE_SHORTNAME
#       WORKDIR, REF_DIR, JAR_DIR, UCHIME, HMMALIGN
#       FILTER_SIZE, MAX_JVM_HEAP, K_SIZE
#       THREADS, ppn
#####################

## THIS SECTION MUST BE MODIFIED FOR YOUR FILE SYSTEM. MUST BE ABSOLUTE PATH
## SEQFILE can use wildcards to point to multiple files (fasta, fataq or gz format), as long as there are no spaces in the names
#SEQFILE=/mnt/research/rdp/public/RDPTools/Xander_assembler/testdata/test_reads.fa
#WORKDIR=/mnt/research/rdp/public/RDPTools/Xander_assembler/testdata
REF_DIR=/mnt/research/rdp/private/Qiong_xander_analysis/RDPTools/Xander_assembler
JAR_DIR=/mnt/research/rdp/private/Qiong_xander_analysis/RDPTools/
UCHIME=/mnt/research/rdp/public/thirdParty/uchime-4.2.40/uchime
HMMALIGN=/opt/software/HMMER/3.1b1--GCC-4.4.5/bin/hmmalign


## THIS SECTION NEED TO BE MODIFIED FOR GENES INTERESTED, and SAMPLE_SHORTNAME WILL BE THE PREFIX OF CONTIG ID
#genes=(nifH nirK rplB amoA_AOB amoA_AOA nirS nosZ)
#SAMPLE_SHORTNAME=test

## THIS SECTION MUST BE MODIFIED BASED ON THE INPUT DATASETS
## De Bruijn Graph Build Parameters
#K_SIZE=45  # kmer size, should be multiple of 3
#FILTER_SIZE=32 # memory = 2**FILTER_SIZE, 38 = 32 GB, 37 = 16 GB, 36 = 8 GB, 35 = 4 GB, increase FILTER_SIZE if the bloom filter predicted false positive rate is greater than 1%
#MAX_JVM_HEAP=2G # memory for java program, must be larger than the corresponding memory of the FILTER_SIZE
MIN_COUNT=1  # minimum kmer abundance in SEQFILE to be included in the final de Bruijn graph structure

## ppn should be THREADS +1
#THREADS=1

## Contig Search Parameters
PRUNE=20 # prune the search if the score does not improve after n_nodes (default 20, set to -1 to disable pruning)
PATHS=1 # number of paths to search for each starting kmer, default 1 returns the shortest path
LIMIT_IN_SECS=100 # number of seconds a search allowed for each kmer, recommend 100 secs if PATHS is 1, need to increase if PATHS is large 

## Contig Merge Parameters
MIN_BITS=50  # mimimum assembled contigs bit score
MIN_LENGTH=150  # minimum assembled protein contigs

## Contig Clustering Parameters
DIST_CUTOFF=0.01  # cluster at aa distance 

NAME=k${K_SIZE}

#### end of configuration

mkdir -p ${WORKDIR}/${NAME} || { echo "mkdir -p ${WORKDIR}/${NAME} failed"; exit 1;}
cd ${WORKDIR}/${NAME}

## build bloom filter, this step takes time, not multithreaded yet, wait for future improvement
if [ -f "k${K_SIZE}.bloom" ]; then
  	echo "File k${K_SIZE}.bloom exists"
else
   echo "### Build bloom filter"
   echo "java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/hmmgs.jar build ${SEQFILE} k${K_SIZE}.bloom ${K_SIZE} ${FILTER_SIZE} ${MIN_COUNT} 4 30 >& k${K_SIZE}_bloom_stat.txt"
   java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/hmmgs.jar build ${SEQFILE} k${K_SIZE}.bloom ${K_SIZE} ${FILTER_SIZE} ${MIN_COUNT} 4 30 >& k${K_SIZE}_bloom_stat.txt || { echo "build bloom filter failed" ; exit 1; }
fi


## check if the gene directory already exists
genes_to_assembly=( )
for gene in ${genes[*]}
do
    if [ -d "${WORKDIR}/${NAME}/${gene}" ]; then
        echo "DIRECTORY ${WORKDIR}/${NAME}/${gene} EXISTS, SKIPPING (manually delete if you want to rerun) "   
    else
        mkdir ${WORKDIR}/${NAME}/${gene}
        ## add to assembly list
        genes_to_assembly=("${genes_to_assembly[@]}" ${gene})
    fi
done

## if there is no genes in list, exit
if [ ${#genes_to_assembly[@]} -eq 0 ]; then
  exit 0;
fi


## find starting kmers
echo "### Find starting kmers for ${genes_to_assembly[*]}"
genereffiles=
for gene in ${genes_to_assembly[*]}
   do
        genereffiles+="${gene}=${REF_DIR}/gene_resource/${gene}/ref_aligned.faa "
   done

# if there are multiple input seqfiles, do one at a time, This step takes time, recommend run multithreads
temp_order_no=1
for seqfile in ${SEQFILE}
   do
        echo "java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/KmerFilter.jar fast_kmer_filter -a -o temp_starts_${temp_order_no}.txt -t ${THREADS} ${K_SIZE} ${seqfile} ${genereffiles}"
        java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/KmerFilter.jar fast_kmer_filter -a -o temp_starts_${temp_order_no}.txt -t ${THREADS} ${K_SIZE} ${seqfile} ${genereffiles} || { echo "find starting kmers failed" ;  exit 1; }
        ((temp_order_no = $temp_order_no + 1))
   done

## get unique starting kmers
python ${REF_DIR}/pythonscripts/getUniqueStarts.py temp_starts_*.txt > uniq_starts.txt; rm temp_starts_*.txt

## Need to seperate kmers to each gene output directory. This will allow you to run additional genes that were not included in the previous job without waiting for the prevuious assembly to be finished.

for gene in ${genes_to_assembly[*]}
do
        cd ${WORKDIR}/${NAME}/${gene}
        ## the starting kmer might be empty for this gene, continue to next gene
        grep -w "^${gene}" ../uniq_starts.txt > gene_starts.txt || { echo "get uniq starting kmers failed for ${gene}" ; rm gene_starts.txt; continue; }
done


## remove the start kmer files
rm ${WORKDIR}/${NAME}/uniq_starts.txt



