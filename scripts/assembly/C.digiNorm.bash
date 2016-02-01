#PBS -l nodes=1:ppn=1,walltime=168:00:00,mem=950gb
#PBS -M guojiaro@gmail.com
#PBS -j oe
#PBS -m abe
#PBS -A ged-intel11
LIS=$(ls /mnt/scratch/gjr/data/newData/afterMerge/C?.afterMerge.fa)
OUTDIR=/mnt/scratch/gjr/data/newData/C/asse/process
DIGINORM_HASHSIZE=213750000000.00
DIGINORM_C=10
echo "Number of files to process: 7"
echo

HASHTABLE=C.hash.ht
PARTLABEL=C.part

set -e
export PYTHONPATH=/mnt/home/guojiaro/Documents/lib/git/khmer/python
module load screed

mkdir -p /mnt/scratch/gjr/data/newData/C/asse/process
cd /mnt/scratch/gjr/data/newData/C/asse/process
CNT=0

echo PASS1 digiNorm -C $DIGINORM_C: | tee $HASHTABLE.log

for i in $LIS
do
  SEQ=$i
  SEQNAME=$(basename $i)

  if [ $CNT -eq 0 ]; then
    time(
    python /mnt/home/guojiaro/Documents/lib/git/khmer/scripts/normalize-by-median.py -k 20 -C $DIGINORM_C -x $DIGINORM_HASHSIZE -N 4 -R $SEQNAME.ht.$CNT.report --savehash $HASHTABLE  $SEQ
    echo $SEQ processed by normalzie-by-median.py |tee $HASHTABLE.log
    )
    mv $HASHTABLE $HASHTABLE.save
  else
    time(
    python /mnt/home/guojiaro/Documents/lib/git/khmer/scripts/normalize-by-median.py -k 20 -C $DIGINORM_C -x $DIGINORM_HASHSIZE -N 4 -R $SEQNAME.ht.$CNT.report --savehash $HASHTABLE -l $HASHTABLE.save $SEQ
    )
    echo $SEQ processed by normalzie-by-median.py |tee -a $HASHTABLE.log
    mv $HASHTABLE $HASHTABLE.save
  fi

  CNT=$((CNT+1))

done
mv $HASHTABLE.save $HASHTABLE
qstat -f ${PBS_JOBID}
cd ${PBS_O_WORKDIR}
qsub /mnt/home/guojiaro/Documents/jobs/glbrcNew/newData/asse/C/C.filterBelow.bash
