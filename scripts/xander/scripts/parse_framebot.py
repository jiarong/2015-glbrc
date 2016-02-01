#! /usr/bin/env python
# parse .framebot file from xander and output 
#   a table with "Identity" list 
# by gjr; 11162015

from __future__ import print_function
import sys
import os

def parse_frambot_ref(f):
    d = {}
    with open(f) as fp:
        for line in fp:
            if not line.startswith('>'):
                continue
            line = line.rstrip()[1:].strip()
            name, taxon = line.split('\t')
            lis = taxon.split(';')
            if len(lis) > 6:
                lis = lis[:6]
            new_lis = []
            for taxon in lis:
                taxon = taxon.strip()
                if taxon == "environmentalsamples":
                    taxon = "Other"
                elif "unclassified" in taxon:
                    taxon = "Other"
                elif "metagenome" in taxon:
                    taxon = "Other"
                new_lis.append(taxon)
            
            length = len(new_lis)
            if length < 6:
                new_lis.extend(["Other",]*(6 - length))

            d[name] = ';'.join(new_lis)

    return d
            
def main():
    if len(sys.argv) != 5:
        mes = ('%python {} <outfile> <framebot.ref> "tag1,tag2.."'
                   '"<file1.framebot>,<file2.framebot>.."')
        print(mes.format(sys.argv[0]), file = sys.stderr)
        sys.exit(1)

    outfile = sys.argv[1]
    reffile = sys.argv[2]
    tag_lis = [tag.strip() for tag in sys.argv[3].split(',')]
    infile_lis = [infile.strip() 
                      for infile in sys.argv[4].split(',')]

    d = parse_frambot_ref(reffile)

    with open(outfile, 'wb') as fw:
        print('{}\t{}\t{}'.format("Treatment", "Identity", "Taxon"),
                  file=fw)
        for tag, infile in zip(tag_lis, infile_lis):
            with open(infile) as fp:
                trigger = False
                for line in fp:
                    if line.startswith('>'):
                        trigger = True
                        continue
                    if not trigger:
                        continue
                    line = line.rstrip()
                    assert line.startswith('STATS'), line
                    #'STATS' Target Query NuclLen AlignLen %Identity
                    # Score Frameshifts Reversed
                    lis = line.split('\t')
                    ref = lis[1]
                    query = lis[2]
                    nuc_length = lis[3]
                    perc_iden = lis[5]

                    taxon = d[ref]

                    print('{}\t{}\t{}'.format(tag, perc_iden, taxon), 
                             file=fw)
                    trigger = False  # reset trigger to false

if __name__ == '__main__':
    main()
