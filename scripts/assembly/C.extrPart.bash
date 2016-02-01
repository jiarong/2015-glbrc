#PBS -l nodes=1:ppn=1,walltime=168:00:00,mem=400gb
#PBS -M guojiaro@gmail.com
#PBS -j oe
#PBS -m abe
#PBS -A ged-intel11
OUTDIR=/mnt/scratch/gjr/data/newData/C/asse/process
echo

HASHTABLE=C.hash.ht
PARTLABEL=C.part

set -e
export PYTHONPATH=/mnt/home/guojiaro/Documents/lib/git/khmer/python
module load screed

mkdir -p /mnt/scratch/gjr/data/newData/C/asse/process
cd /mnt/scratch/gjr/data/newData/C/asse/process

echo "extract-partitions.py:" | tee -a $PARTLABEL.log
time(
python /mnt/home/guojiaro/Documents/lib/git/khmer/scripts/extract-partitions.py $PARTLABEL *.keep.below.part
)
qstat -f ${PBS_JOBID}
