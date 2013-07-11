import ConfigParser
import os

import sight_reading.synthesis.apopcaleaps_interface

if __name__ == '__main__':
    
    my_dir = os.path.dirname(os.path.realpath(__file__))
    runtime_dir = my_dir.replace('src','runtime')
    parameter_path = os.path.join(runtime_dir, 'parameters.ini')

    config = ConfigParser.ConfigParser()
    config.read(parameter_path)
    music_path = config.get('APOPCALEAPS', 'music_folder')
    
    sight_reading.synthesis.apopcaleaps_interface.compose(music_path)
