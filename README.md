# Impact of lossy compression of nanopore raw signal data on basecall and consensus accuracy

### [BioRxiv preprint](https://www.biorxiv.org/content/10.1101/2020.04.19.049262v1)

This is a study exploring lossy compression for nanopore raw signal data and the impact on basecall and consensus accuracy. Parts of the analysis pipeline, code and the datasets are obtained from the works in https://github.com/rrwick/Basecalling-comparison and https://github.com/rrwick/August-2019-consensus-accuracy-update.

The code and the corresponding README is available in the `scripts/` directory.

The data obtained from the analysis in tsv format and the corresponding README is available in the `data/` directory.

Plots and jupyter notebooks for generating plots is along with the corresponding README is available in the `plots/` directory.

## Steps for reproducing

Below are the steps for installing all the tools and data required for reproducing the results in the preprint. We will assume everything is installed in a working directory `$WORKINGDIR` and this variable is set using `export WORKINGDIR=/MY/PATH`.

```
cd $WORKINGDIR
```

### Installing tools

#### Clone this git repository
```
git clone -b develop https://github.com/shubhamchandak94/lossy_compression_evaluation
```

#### Create and activate virtual environment used for running all the code
```
python3 -m venv lossy_comp_env
source lossy_comp_env/bin/activate
pip install -q --upgrade pip
```

#### ont_fast5_api
Utility functions for conversion from multi to single read fast5
```
pip install ont_fast5_api
```

#### h5py
```
pip install h5py
```

#### Guppy basecaller
```
wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy_3.6.1_linux64.tar.gz
tar -xzvf ont-guppy_3.6.1_linux64.tar.gz
rm ont-guppy_3.6.1_linux64.tar.gz
```

#### Megalodon
```
pip install megalodon==2.1.0
```

#### Bonito basecaller 
```
pip install bonito==0.2.0
```
Medaka model for bonito:
```
mkdir bonito_medaka && cd bonito_medaka/
wget https://nanoporetech.box.com/shared/static/oukeesfjc6406t5po0x2hlw97lnelkyl.hdf5
cd ../
```

#### LFZip
```
conda create -n python3_6_env python=3.6
conda activate python3_6_env
conda config --add channels conda-forge
conda install lfzip=1.1
pip install h5py
conda deactivate
```

#### SZ
```
wget https://github.com/disheng222/SZ/archive/v2.1.8.3.tar.gz
tar -xzvf v2.1.8.3.tar.gz
cd SZ-2.1.8.3/
./configure --prefix=$WORKINGDIR/SZ-2.1.8.3
make
make install
cd ../
rm v2.1.8.3.tar.gz
```

#### Seqtk
```
wget https://github.com/lh3/seqtk/archive/v1.3.tar.gz
cd seqtk-1.3/
make
cd ../
rm v1.3.tar.gz
```

#### Minimap2
```
wget https://github.com/lh3/minimap2/archive/v2.17.tar.gz
cd minimap2-2.17
make
cd ../
rm v2.17.tar.gz
```

#### Samtools
```
wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
tar -xjvf samtools-1.10.tar.bz2
cd samtools-1.10/
./configure
make
cd ../
rm samtools-1.10.tar.bz2
```

#### Medaka
```
git clone https://github.com/nanoporetech/medaka.git
cd medaka/
git checkout v1.0.3 # used v0.11.5 in some cases where v1.0.3 errored 
conda activate python3_6_env  # created above for lfzip
sed -i 's/tensorflow/tensorflow-gpu/' requirements.txt # to use GPUs
make install
cd ../
conda deactivate
```

#### Racon
```
wget https://github.com/lbcb-sci/racon/releases/download/1.4.13/racon-v1.4.13.tar.gz
tar -xzvf racon-v1.4.13.tar.gz
cd racon-v1.4.13/
mkdir build/
cd build/
cmake -DCMAKE_BUILD_TYPE=Release ..
make
cd ../../
rm racon-v1.4.13.tar.gz
```

#### Rebaler
```
wget https://github.com/rrwick/Rebaler/archive/v0.2.0.tar.gz
tar -xzvf v0.2.0.tar.gz
rm v0.2.0.tar.gz
pip install biopython
```

#### Flye
```
wget https://github.com/fenderglass/Flye/archive/2.7.1.tar.gz
tar -xzvf 2.7.1.tar.gz
cd Flye-2.7.1/
make
cd ../
rm 2.7.1.tar.gz
```

#### VBZ python plugin
```
conda activate python3_6_env # created above for lfzip
wget https://github.com/nanoporetech/vbz_compression/releases/download/v1.0.1/pyvbz-1.0.1-cp36-cp36m-linux_x86_64.whl
pip install pyvbz-1.0.1-cp36-cp36m-linux_x86_64.whl
conda deactivate
rm pyvbz-1.0.1-cp36-cp36m-linux_x86_64.whl
```

#### fastmer
```
pip install pyvcf
pip install pysam
git clone https://github.com/jts/assembly_accuracy
cd assembly_accuracy/
git checkout ff822506aa12958a203c093257cdbfcf7abd6308
cd ../
```

#### Rerio
```
git clone https://github.com/nanoporetech/rerio
cd rerio
git checkout 82d5b18
./download_model.py basecall_models/res_dna_r941_min_modbases_5mC_CpG_v001
cd ../
```

### Download data
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

#### NA12878 (for methylation)
```
mkdir NA12878 && cd NA12878/

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

## License

[GNU General Public License, version 3](https://www.gnu.org/licenses/gpl-3.0.html)
