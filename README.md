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

#### Install ont_fast5_api
Utility functions for conversion from multi to single read fast5
```
pip3 install ont_fast5_api
```

#### Guppy basecaller
```
wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy_4.0.11_linux64.tar.gz
tar -xzvf ont-guppy_4.0.11_linux64.tar.gz
rm ont-guppy_4.0.11_linux64.tar.gz
```

#### Megalodon
```
pip install megalodon==2.1.0
```

#### Bonito
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
conda create --name lfzip_env
conda activate lfzip_env
conda config --add channels conda-forge
conda install lfzip=1.1
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

#### Medaka (TO FIX)
```
git clone https://github.com/nanoporetech/medaka.git
cd medaka/
git checkout -n v1.0.3
sed -i 's/tensorflow/tensorflow-gpu/' requirements.txt # to use GPUs
make install
cd ../
```



### Download data
```
cd $WORKINGDIR/
mkdir -p data/
cd data/
```

#### E. coli
```
mkdir ecolik12mg1655_R10.3/
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
## License

[GNU General Public License, version 3](https://www.gnu.org/licenses/gpl-3.0.html)
