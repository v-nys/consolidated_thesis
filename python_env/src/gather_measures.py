import ConfigParser
import os

import music21

def time_signature_equality(a, b):
    return a.numerator == b.numerator and a.denominator == b.denominator


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


def create_measure_files(in_folder, out_folder_root):
    r"""
    Given the path the source MusicXML files as `in_folder` and the desired
    output location for subfolders containing extracted rhythms organized
    per time signature as `out_folder_root`, create a MusicXML file for each
    meaningful rhythm.

    This function does not eliminate duplicate rhythms and it does not leave
    out rhythms played by non-guitar instruments, nor does it ignore
    whole-note rests. Such postprocessing is handled by consumer functions.
    """
    # TODO verify whether description is entirely accurate
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
    config = ConfigParser.ConfigParser()
    with open('params.ini') as param_fh:
        config.readfp(param_fh)
    musicxml_dir = config.get('Analysis', 'musicxml_dir')
    rhythm_measures_dir = config.get('Analysis', 'intermediate_rhythm_measures_dir')
    create_measure_files(musicxml_dir, rhythm_measures_dir)
