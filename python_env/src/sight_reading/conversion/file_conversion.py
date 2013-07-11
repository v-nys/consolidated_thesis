import subprocess

def midi2musicXML(midi_path, xml_desired_path):
    r"""
    Take an existing Midi file and transform it into a MusicXML file.
    
    **Platform dependent: this function uses MuseScore to do the heavy
    lifting and it calls it as you would call it from the UNIX command
    line. It is probably necessary to add a platform condition to make
    this work under Windows.**
    """
    subprocess.call(['musescore', midi_path, '-o', xml_desired_path])
