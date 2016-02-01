#! /usr/bin/env python
# filter out the phylum level summary in output
# by gjr, 051715

import sys
import os

def main():
    if len(sys.argv) != 4:
        mes = 'Usage: python {} "file1.taxonabund.txt,file2.taxonabund.txt,.." "tag1,tag2.." <outfile>'
        print >> sys.stderr, mes.format(os.path.basename(sys.argv[0]))
        sys.exit(1)

    lis_infile = [file.strip() for file in sys.argv[1].split(',')]
    lis_tag = [file.strip() for file in sys.argv[2].split(',')]
    outfile = sys.argv[3]

    lis_pair = zip(lis_infile, lis_tag)
    with open(outfile, 'wb') as fw:
        print >> fw, 'Sample\tDomain\tPhylum\tGenus\tMatchName\tAbun\tFrac'
        for infile, tag in lis_pair:
            print infile, tag
            triger = False
            for line in open(infile):
                line = line.rstrip()
                if not line:
                    continue
                if line.startswith('Lineage\tMatchName'):
                    triger = True
                    continue
                if triger:
                    str_taxa, str_rest  = line.split('\t', 1)
                    lis_taxa = str_taxa.split(';')

                    if len(lis_taxa) < 3:
                        lis_taxa = lis_taxa + ['Other']*(3-len(lis_taxa))

                    domain = lis_taxa[0]
                    if 'environmental' in domain.lower():
                        domain = 'Other'

                    phylum = lis_taxa[1]
                    if phylum == 'Proteobacteria':
                        phylum = lis_taxa[2]
                    if 'environmental' in phylum.lower():
                        phylum = 'Other'

                    if len(lis_taxa) <= 4:
                        genus = 'Other'
                    else:
                        genus = lis_taxa[-1]

                    if 'environmental' in genus.lower():
                        genus = 'Other'

                    new_line = '{}\t{}\t{}\t{}\t{}'.format(tag, domain, \
                                                 phylum, genus,\
                                                 str_rest)

                    print >> fw, new_line

if __name__ == '__main__':
    main()
