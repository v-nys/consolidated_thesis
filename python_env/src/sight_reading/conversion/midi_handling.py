r"""
A collection of functions to help manipulate midi files.

These functions are specifically meant to work with the type of midi produced
by APOPCALEAPS and Lilypond. They are not meant to work with general midi
files.
"""


import music21
from music21.note import Note


def extract_melody(piece):
    r"""
    Given a .midi file produced by APOPCALEAPS and parsed by music21,
    return the part which represents the melody.
    """
    sums_counts = [(0.0, 0) for part in piece]
    for (part_num, part) in enumerate(piece):
        for elem in part:
            if isinstance(elem, Note):
                (total_octaves, count) = sums_counts[part_num]
                changed = (total_octaves + elem.octave, count + 1)
                sums_counts[part_num] = changed
    # now return index of part with highest average
    for (entry_num, (total_octaves, count)) in enumerate(sums_counts):
        if not count:
            sums_counts[entry_num] = 0
        else:
            sums_counts[entry_num] = total_octaves / count
    max_avg = max(sums_counts)
    return piece[sums_counts.index(max_avg)]

    
def extract_melody_measures(piece, measure_numbers):
    r"""
    Given a .midi file produced by APOPCALEAPS and parsed by music21,
    yield a stream representing each specified measure.

    #. `piece`: a Music21 stream from which a melody part may be extracted
    #. `measure_numbers`: a sequence containing (1-indexed) measure indices

    This assumes the piece is written in common time.
    Measures returned are meant to be somewhat self-sufficient, and thus
    contain a time signature and an indication of tempo.

    Note that elements that began in a previous measure are not taken into
    account. This is deliberate: they make the previous measure more
    difficult.
    """
    melody_part = extract_melody(piece)
    # APOCALEAPS and music21 together do not produce `Measure` objects!
    # Therefore, look at the offsets to place elements into measures.
    measures = [music21.stream.Measure() for measure in measure_numbers]
    for measure in measures:
        measure.append(music21.tempo.MetronomeMark('andantino', 80))
        measure.append(music21.meter.TimeSignature('4/4'))
    for element in melody_part:
        element_offset = element.offset
        measure_num = (element_offset // 4) + 1  # count of 4.5 has offset 3.5
        if measure_num in measure_numbers:
            measure = measures[measure_numbers.index(measure_num)]
            measure.append(element)
            # next adjustment may happen automatically...
            measure[-1].offset = element_offset % 4.0
    for measure in measures:
        yield measure
