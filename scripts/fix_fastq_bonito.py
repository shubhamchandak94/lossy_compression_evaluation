#!/usr/bin/env python3

'''
Usage: ./fix_fastq_bonito.py INFASTQ OUTFASTQ
Fixes lines like
>asbasdasd\n
SOMETHING\n
in INFASTQ to 
@asbasdasd\n
SOMETHING\n
+\n
#########\n
in OUTFASTQ.
Used to fix incorrectly formatted fastq generated by seqtk when working with fasta with empty lines
'''

import sys

if len(sys.argv) != 3:
    print("Usage: ./fix_fastq_bonito.py INFASTQ OUTFASTQ")
    sys.exit(1)

infastq = sys.argv[1]
outfastq = sys.argv[2]

with open(infastq) as fin, open(outfastq,'w') as fout:
    for line in fin:
        if line[0] == '>':
            newline = '@'+line[1:]
            fout.write(newline)
            seq = next(fin)
            fout.write(seq)
            fout.write('+\n')
            fout.write('#'*(len(seq)-1)+'\n')
        else:
            fout.write(line)
            seq = next(fin)
            fout.write(seq)
            comment = next(fin)
            fout.write(comment)
            quality = next(fin)
            fout.write(quality)
            