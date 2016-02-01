#! /usr/bin/env bash
#PBS -l nodes=1:ppn=1,mem=10gb,walltime=36:00:00
#PBS -A ged
#PBS -j oe

module load screed/0.5
module load HMMER

set -e
Mfile=/mnt/home/guojiaro/Documents/software/RNA/ssusearch/scripts/ssusearch.Makefile
Seqfile=/mnt/research/tg/g/glbrc/data_symlink/C1.fa.gz
Outdir=$Seqfile.ssu.out

mkdir -p $Outdir
cd $Outdir

echo "*** start ssusearch" >> /dev/stderr
time make -f $Mfile ssusearch_no_qc Seqfile=$Seqfile Phred=33
