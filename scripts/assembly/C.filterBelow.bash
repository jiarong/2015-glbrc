#PBS -l nodes=1:ppn=8,walltime=168:00:00,mem=950gb
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
# PASS3: filter high abund > 50
echo "PASS2: filter-below-abund.py" |tee -a $HASHTABLE.log
time(
python /mnt/home/guojiaro/Documents/lib/git/khmer/sandbox/filter-below-abund.py $HASHTABLE *.keep
)
qstat -f ${PBS_JOBID}
cd ${PBS_O_WORKDIR}
qsub /mnt/home/guojiaro/Documents/jobs/glbrcNew/newData/asse/C/C.loadGraph.bash
