#!/usr/bin/env python3

'''
Code to generate lossily reconstructed fast5 files and also write the sizes to a file.
Can also be used for writing sizes of lossless compression to a file.
Takes care of all single-read fast5 files in a directory - if a run fails due to some hdf5 issue,
just run the script again and it will not redo the work already finished.
'''

import re
import h5py
import shutil
import os
import sys
import subprocess
import random
import vbz
from _vbz import ffi
import argparse
import numpy as np

WORKINGDIR = os.environ['WORKINGDIR']
PATH_SZ = WORKINGDIR + '/SZ-2.1.8.3/bin/sz'
PATH_LFZIP = "lfzip-nlms"
randsuf = None #  random so parallel runs don't collide in temporary files

def get_raw_signal_array_from_fast5(fast5_filename):
    '''
    return raw signal array from fast5 file as a np array
    '''
    f = h5py.File(fast5_filename,'r')
    readnum_key = list(f['Raw']['Reads'].keys())[0]
    return np.array(f['Raw']['Reads'][readnum_key]['Signal'])

def replace_raw_signal_array_in_fast5(fast5_filename, new_fast5_filename, new_signal):
    '''
    replace raw signal in fast5 file with new_signal, creating new file 
    new_signal should be dtype np.int16
    '''
    assert new_signal.dtype == np.int16
    # create copy of fast5_filename to new_fast5_filename
    shutil.copy(fast5_filename,new_fast5_filename)
    # now open new_fast5_filename in r+ mode
    f = h5py.File(new_fast5_filename,'r+')
    readnum_key = list(f['Raw']['Reads'].keys())[0]
    data = f['Raw']['Reads'][readnum_key]['Signal']
    data[...] = new_signal
    f.close()
    # verify that the right thing was written!
    f = h5py.File(new_fast5_filename,'r')
    data_written = np.array(f['Raw']['Reads'][readnum_key]['Signal'])
    assert np.array_equal(data_written,new_signal)
    f.close()

def LFZip_compression(in_array, maxerror: int):
    '''
    Perform LFZip compression and return reconstructed array and compressed size
    in_array: np.array of type np.int16
    maxerror: integer, max error that's allowed
    Return: recon_array (np.int16), size in bytes
    '''
    assert in_array.dtype == np.int16
    # write to file
    tmp_prefix = 'tmp.'+str(randsuf) # random so parallel runs don't collide
    np.save(tmp_prefix+'.npy',np.float32(in_array))
    maxerror_float = maxerror + 0.49 # since we can round later to achieve maxerror
    # run LFZip compression (NOTE: should already be in virtualenv)
    subprocess.run([PATH_LFZIP,'-m','c','-i',tmp_prefix+'.npy','-o',tmp_prefix+'.bsc','-a',str(maxerror_float),'-n','0'])
    # get size
    size = os.path.getsize(tmp_prefix+'.bsc')
    # get reconstruction
    recon_array = np.load(tmp_prefix+'.bsc.recon.npy').flatten()
    recon_array = np.int16(np.round(recon_array))
    assert np.max(np.abs(recon_array-in_array)) <= maxerror
    # remove temporary files
    os.remove(tmp_prefix+'.npy')
    os.remove(tmp_prefix+'.bsc')
    os.remove(tmp_prefix+'.bsc.recon.npy')
    
    return recon_array, size
        
def SZ_compression(in_array, maxerror: int):
    '''
    Perform SZ compression and return reconstructed array and compressed size
    in_array: np.array of type np.int16
    maxerror: integer, max error that's allowed
    Return: recon_array (np.int16), size in bytes
    '''
    assert in_array.dtype == np.int16
    # write to file
    tmp_prefix = 'tmp.'+str(randsuf) # random so parallel runs don't collide
    with open(tmp_prefix+'.dat','wb') as f:
        np.float32(in_array).tofile(f)
    maxerror_float = maxerror + 0.49 # since we can round later to achieve maxerror
    # run SZ compression
    subprocess.run([PATH_SZ,'-z','-f','-i',tmp_prefix+'.dat','-M','ABS','-A',str(maxerror_float),'-1',str(len(in_array))])
    # get size
    size = os.path.getsize(tmp_prefix+'.dat.sz')
    # run SZ decompression
    subprocess.run([PATH_SZ,'-x','-f','-s',tmp_prefix+'.dat.sz','-1',str(len(in_array))])
    # get reconstruction
    with open(tmp_prefix+'.dat.sz.out','rb') as f:
        recon_array = np.fromfile(f,dtype=np.float32)
    recon_array = np.int16(np.round(recon_array))
    assert np.max(np.abs(recon_array-in_array)) <= maxerror
    # remove temporary files
    os.remove(tmp_prefix+'.dat')
    os.remove(tmp_prefix+'.dat.sz')
    os.remove(tmp_prefix+'.dat.sz.out')
    
    return recon_array, size

def vbz_compressed_size(signal):
    '''
    Perform VBZ compression (maximum compression mode) and return compressed size
    signal: np.array of type np.int16
    Return: compressed size in bytes
    '''
    assert signal.dtype == np.int16
    def compression_options(zigzag, size, zlevel=1, version=0):
        options = ffi.new("CompressionOptions *")
        options.integer_size = size
        options.perform_delta_zig_zag = zigzag
        options.zstd_compression_level = zlevel
        options.vbz_version = version
        return options
    zigzag = np.issubdtype(signal.dtype, np.signedinteger)
    options = compression_options(zigzag, signal.dtype.itemsize, zlevel=22)
    return vbz.compress(signal,options).nbytes

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Input')
    parser.add_argument('--inDir', type=str, required=True, help='directory with input fast5 files (must be singleread fast5s)')
    parser.add_argument('--outDir', type=str, help='directory to store output fast5 files when using lossy compression')
    parser.add_argument('--summaryFile', type=str, required=True, help='file to write the summary of files processed along with the signal lengths and compressed sizes')
    parser.add_argument('--compressor', type=str, required=True, help='compressor to use: VBZ (lossless), LFZip (lossy), SZ (lossy)')
    parser.add_argument('--maxError', type=int, help='maximum tolerable error in signal when using lossy compression')
    args = parser.parse_args()
    # check that compressor is correct
    if args.compressor not in ['VBZ','LFZip','SZ']:
        raise RuntimeError('Incorrect compressor')
    # if lossy compression being used, check that maxError and outDir are specified
    lossy_flag = False
    if args.compressor in ['LFZip','SZ']:
        lossy_flag = True
        if args.outDir is None or args.maxError is None:
            raise RuntimeError('outDir or maxError not specified for lossy compression')

    if lossy_flag:
        # create args.outDir directory if doesn't already exist
        os.makedirs(args.outDir, exist_ok = True)
    randsuf = random.randrange(10000000)

    # go through all fast5 files in inDir and perform relevant operation
    # open summaryFile
    # check if file already exists (if previous run failed, don't rerun the whole thing)
    if os.path.isfile(args.summaryFile):
        with open(args.summaryFile,'r') as f_summary:
            already_done = set([l.rstrip('\n').split('\t')[0] for l in f_summary.readlines()])    
        f_summary = open(args.summaryFile,'a')
    else:
        f_summary = open(args.summaryFile,'w')
        f_summary.write('File\tSignal length\tCompressed Size\n')
        already_done = set([]) 

    for filename in os.listdir(args.inDir):
        if filename.endswith('.fast5'):
            if filename in already_done:
                continue
            filepath = os.path.join(args.inDir,filename)
            raw_array = get_raw_signal_array_from_fast5(filepath)
            raw_array_len = raw_array.size
            if lossy_flag:
                if args.compressor == 'LFZip':
                    new_raw_array,compressed_size = LFZip_compression(raw_array, args.maxError)
                elif args.compressor == 'SZ':
                    new_raw_array,compressed_size = SZ_compression(raw_array, args.maxError)
                new_filepath = os.path.join(args.outDir,filename)
                replace_raw_signal_array_in_fast5(filepath, new_filepath, new_raw_array)
            else:
                compressed_size = vbz_compressed_size(raw_array)
            f_summary.write(filename+'\t'+str(raw_array_len)+'\t'+str(compressed_size)+'\n')
    f_summary.close()
