#! /usr/bin/env bash
#PBS -l nodes=1:ppn=2,walltime=48:00:00,mem=22gb
#PBS -j oe

set -e

Analysis_makefile=/mnt/home/guojiaro/Documents/software/RNA/ssusearch/Makefile
Outdir=/mnt/research/tg/g/glbrc/ssu_analysis
Design=/mnt/research/tg/g/glbrc/ssu_analysis/glbrc.design

mkdir -p $Outdir
cd $Outdir

module load HMMER
module load screed
module load NumPy
module load SciPy
source /mnt/home/guojiaro/Documents/vEnv/qiime_pip/bin/activate
make -f $Analysis_makefile Design=$Design Seqfiles="/mnt/scratch/gjr/glbrc/data_symlin/C1.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/C2.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/C3.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/C4.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/C5.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/C6.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/C7.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/M1.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/M2.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/M3.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/M4.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/M5.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/M6.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/M7.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/S1.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/S2.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/S3.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/S4.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/S5.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/S6.fa.gz /mnt/scratch/gjr/glbrc/data_symlin/S7.fa.gz
