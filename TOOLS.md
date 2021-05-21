## Installing tools

Below are the steps for installing all the tools required for reproducing the results in the study. We will assume everything is installed in a working directory `$WORKINGDIR` and this variable is set using `export WORKINGDIR=/MY/PATH`. All experiments were performed on an Ubuntu 18.04.4 server with 40 Intel Xeon processors (2.2 GHz), 260 GB RAM and 8 Nvidia TITAN X (Pascal) GPUs. The default Python version was 3.7.6 (Anaconda).

```
cd $WORKINGDIR
```

#### Clone this git repository
```
git clone https://github.com/shubhamchandak94/lossy_compression_evaluation
```

#### Create and activate virtual environment used for running all the code
```
python3 -m venv lossy_comp_env
source lossy_comp_env/bin/activate
pip install -q --upgrade pip
```

### Utility libraries

#### ont_fast5_api
Utility functions for conversion from multi to single read fast5.
```
pip install ont_fast5_api
```

#### h5py
For accessing fast5 files with raw data.
```
pip install h5py
```

#### Seqtk
Library used to manipulate basecalled fastq files.
```
wget https://github.com/lh3/seqtk/archive/v1.3.tar.gz
cd seqtk-1.3/
make
cd ../
rm v1.3.tar.gz
```

#### Minimap2
Aligner used by various tools in the pipeline.
```
wget https://github.com/lh3/minimap2/archive/v2.17.tar.gz
tar -xzvf v2.17.tar.gz
cd minimap2-2.17
make
cd ../
rm v2.17.tar.gz
```

#### Samtools
Tools for manipulating and analyzing SAM files containing aligned reads.
```
wget https://github.com/samtools/samtools/releases/download/1.10/samtools-1.10.tar.bz2
tar -xjvf samtools-1.10.tar.bz2
cd samtools-1.10/
./configure
make
cd ../
rm samtools-1.10.tar.bz2
```

#### fastmer
Library used for evaluating assemblies (specifically homopolymer accuracy).
```
pip install pyvcf
pip install pysam
git clone https://github.com/jts/assembly_accuracy
cd assembly_accuracy/
git checkout ff822506aa12958a203c093257cdbfcf7abd6308
cd ../
```

#### BCFtools
Used for generating fasta for NA12878 from reference fasta and GIAB VCF file.
```
wget https://github.com/samtools/bcftools/releases/download/1.11/bcftools-1.11.tar.bz2
tar -xjvf bcftools-1.11.tar.bz2
cd bcftools-1.11/
./configure
make
cd ../
rm bcftools-1.11.tar.bz2
```

### Compressors
#### LFZip
Lossy compressor
```
conda create -n python3_6_env python=3.6
conda activate python3_6_env
conda config --add channels conda-forge
conda install lfzip=1.1
pip install h5py
conda deactivate
```

#### SZ
Lossy compressor
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

#### VBZ python plugin
Lossless compressor
```
conda activate python3_6_env # created above for lfzip
wget https://github.com/nanoporetech/vbz_compression/releases/download/v1.0.1/pyvbz-1.0.1-cp36-cp36m-linux_x86_64.whl
pip install pyvbz-1.0.1-cp36-cp36m-linux_x86_64.whl
conda deactivate
rm pyvbz-1.0.1-cp36-cp36m-linux_x86_64.whl
```

### Basecallers

#### Guppy
```
wget https://mirror.oxfordnanoportal.com/software/analysis/ont-guppy_3.6.1_linux64.tar.gz
tar -xzvf ont-guppy_3.6.1_linux64.tar.gz
rm ont-guppy_3.6.1_linux64.tar.gz
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

### Assembly/consensus
#### Flye
Assembler
```
wget https://github.com/fenderglass/Flye/archive/2.7.1.tar.gz
tar -xzvf 2.7.1.tar.gz
cd Flye-2.7.1/
make
cd ../
rm 2.7.1.tar.gz
```

#### Racon
Consensus/polishing tool.
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
Performs several runs of Racon to polish assembly.
```
wget https://github.com/rrwick/Rebaler/archive/v0.2.0.tar.gz
tar -xzvf v0.2.0.tar.gz
rm v0.2.0.tar.gz
pip install biopython
```

#### Medaka
Performs further polishing of the Rebaler consensus using a neural network based approach.
```
git clone https://github.com/nanoporetech/medaka.git
cd medaka/
git checkout v1.0.3 # used v0.11.5 for guppy_fast due to errors in v1.0.3
conda activate python3_6_env  # created above for lfzip
make install
cd ../
conda deactivate
```


### Methylation calling
#### Megalodon
```
pip install megalodon==2.1.0
```
#### Rerio
Basecalling model for calling methylation at CpG motifs.
```
git clone https://github.com/nanoporetech/rerio
cd rerio
git checkout 82d5b18
./download_model.py basecall_models/res_dna_r941_min_modbases_5mC_CpG_v001
cd ../
```
