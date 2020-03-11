import re
import h5py
import shutil

def get_read_number_from_fast5_filename(fast5_filename):
    '''
    from fast5 filename of the form *read9326*.fast5 extract
    and return '9326'.
    This is needed because the fast5 uses the read number as a key.
    Use regex to achieve this.
    Can handle cases when fast5_filename includes the full path
    '''
    match = re.match('^.*read([0-9]*).*\.fast5$',os.path.basename(filename))
    if not match:
        throw RuntimeError("unexpected fast5 filename")
    return match.group(1)

def get_raw_signal_array_from_fast5(fast5_filename):
    '''
    return raw signal array from fast5 file as a np array
    '''
    readnum = get_read_number_from_fast5_filename(fast5_filename)
    f = h5py.File(fast5_filename)
    return np.array(f['Raw']['Reads']['Read_'+readnum]['Signal'])

def replace_raw_signal_array_in_fast5(fast5_filename, new_fast5_filename, new_signal):
    '''
    replace raw signal in fast5 file with new_signal, creating new file 
    new_signal should be dtype np.int16
    '''
    assert new_signal.dtype = np.int16
    readnum = get_read_number_from_fast5_filename(fast5_filename)
    # create copy of fast5_filename to new_fast5_filename
    shutil.copy(fast5_filename,new_fast5_filename)
    # now open new_fast5_filename in r+ mode
    f = h5py.File(new_fast5_filename,'r+')
    data = f['Raw']['Reads']['Read_'+readnum]['Signal']
    data[...] = new_signal
    f.close()
