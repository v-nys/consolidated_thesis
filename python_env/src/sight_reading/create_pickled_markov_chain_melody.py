import argparse
import logging
import logging.config
import os
import pickle

from os.path import abspath, dirname

import music21
from music21.converter import parse
from music21.interval import notesToChromatic
from music21.key import Key, convertKeyStringToMusic21KeyString 
from music21.midi.translate import streamToMidiFile
from music21.note import Note, Rest
from music21.stream import Part, Measure
import pykov


import temperley


HERE = abspath(dirname(__file__))
# don't ask for an argument for these - they're temp files
TEXT_CHAIN_NAME = 'text_chain_melody'
TEMP_MIDI_NAME = 'for_analysis.midi'

runtime_path = HERE.replace('src', 'runtime')
logfile_path = os.path.join(runtime_path, 'logging_chains_melody.conf')
logging.config.fileConfig(logfile_path, defaults={'this_dir': runtime_path})
LOG = logging.getLogger(__name__)


def read_and_pickle_chain(output_dir, name='pickled_melody'):
    r"""
    Read in a Markov chain specified in textual form and pickle it for quick
    re-initialization.
    """
    chain = pykov.readtrj(os.path.join(output_dir, TEXT_CHAIN_NAME))
    with open(os.path.join(output_dir, name), mode='w') as fh:
        pickle.dump(chain, fh)


def create_chain(data_path, output_dir, mode):
    r"""
    Create the textual form of a Markov chain by writing each element of
    the generated sequence to a text file.
    """
    out_path = os.path.join(output_dir, TEXT_CHAIN_NAME)
    with open(out_path, mode='w') as fh:
        for sequence in sequences(data_path, output_dir, mode):
            fh.write('BEGINNING_OF_SEQUENCE\n')
            for data_tuple in sequence:
                fh.write(str(data_tuple) + '\n')
            fh.write('END_OF_SEQUENCE\n')


def sequences(data_path, output_path, mode):
    r"""
    Yield all melodic chain sequences that can be derived from the input data.
    For each uninterrupted run of notes, a sequence is yielded. 

    A sequence is a Python list of data tuples.
    The nature of the elements depends on the `mode` argument.
    """
    if mode == 'Relative':
        for sequence in relative_sequences(data_path):
            yield sequence
    elif mode == 'Mixed':
        for sequence in mixed_sequences(data_path, output_path):
            yield sequence
    else:
        assert False


def relative_sequences(data_path):
    for (number, filename) in enumerate(os.listdir(data_path), start=1):
        piece = parse(os.path.join(data_path, filename))
        LOG.debug("Finding relative sequences in piece {number}: {filename}.".format(**locals()))
        instrument = lambda x: x.getInstrument().instrumentName.lower()
        guitar_parts = (e for e in piece if isinstance (e, Part) and \
                                         ('guitar' in instrument(e) or \
                                         'gtr' in instrument(e)) and not \
                                         'bass' in instrument(e))
        for part in guitar_parts:
            current_sequence = None
            last_note = None
            for measure in (elem for elem in part if isinstance(elem, Measure)):
                for element in measure:  # can be note, rest, chord, timesig,...
                    if isinstance(element, Note):
                        if not last_note:
                            current_sequence = [(0,0,0)]
                        else:
                            interval = notesToChromatic(last_note, element)
                            entry = current_sequence[-1][1:3] + (interval.semitones,)
                            current_sequence.append(entry)
                        last_note = element
                    elif isinstance(element, Rest) and element.quarterLength < 4:
                        pass  # ignore short rests
                    elif current_sequence:
                        yield current_sequence
                        current_sequence = None
                        last_note = None


def mixed_sequences(data_path, output_path):
    for (number, filename) in enumerate(os.listdir(data_path), start=1):
        full_path = os.path.join(data_path, filename)
        LOG.debug("Finding mixed sequences in piece {number}: {filename}.".format(**locals()))
        piece = parse(full_path)
        temp_abspath = os.path.join(output_path, TEMP_MIDI_NAME)
        piece.write('midi', temp_abspath)
        chord_per_measure = temperley.chord_per_measure(piece, temp_abspath)
        keys = temperley.key_sequence(temp_abspath)
        if len(set(keys)) > 1:
            continue  # more than one key in piece is complicated...
        else:
            key_string = convertKeyStringToMusic21KeyString(keys[0].replace('b','-'))
            key = Key()
            key_pitch = key.getPitches()[0]
        instrument = lambda x: x.getInstrument().instrumentName.lower()
        guitar_parts = (e for e in piece if isinstance (e, Part) and \
                                         ('guitar' in instrument(e) or \
                                         'gtr' in instrument(e)) and not \
                                         'bass' in instrument(e))
        for part in guitar_parts:
            current_sequence = None
            last_note = None
            measures = [elem for elem in part if isinstance(elem, Measure)]
            if len(chord_per_measure) != len(measures):
                continue
            for chord, measure in zip(chord_per_measure, measures):
                chord_pitch = music21.pitch.Pitch(convertKeyStringToMusic21KeyString(chord))
                for element in measure:
                    if isinstance(element, Note):
                        if not last_note:
                            current_sequence = [(0, 0, notesToChromatic(key_pitch, element).semitones, key.mode, notesToChromatic(key_pitch, chord_pitch).semitones)]
                        else:
                            interval = notesToChromatic(last_note, element)
                            entry = (current_sequence[-1][1], interval.semitones, notesToChromatic(key_pitch, element).semitones, key.mode, notesToChromatic(key_pitch, chord_pitch).semitones)
                            current_sequence.append(entry)
                        last_note = element
                    elif isinstance(element, Rest) and element.quarterLength < 4:
                        pass
                    elif current_sequence:
                        yield current_sequence
                        current_sequence = None
                        last_note = None
    

if __name__=='__main__':

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('data_path', help='path of folder containing training corpus in musicxml format')
    arg_parser.add_argument('output_path', help='folder in which to store the "pickled_melody" output file')
    arg_parser.add_argument('mode', help='the type of analysis to perform ("Relative" or "Mixed")')
    args = arg_parser.parse_args()

    create_chain(args.data_path, args.output_path, args.mode)
    read_and_pickle_chain(args.output_path, 'pickled_melody_{mode}'.format(mode=args.mode))
