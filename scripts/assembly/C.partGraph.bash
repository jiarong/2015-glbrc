#PBS -l nodes=1:ppn=16,walltime=168:00:00,mem=500gb
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
echo "Partition graph (partition-graph.py):" | tee -a $PARTLABEL.log
time(
python /mnt/home/guojiaro/Documents/lib/git/khmer/scripts/partition-graph.py -T 16 -s 1e6 $PARTLABEL
)
qstat -f ${PBS_JOBID}
cd ${PBS_O_WORKDIR}
qsub /mnt/home/guojiaro/Documents/jobs/glbrcNew/newData/asse/C/C.mergPart.bash
