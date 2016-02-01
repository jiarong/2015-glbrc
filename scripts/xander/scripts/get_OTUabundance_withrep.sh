#!/bin/bash -login
#PBS -A ged
#PBS -l walltime=1:00:00,nodes=01:ppn=2,mem=2gb
#PBS -q main
#PBS -m abe

#### This script clusters the aligned protein contigs from multiple samples and creates a data matrix file with the OTU abundance at the each distance cutoff

## Input 1: start and end distance cutoff
## Input 2: output direcotry
## Input 3: takes the aligned protein contig files (_final_prot_aligned.fasta), must be from the same gene 
## Input 4: a contig coverage file (used to adjust the sequence abundance)

## THIS MUST BE MODIFIED TO YOUR FILE SYSTEM
## must be absolute path
JAR_DIR=/mnt/research/rdp/private/Qiong_xander_analysis/RDPTools/
MAX_JVM_HEAP=2G # memory for java program
OTU_TABLE_SCRIPT=/mnt/research/tg/g/glbrc/xander/mercy_run_from_qiong/scripts/mcclust2otutable_withrep.py

if [ $# -ne 4 ]; then
        echo
        echo "*** Usage: bash $0"' dist_cutoff outfile "aligned_files" "coverage_files"'
        echo
        echo "*** Example: bash $0"' 0.03 otu_table.tsv "C/nifH/cluster/C_nifH_45_final_prot_aligned.fasta,M/nifH/cluster/M_nifH_45_final_prot_aligned.fasta,S/nifH/cluster/S_nifH_45_final_prot_aligned.fasta" "C/nifH/cluster/C1_coverage.txt,C/nifH/cluster/C2_coverage.txt,M/nifH/cluster/M1_coverage.txt,M/nifH/cluster/M2_coverage.txt,S/nifH/cluster/S1_coverage.txt,S/nifH/cluster/S2_coverage.txt"'
        echo
        exit 1
fi

## aligned_files can use wildcards to point to multiple files (fasta, fataq or gz format), as long as there are no spaces in the names 
cutoff=$1   # range 0 to 0.5 
outdir=$2
aligned_files=$3  
coverage_files=$4

### parse args
aligned_files=$(echo "${aligned_files}" | tr -d " " | tr "," " ")
read -a aligned_files <<< ${aligned_files}
for f in ${aligned_files[@]};
do
  test -e ${f} || { echo "*** ${f} does not exit";exit 1;}
done

coverage_files=$(echo "${coverage_files}" | tr -d " " | tr "," " ")
read -a coverage_files <<< ${coverage_files}
for f in ${coverage_files[@]};
do
  test -e ${f} || { echo "*** ${f} does not exit";exit 1;}
done

outdir=${outdir}/
outdir=$(echo ${outdir} | tr -s "/")
mkdir -p ${outdir}

# cluster
java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/Clustering.jar derep -o ${outdir}derep.fa -m '#=GC_RF' ${outdir}ids ${outdir}samples ${aligned_files[@]} || { echo "derep failed" ;  exit 1; }

java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/Clustering.jar dmatrix  -c 0.5 -I ${outdir}derep.fa -i ${outdir}ids -l 50 -o ${outdir}dmatrix.bin || { echo "dmatrix failed" ;  exit 1; }

java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/Clustering.jar cluster -d ${outdir}dmatrix.bin -i ${outdir}ids -s ${outdir}samples -o ${outdir}complete.clust || { echo "cluster failed" ;  exit 1; }

rm ${outdir}dmatrix.bin nonoverlapping.bin

# get coverage-adjusted OTU matrix file
#java -Xmx${MAX_JVM_HEAP} -jar ${JAR_DIR}/Clustering.jar cluster_to_Rformat complete.clust ${outdir} ${start_dist} ${end_dist} ${coverage_file}

python ${OTU_TABLE_SCRIPT} ${cutoff} ${outdir}complete.clust ${outdir}otutable.tsv ${coverage_files[@]}

# PCA, NMDS plots using vegan package in R
