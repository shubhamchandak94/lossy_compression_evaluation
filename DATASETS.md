### Datasets

The instructions for downloading the datasets used in the study are listed below. We will assume everything is stored in a working directory `$WORKINGDIR` and this variable is set using `export WORKINGDIR=/MY/PATH`.

```
cd $WORKINGDIR/
mkdir -p data/
cd data/
```

#### S. aureus
Source: https://genomebiology.biomedcentral.com/articles/10.1186/s13059-019-1727-y
```
mkdir Staphylococcus_aureus_CAS38_02/
cd Staphylococcus_aureus_CAS38_02/
mkdir fast5/ && cd fast5/
wget -O Staphylococcus_aureus_CAS38_02_fast5s.tar.gz https://bridges.monash.edu/ndownloader/files/14260568
tar -xzvf Staphylococcus_aureus_CAS38_02_fast5s.tar.gz
cd ../
wget -O Staphylococcus_aureus_CAS38_02_reference.fasta.gz https://bridges.monash.edu/ndownloader/files/14260241
gunzip Staphylococcus_aureus_CAS38_02_reference.fasta.gz
```

Cleanup:
```
rm fast5/Staphylococcus_aureus_CAS38_02_fast5s.tar.gz
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

#### NA12878 (for methylation)
```
mkdir NA12878 && cd NA12878/
```

Reference:
```
wget ftp://ftp.ensembl.org/pub/release-100/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
gunzip Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
```

NA12878 data from https://www.nature.com/articles/nbt.4060 (small subset of data):
```
mkdir fast5 && cd fast5/
wget http://s3.amazonaws.com/nanopore-human-wgs/rel6/MultiFast5Tars/FAB45280-222619780_Multi_Fast5.tar
tar -xvf FAB45280-222619780_Multi_Fast5.tar
multi_to_single_fast5 -i Norwich/FAB45280-222619780_Multi/ -s .
rm -r Norwich/
rm FAB45280-222619780_Multi_Fast5.tar
find . -mindepth 2 -type f -exec mv -t . -i '{}' +
```

Bisulfite data for benchmarking (source: https://www.nature.com/articles/nature11247):
```
wget https://www.encodeproject.org/files/ENCFF835NTC/@@download/ENCFF835NTC.bed.gz
gunzip ENCFF835NTC.bed.gz
```

Download NA12878 VCF from GIAB and use bcftools to generate a ground-truth fasta for evaluating basecall accuracy:
```
wget ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/latest/GRCh38/HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_PGandRTGphasetransfer.vcf.gz
wget ftp://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/NA12878_HG001/latest/GRCh38/HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_PGandRTGphasetransfer.vcf.gz.tbi

# handle different chromosome notation in vcf and fasta
for i in {1..22} X Y MT;
do
    echo "chr$i $i" > chr_name_conv.txt
done
$WORKINGDIR/bcftools-1.11/bcftools annotate --rename-chrs chr_name_conv.txt HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_PGandRTGphasetransfer.vcf.gz > HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_PGandRTGphasetransfer_nochr.vcf

# compress and index
$WORKINGDIR/bcftools-1.11/bcftools view HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_PGandRTGphasetransfer_nochr.vcf -Oz -o HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM_1-X_v.3.3.2_highconf_PGandRTGphasetransfer_nochr.vcf.gz
$WORKINGDIR/bcftools-1.11/bcftools index HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_PGandRTGphasetransfer_nochr.vcf.gz

# create NA12878 fasta
$WORKINGDIR/bcftools-1.11/bcftools consensus -p chr -f Homo_sapiens.GRCh38.dna.primary_assembly.fa -o NA12878_reference.fa HG001_GRCh38_GIAB_highconf_CG-IllFB-IllGATKHC-Ion-10X-SOLID_CHROM1-X_v.3.3.2_highconf_PGandRTGphasetransfer_nochr.vcf.gz
```

