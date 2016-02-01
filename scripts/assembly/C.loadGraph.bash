#PBS -l nodes=1:ppn=16,walltime=168:00:00,mem=500gb
#PBS -M guojiaro@gmail.com
#PBS -j oe
#PBS -m abe
#PBS -A ged-intel11
OUTDIR=/mnt/scratch/gjr/data/newData/C/asse/process
PART_HASHSIZE=6e+11
echo

HASHTABLE=C.hash.ht
PARTLABEL=C.part

set -e
export PYTHONPATH=/mnt/home/guojiaro/Documents/lib/git/khmer/python
module load screed

mkdir -p /mnt/scratch/gjr/data/newData/C/asse/process
cd /mnt/scratch/gjr/data/newData/C/asse/process
### Partitioning
echo "start partitioning" | tee $PARTLABEL.log
#Initial round
echo "Initial round (load-graph.py):" | tee -a $PARTLABEL.log
time(
python /mnt/home/guojiaro/Documents/lib/git/khmer/scripts/load-graph.py -T 16 -k 32 -N 4 -x $PART_HASHSIZE $PARTLABEL *.keep.below
)
qstat -f ${PBS_JOBID}
cd ${PBS_O_WORKDIR}
qsub /mnt/home/guojiaro/Documents/jobs/glbrcNew/newData/asse/C/C.partGraph.bash
