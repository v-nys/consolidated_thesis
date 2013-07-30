import argparse
import ConfigParser
import os
import shutil

from sight_reading.synthesis.apopcaleaps_interface import compose_samples

if __name__ == '__main__':

    my_dir = os.path.dirname(os.path.realpath(__file__))
    runtime_dir = my_dir.replace('src','runtime')
    parameter_path = os.path.join(runtime_dir, 'parameters.ini')

    config = ConfigParser.ConfigParser()
    config.read(parameter_path)
    gui_path = config.get('APOPCALEAPS', 'music_folder')

    num_samples = 2000
    compose_samples(gui_path, num_samples)
