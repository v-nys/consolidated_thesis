import ConfigParser
import os
import pickle

from pykov import maximum_likelihood_probabilities

import sight_reading.synthesis.apopcaleaps_interface

def compose():
    
    my_dir = os.path.dirname(os.path.realpath(__file__))
    runtime_dir = my_dir.replace('src','runtime')
    parameter_path = os.path.join(runtime_dir, 'parameters.ini')

    config = ConfigParser.ConfigParser()
    config.read(parameter_path)
    music_path = config.get('APOPCALEAPS', 'music_folder')

    with open('/home/vincent/Shared/masterproef_moeilijkheid_final/data/pickled_rhythm') as fh:
        rhythm_chain = pickle.load(fh)
        _, P = maximum_likelihood_probabilities(rhythm_chain,lag_time=1, separator='0')
        rhythm_chain = P
    with open('/home/vincent/Shared/masterproef_moeilijkheid_final/data/pickled_melody') as fh:
        melodic_chain = pickle.load(fh)
        _, P = maximum_likelihood_probabilities(melodic_chain,lag_time=1, separator='0')
        melodic_chain = P
    
    sight_reading.synthesis.apopcaleaps_interface.compose(music_path, rhythm_chain, [-5.00, -10.00, -15.00, -20.00], 1, melodic_chain, [-10.00, -20.00, -30.00, -40.00], 1)

if __name__ == '__main__':
    compose()
