r"""
A collection of functions used to interface with David Temperley's programs.
"""


import collections
import ConfigParser
import logging
import math
import os
import re
import subprocess
from subprocess import PIPE


from music21.converter import parse
from music21.midi.translate import streamToMidiFile
from music21.stream import Part, Measure


from .conversion.midi_handling import extract_melody


HARMONY_REGEXP = re.compile(r"""^(?P<whitespace_padding_1>\s*)"""\
                            r"""(?P<start>[0-9]+)"""\
                            r"""(?P<whitespace_padding_2>\s*)"""\
                            r"""(?P<level>(x )+)"""\
                            r"""(\s*)"""\
                            r"""(?P<chord_name>[A-G][#b]?)"""\
                            r""".+$""")
NOTELIST_REGEXP = re.compile(r"""(?P<tag>^Note)"""\
                             r"""(?P<whitespace_padding_1>\s+)"""\
                             r"""(?P<start>[0-9]+)"""\
                             r"""(?P<whitespace_padding_2>\s+)"""\
                             r"""(?P<stop>[0-9]+)"""\
                             r"""(?P<whitespace_padding_3>\s+)"""\
                             r"""(?P<pitch>[0-9]+)$""")



# should remove instances of this section being read in other files
my_dir = os.path.dirname(os.path.realpath(__file__))
runtime_dir = my_dir.replace('src','runtime')
parameter_path = os.path.join(runtime_dir, 'parameters.ini')
config = ConfigParser.ConfigParser()
config.read(parameter_path)
beatlist_path = config.get('Temperley', 'beatlist_path')
melprob_path = config.get('Temperley', 'melprob_path')
notelist_path = config.get('Temperley', 'notelist_path')
harmony_path = config.get('Temperley', 'harmony_path')
key_path = config.get('Temperley', 'key_path')

LOG = logging.getLogger(__name__)
ldebug = lambda x: LOG.debug(x.format(**locals()))
lwarning = lambda x: LOG.warning(x.format(**locals()))


def _read_beatlist(midi_path):
    process_notelist = subprocess.Popen([notelist_path, midi_path], stdout=PIPE)
    notelist = process_notelist.communicate()[0]
    process_beatlist = subprocess.Popen([beatlist_path], stdin=PIPE, stdout=PIPE)
    beatlist = process_beatlist.communicate(notelist)[0]
    return beatlist


def _read_harmony(midi_path):
    beatlist = _read_beatlist(midi_path)
    process_harmony = subprocess.Popen([harmony_path], stdin=PIPE, stdout=PIPE)
    harmony = process_harmony.communicate(beatlist)[0]
    return harmony


def _majority_chord(chords):
    ldebug("Looking for majority chord in {chords}")
    counter = collections.Counter(chords)
    maxima = [c for c in counter if counter[c] == max(counter.values())]
    if not maxima:
        lwarning("List of chord maxima was empty")
    return maxima[-1]  # have to pick one, so...


def _number_of_measures(piece):
    num_measures = None
    for part in piece:
        if isinstance(part, Part):
            return len([m for m in part if isinstance(m, Measure)])


def _duration_of_piece(notelist):
    current_duration = 0
    for line in notelist.split('\n'):
        match = NOTELIST_REGEXP.match(line)
        if match:
            current_duration = max(current_duration, int(match.group('stop')))
    return current_duration


def chord_per_measure(piece, midi_path):
    harmony = _read_harmony(midi_path)
    beatlist = _read_beatlist(midi_path)
    num_measures = _number_of_measures(piece)
    duration = _duration_of_piece(beatlist)
    duration_measure = float(duration) / num_measures # in msec!

    chords = [[]] * num_measures
    for line in harmony.split('\n'):
        line_match = HARMONY_REGEXP.match(line)
        if not line_match:
            continue
        else:
            start = int(line_match.group('start'))
            chord = line_match.group('chord_name')
            measure = int(math.floor(start / duration_measure))
            ldebug("Appending chord {chord} to measure {measure}")
            chords[measure].append(chord)

    ldebug('Chord array: {chords}')
    for i in range(0, len(chords)):
        chords[i] = _majority_chord(chords[i])
    return chords


def key_sequence(midi_path):
    harmony = _read_harmony(midi_path)
    process_key = subprocess.Popen([key_path], stdin=PIPE, stdout=PIPE)
    keys = process_key.communicate(harmony)[0]
    return keys.split()


def likelihood_melody(midi_path, temp_midi_path):
    r"""
    Given the full path to an APOPCALEAPS-generated midi file,
    return Temperley's estimation of the likelihood of the melody.

    #. `midi_path`: path to the midi file whose likelihood will be assessed
    #. `temp_midi_path`: a path where an intermediate file may safely be stored

    **Note:this function cannot be applied to arbitrarily long melodies.
    It should only be used for single measures.**
    """
    piece = parse(midi_path)
    melody = extract_melody(piece)
    midi_f = streamToMidiFile(melody)
    midi_f.open(temp_midi_path, 'wb')
    midi_f.write()
    midi_f.close()
    process_notelist = subprocess.Popen([notelist_path, temp_midi_path], stdout=PIPE)
    notelist = process_notelist.communicate()[0]
    process_melprob = subprocess.Popen([melprob_path], stdin=PIPE, stdout=PIPE)
    likelihood = float(process_melprob.communicate(notelist)[0])
    return likelihood
