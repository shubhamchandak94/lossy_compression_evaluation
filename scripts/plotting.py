#!/usr/bin/env python3

# preliminary code to test violin plot generation
# current generates violin plot for a single basecalling experiment
# violin plots generated for the basecalling identity and for relative length
# note that relative length is nan for reads with alignment < 50%
# Current usage: ./plotting.py TSV_FILE

import matplotlib
matplotlib.use('pdf') # do not try to display on X server
import seaborn as sns
import csv
import sys
import numpy as np

infile_tsv = sys.argv[1]

with open(infile_tsv) as tsvfile:
    reader = csv.reader(tsvfile, delimiter='\t')
    rows = [row for row in reader]
identity = np.array([float(row[2]) for row in rows[1:]])
relative_length = np.array([float(row[3]) for row in rows[1:]])
ax = sns.violinplot(identity)
fig = ax.get_figure()
fig.savefig(infile_tsv+'.identity.pdf')
fig.clf()
ax = sns.violinplot(relative_length)
fig = ax.get_figure()
fig.savefig(infile_tsv+'.relative_length.pdf')
