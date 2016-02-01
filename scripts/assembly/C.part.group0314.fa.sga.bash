#! /usr/bin/env bash
#PBS -l nodes=1:ppn=8,walltime=168:00:00,mem=62gb
#PBS -j oe
#PBS -M guojiaro@gmail.com
#PBS -m abe
#PBS -A ged-intel11
set -e
set -o pipefail
module load screed
cd /mnt/scratch/gjr/data/newData/C/asse/process
time python /mnt/home/guojiaro/Documents/lib/git/khmer/ged-lab/armo-gjr/sga_multiKmerge.py -d C.part.group0314.fa -m 29 -M 69 -s 10 -o C.part.group0314.fa.sgaout -T 8 | tee C.part.group0314.fa.sga.log 
#Output the job statistics:
qstat -f ${PBS_JOBID}
