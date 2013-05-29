import argparse
import ConfigParser
import os
import pickle

import music21
import pykov

def read_and_pickle_chain(chain_path):
    chain = pykov.readtrj(chain_path)
    pickle.dump(chain, '../../../data/intermediate_results/pickle_of_' + chain_path)


def create_chain_for_signature(sig, in_folder, out_folder):
    # FIXME overlap between sig and folder
    in_folder = '../../../data/intermediate_results/rhythm measures' + '/' + sig
    out_folder = '../../../data'
    
    for filename in os.listdir(in_folder):
        measure = music21.converter.parse(in_folder + os.sep + filename)[1][1]
        values = [(0, None)]
        for index in range(1, len(measure)):
            print(str(measure[index]))
            if isinstance(measure[index], music21.note.Note):
                print("Found a note")
                note = measure[index]
                values.append((str(note.offset + 1),
                              str(note.quarterLength),
                              True))
            elif isinstance(measure[index], music21.note.Rest):
                print("Found a rest")
                rest = measure[index]
                values.append((str(rest.offset + 1),
                              str(rest.quarterLength),
                              False))
                              
    with open(out_folder + os.sep + 'rhythm_chain_' + sig, mode='w') as fh:
         for value in values:
            fh.write(str(value) + '\n')
        fh.write('END_OF_MEASURE' + '\n')

def create_markov_chain_file(sig):
    create_chain_for_signature('common')
    create_chain_for_signature('128')

if __name__=='__main__':
    config = ConfigParser.ConfigParser()
    with open('params.ini') as param_fh:
        config.readfp(param_fh)

    create_markov_chain_file()
    read_and_pickle_chain('../../../data/rhythm_chain_common')
    read_and_pickle_chain('../../../data/rhythm_chain_128')
