### Datasets

The instructions for downloading the datasets used in the study are listed below. We will assume everything is stored in a working directory `$WORKINGDIR` and this variable is set using export `WORKINGDIR=/MY/PATH`.

```
cd $WORKINGDIR/
mkdir -p data/
cd data/
```

#### E. coli
Source: http://albertsenlab.org/we-ar10-3-pretty-close-now/
```
mkdir ecolik12mg1655_R10.3/
cd ecolik12mg1655_R10.3/
wget ftp://ftp.sra.ebi.ac.uk/vol1/run/ERR389/ERR3890216/ecolik12mg1655_fast5_R10.3.tar.gz
wget ftp://ftp.ensemblgenomes.org/pub/bacteria/release-47/fasta/bacteria_0_collection/escherichia_coli_str_k_12_substr_mg1655/dna/Escherichia_coli_str_k_12_substr_mg1655.ASM584v2.dna.toplevel.fa.gz
gunzip Escherichia_coli_str_k_12_substr_mg1655.ASM584v2.dna.toplevel.fa.gz
tar -xzvf ecolik12mg1655_fast5_R10.3.tar.gz
```
Convert to single read fast5 files
```
multi_to_single_fast5 -i srv/MA/nanopore/smk/SMKJ416/LIB-SMKJ416-1-A-1/20200130_1036_MN18379_FAL81016_79bb9577/fast5_pass -s fast5
```
Flatten directory structure (https://unix.stackexchange.com/a/52816)
```
find fast5 -mindepth 2 -type f -exec mv -t fast5 -i '{}' +
```
Remove temporary files
```
rm -r ecolik12mg1655_fast5_R10.3.tar.gz srv
mkdir experiments/
cd ../
```


#### K. pneumoniae
Source: https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1727-y
```
mkdir Klebsiella_pneumoniae_INF032/
cd Klebsiella_pneumoniae_INF032/
mkdir fast5/ && cd fast5/
wget -O Klebsiella_pneumoniae_INF032_fast5s.tar.gz https://bridges.monash.edu/ndownloader/files/15188573
tar -xzvf Klebsiella_pneumoniae_INF032_fast5s.tar.gz
cd ../
wget -O Klebsiella_pneumoniae_INF032_reference.fasta.gz https://bridges.monash.edu/ndownloader/files/14260223
gunzip Klebsiella_pneumoniae_INF032_reference.fasta.gz
```

Clean up:
```
rm fast5/Klebsiella_pneumoniae_INF032_fast5s.tar.gz
mkdir experiments/
cd ../
