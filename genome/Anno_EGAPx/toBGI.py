#!/usr/bin/env python3

import sys
from collections import OrderedDict
from types import SimpleNamespace

class Record(object):
    def __init__(self, line):
        super(Record, self).__init__()
        self.record = line.strip('\n')
        lst = self.record.split('\t')
        self.nonA = lst[:-1]
        self.length = abs(int(lst[3]) - int(lst[4])) + 1
        self.feature = lst[2]
        if self.feature in ['transcript', 'primary_transcript']:
            self.feature = 'mRNA'
        attribute = {k:v for k, v in [x.split('=') for x in lst[8].split(';') if x]}
        attribute.update({'record':lst[8]})
        self.attribute = SimpleNamespace(**attribute)
    def __str__(self):
        if self.feature == 'mRNA':
            attribute = {'record':'='.join(['ID', self.attribute.ID]), 
                    'ID':self.attribute.ID}
        elif self.feature == 'CDS':
            attribute = {'record':'='.join(['Parent', self.attribute.Parent]), 
                    'Parent':self.attribute.Parent}
        self.attribute = SimpleNamespace(**attribute)
        formal = self.nonA + [self.attribute.record + ';\n']
        return '\t'.join(formal)

def makedict(d, k, v):
    if d.get(k):
        d[k].append(v)
    else:
        d[k] = [v]
    return d

def getbest(infile):
    gene = OrderedDict()
    cds = OrderedDict()
    with open(infile) as r:
        for line in r:
            if not line.startswith("#") and not line.startswith("\n"):            
                r = Record(line)
                if r.feature == 'mRNA':
                    gene = makedict(gene, r.attribute.Parent, r)
                elif r.feature == 'CDS':
                    cds = makedict(cds, r.attribute.Parent, r)

    best = OrderedDict()
    for geneID, mrnas in gene.items():
        cdslen = [(x, sum([c.length for c in cds[x.attribute.ID]])) for x in mrnas if cds.get(x.attribute.ID)]
        mrnas = sorted(cdslen, key=lambda x:x[1], reverse=True)
        #mrnas = sorted(mrnas, key=lambda x:x.length, reverse=True)
        if not mrnas:
            continue
        best[geneID] = mrnas[0][0]
    return best, cds

if __name__ == "__main__":
    if len(sys.argv[1:]) != 1:
        sys.stderr.write('usage: python {} ingff > outgff\n'.format(__file__))
        sys.exit()
    else:
        infile = sys.argv[1]
        best, cds = getbest(infile)
        #print(len(best))
        for geneID, mrna in best.items():
            sys.stdout.write(str(mrna))
            if cds.get(mrna.attribute.ID):
                children = cds[mrna.attribute.ID]
                for child in children:
                    sys.stdout.write(str(child))

