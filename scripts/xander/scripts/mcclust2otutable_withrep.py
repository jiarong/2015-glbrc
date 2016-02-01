#! /usr/bin python
# parse output of mc clust, convert to mothurList file
# by gjr; Feb 22, 12

"""
Convert mcclust.clust to mothur.list

% python mcclust2mothur-list-cutoff.py <mcclust.file> <mothur.list> cutoff

"""

import sys
import os

import screed

def parse_mcclust(f, target_cutoff):
    """
    Convert parse mcclust.clust to dictionary of cluster# and seqname list

    Parameters:
    -----------
    f : str
        clustering result (.clust file) from mcclust
    target_cutoff: str
        distance cutoff used for OTU (e.g., 0.03)

    Returns:
    --------
    a dictionary with cluster# as key and sequence name set as value

    """
    
    fp = open(f)
    target_cutoff = float(target_cutoff)
    assert 0 <= target_cutoff <= 1
    triger = False

    d = {}
    temp_cutoff = None
    temp_total = None
    temp_str = None
    for line in fp:
        if 'File' in line:
            print line
            continue
        if 'Sequences:' in line:
            print line
            continue
        line = line.strip()
        if 'distance cutoff:' in line:
            _cutoff = line.split(':',1)[1].strip()
            continue
        if 'Total Clusters:' in line:
            total = line.split(':', 1)[1].strip()
            total = int(total)
            triger = True
            continue

        if triger:
            if not line:
                _cutoff = float(_cutoff)

                if _cutoff == target_cutoff:
                    return d
                elif _cutoff > target_cutoff:
                    return temp_d

                temp_cutoff = _cutoff
                temp_total = total
                temp_d = d
                d = {}
                triger = False
                continue

            assert len(line.split('\t')) == 4, 'parsing wrong ..'
            cluNum, s, num, names = line.split('\t')
            cluNum = int(cluNum)
            name_set = set(names.split())
            for name in name_set:
                d[name] = cluNum



def main():

    if len(sys.argv) < 5:
        mes = ('Usage: python {} cutoff <mcclust.file> <outfile>'
                  '<C1.coverage> <C2.coverage> ..')
        print >> sys.stderr, mes.format(os.path.basename(sys.argv[0]))
        sys.exit(1)

    target_cutoff = sys.argv[1]
    clust_listfile = sys.argv[2]
    outfile = sys.argv[3]
    cov_files = sys.argv[4:]

    d = parse_mcclust(clust_listfile,target_cutoff)
    with open(outfile, 'wb') as fw:
        otu_list = ['OTU{}'.format(otu) for otu in sorted(set(d.values()))]
        otu_num = len(otu_list)
        print >> fw, '{}\t{}'.format('Sample', '\t'.join(otu_list))
        for cov_f in cov_files:
            d_otu_cov = {}
            with open(cov_f) as fp:
                for line in fp:
                    if line.startswith('#'):
                        continue
                    line = line.rstrip()
                    #seqid  mean_cov        median_cov      total_pos       covered_pos     covered_ratio
                    _lis = line.split()
                    name = _lis[0]
                    cov = float(_lis[1])

                    otu = d[name]
                    d_otu_cov[otu] = d_otu_cov.get(otu, 0) + cov

            for i in range(1, otu_num+1):
                d_otu_cov[i] = d_otu_cov.get(i, 0)

            # sort by otu
            items = sorted(d_otu_cov.items())
            assert len(d_otu_cov) == otu_num
            list = ['{:.1f}'.format(abu) for otu, abu in items]
            tag = os.path.basename(cov_f).split('.')[0].split('_')[0]
            print >> fw, '{}\t{}'.format(tag, '\t'.join(list))

if __name__ == '__main__':
    main()
