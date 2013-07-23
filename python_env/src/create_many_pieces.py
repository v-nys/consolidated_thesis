import argparse
import ConfigParser
import os
import shutil

from compose import compose

if __name__ == '__main__':

    my_dir = os.path.dirname(os.path.realpath(__file__))
    runtime_dir = my_dir.replace('src','runtime')
    parameter_path = os.path.join(runtime_dir, 'parameters.ini')

    config = ConfigParser.ConfigParser()
    config.read(parameter_path)
    gui_path = config.get('APOPCALEAPS', 'gui_folder')
    sample_corpus_path = config.get('APOPCALEAPS', 'sample_corpus_folder')

    for i in range(1, 2001):
        destination = os.path.join(sample_corpus_path, str(i) + '.midi')
        compose()
        shutil.copy(os.path.join(gui_path, 'temp.midi'), destination) 
