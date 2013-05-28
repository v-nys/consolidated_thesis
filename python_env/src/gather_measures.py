import os

import music21

def time_signature_equality(a, b):
    return a.numerator == b.numerator and a.denominator == b.denominator


def measure_equality(a, b):
    """Determine whether two simplified measures are equal. This is required
    because music21 does not have an implementation for measure equality
    (creating two new measures and checking for equality gives False as a
    result)."""
    if len(a) != len(b):
        return False
    else:
        for index in range(0, len(a)):
            if(isinstance(a[index], music21.meter.TimeSignature) and
               isinstance(b[index], music21.meter.TimeSignature) and
               time_signature_equality(a[index], b[index])):
                   continue
            if a[index] != b[index]:
                return False
    return True


def rhythms(song_path, sig):
    """Traverse the file whose handle is supplied and return a collection of
    usable rhythms.
    
    This method will look at all the rhythms that are in the piece, so not just
    the guitar voice. At the moment, it assumes input is strictly in common
    time without a pickup measure. It will also discard ghost notes. The result
    may contain duplicates, which will need to be filtered out later on."""
    if sig == '128':
        sig = music21.meter.TimeSignature('12/8')
    elif sig == 'common':
        sig = music21.meter.TimeSignature('4/4')
    else:
        sig = None
    assert sig is not None
    discovered_rhythms = set()
    song_score = music21.converter.parse(song_path)
    for part in song_score.getElementsByClass(music21.stream.Part):
        for measure in part.getElementsByClass(music21.stream.Measure):
            measure_replacement = music21.stream.Measure()
            measure_replacement.timeSignature = sig
            for index in range(0, len(measure)):
                if(isinstance(measure[index], music21.note.Note) or
                   isinstance(measure[index], music21.chord.Chord)):
                    sound_replacement = music21.note.Note('a4')
                    sound_replacement.duration = measure[index].duration
                    measure_replacement.append(sound_replacement)
                    measure_contains_notes = True
                else:
                    measure_replacement.append(measure[index])
            measure_replacement.offset = 0
            discovered_rhythms.add(measure_replacement)
    return discovered_rhythms

def time_signature(path):
    """Return the time signature of a piece.
    
    The known types of time signature are "common", "128" and "unknown".
    If a piece contains measures with different signatures, the result is
    "unknown"."""
    song_score = music21.converter.parse(path)
    # note: __equals__ does not behave as expected for TimeSignature!
    # use time_signature_equality instead.
    common_time = music21.meter.TimeSignature('4/4')
    twelve_eighths = music21.meter.TimeSignature('12/8')
    guess = None
    part = song_score.getElementsByClass(music21.stream.Part)[0]
    for measure in part.getElementsByClass(music21.stream.Measure):
        if measure.timeSignature:
            if time_signature_equality(measure.timeSignature, common_time):
                if(guess is None or time_signature_equality(measure.timeSignature, guess)):
                    guess = common_time
                else:
                    return 'unknown'
            elif time_signature_equality(measure.timeSignature, twelve_eighths):
                if(guess is None or time_signature_equality(measure.timeSignature, guess)):
                    guess = twelve_eighths
                else:
                    return 'unknown'
        else:
            continue # if the signature is unchanged, no problem
    if guess is common_time:
        return 'common'
    elif guess is twelve_eighths:
        return '128'
    else:
        return 'unknown'

def create_measure_files():

    # all input is in the same folder, but separate rhythms by time signature
    in_folder = '../../../data/inputs/musicXML corpus'
    out_folder_root = '../../../data/intermediate_results/rhythm_measures'
    
    # for each file, extract the rhythms inside each measure
    file_counter = 1
    for filename in os.listdir(in_folder):
        measure_set = set()
        counter = 1
        path = in_folder + os.sep + filename
        sig = time_signature(path) # common, 128 or unknown
        if sig == 'unknown':
            file_counter += 1
            continue
        out_folder = out_folder_root + os.sep + sig
        
        song_rhythms = rhythms(path, sig)
        for rhythm in song_rhythms:
            measure_set.add(rhythm)
        for measure in measure_set:
            measure.write(fmt='musicxml', 
                          fp=out_folder + os.sep + str(file_counter) + '_' + str(counter) + '.xml')
            counter += 1
        file_counter += 1

if __name__ == '__main__':
    create_measure_files()
