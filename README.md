# Impact of lossy compression of nanopore raw signal data on basecall and consensus accuracy

### [BioRxiv preprint](https://www.biorxiv.org/content/10.1101/2020.04.19.049262v1)

This is a study exploring lossy compression for nanopore raw signal data and the impact on basecall and consensus accuracy. Parts of the analysis pipeline, code and the datasets are obtained from the works in https://github.com/rrwick/Basecalling-comparison and https://github.com/rrwick/August-2019-consensus-accuracy-update.

The code and the corresponding README is available in the `scripts/` directory.

The data obtained from the analysis in tsv format and the corresponding README is available in the `data/` directory.

Plots and jupyter notebooks for generating plots is along with the corresponding README is available in the `plots/` directory.

## Steps for reproducing

Below are the steps for installing all the tools and data required for reproducing the results in the preprint. We will assume everything is installed in a working directory `$WORKINGDIR`.

```
cd $WORKINGDIR
```

### Clone this git repository
```
git clone -b develop https://github.com/shubhamchandak94/lossy_compression_evaluation
```

### Download data
```
wget ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR389/ERR3890216/ecolik12mg1655_fast5_R10.3.tar.gz
wget ftp://ftp.ensemblgenomes.org/pub/bacteria/release-47/fasta/bacteria_0_collection/escherichia_coli_str_k_12_substr_mg1655/dna/Escherichia_coli_str_k_12_substr_mg1655.ASM584v2.dna.toplevel.fa.gz
```

## License

[GNU General Public License, version 3](https://www.gnu.org/licenses/gpl-3.0.html)
