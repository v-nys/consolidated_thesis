import argparse
import ConfigParser
import logging
import os
import pickle

import music21
from music21.converter import parse as parse21
import pykov


logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.INFO)  # acceptable because this is just a script


def _silent_measure(measure):
    r"""
    Given a Music21 measure, determine whether it is completely silent.
    """
    # note that this function takes simplified rhythm measures as its input
    # therefore, it only checks for notes as elements with sound
    for element in measure:
        if isinstance(element, music21.note.Note):
            return False
    return True


def _txt2pickle_chain(txt_path, pickle_path):
    r"""
    Given a chain that is specified in `txt_path`, make a pickle of its Pykov
    representation and store it in `pickle_path`.
    
    The result will be read much more quickly than a text file.
    """
    chain = pykov.readtrj(txt_path)
    pickle.dump(chain, pickle_path)


def _create_chain(sig, in_root, out_path):
    r"""
    Transform a collection of single-measure rhythms into a textual
    representation of Markov chain input.

    `sig` defines the time signature for the rhythm model to be represented.
    `in_root` is the root folder for rhythm measures, containing subfolders
    of which at least one should be named `sig`.
    `out_path` determines the desired output location for the plain text chain.

    **Note that `out_path` is not itself the output location, because _`sig`
    will be appended to it.**

    **Also note that these chains ignore empty measures, as those do not
    represent meaningful rhythms.**
    """
    sep = os.sep
    in_folder = '{in_root}{sep}{sig}'.format(**locals()) # specific to sig
    with open('{out_path}_{sig}'.format(**locals()), mode='w') as fh:
        for filename in os.listdir(in_folder):
            logger.debug("Adding to text chain: {filename}".format(**locals()))
            measure_path = '{in_folder}{sep}{filename}'.format(**locals())
            # technically we have a piece, so extract measure
            measure = parse21(measure_path)[1][1]
            if not _silent_measure(measure):
                _append_txt_chain(measure, fh)


def _append_txt_chain(measure, fh):
    r"""
    Given a rhythm measure `measure` and a write-mode file handle `fh`,
    append the values describing the rhythm of `measure` to the file.
    """
    # values are 3-tuples: offset, quarterLength and sound
    values = [(0, None, None)]
    for element in measure:  # Check types! Also contains TimeSig, Clef,...
        if isinstance(element, music21.note.Note):
            logger.debug("Found a note")
            values.append((str(element.offset + 1),
                          str(element.quarterLength),
                          True))
        elif isinstance(element, music21.note.Rest):
            logger.debug("Found a rest")
            values.append((str(element.offset + 1),
                          str(element.quarterLength),
                          False))
                              
    logger.info("Writing out {num} values".format(num=len(values)))
    for value in values:
        fh.write(str(value) + '\n')
    fh.write('END_OF_MEASURE' + '\n')


if __name__=='__main__':
    config = ConfigParser.ConfigParser()
    # FIXME now this only works when running from same folder
    with open('params.ini') as param_fh:
        config.readfp(param_fh)
    chain_txt_path = config.get('Analysis', 'intermediate_rhythm_unified')
    rhythm_measures_dir = config.get('Analysis', 'intermediate_rhythm_measures_dir')

    _create_chain('common', rhythm_measures_dir, chain_txt_path)
    #_txt2pickle_chain(common_chain_txt_path)
