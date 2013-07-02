\version "2.12.1"
Melody = {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    
\override NoteHead #'color = #blue
d'4 
\override NoteHead #'color = #black
r8 
\override NoteHead #'color = #darkyellow
b'16 
\override NoteHead #'color = #black
c''16  |
    
\override NoteHead #'color = #darkblue
d''8 
\override NoteHead #'color = #black
r8 
\override NoteHead #'color = #blue
dis''16 
\override NoteHead #'color = #blue
c''16 
\override NoteHead #'color = #darkblue
d''8  |
    
\override NoteHead #'color = #darkblue
c''4 
\override NoteHead #'color = #darkblue
c''4  |
    
\override NoteHead #'color = #darkblue
a'4 
\override NoteHead #'color = #darkblue
f'4  |
    
\override NoteHead #'color = #black
r16 
\override NoteHead #'color = #blue
dis'16 
\override NoteHead #'color = #black
r16 
\override NoteHead #'color = #darkblue
c''16 
\override NoteHead #'color = #darkblue
c''4  |
    
\override NoteHead #'color = #black
r4 
\override NoteHead #'color = #blue
c''16 
\override NoteHead #'color = #darkyellow
a'16 
\override NoteHead #'color = #darkyellow
a'16 
\override NoteHead #'color = #darkblue
b'16  |
    
\override NoteHead #'color = #blue
dis''16 
\override NoteHead #'color = #darkblue
e''16 
\override NoteHead #'color = #darkblue
e''8 
\override NoteHead #'color = #darkblue
c''4  |
    
\override NoteHead #'color = #blue
d''4 
\override NoteHead #'color = #darkblue
e''8 
\override NoteHead #'color = #blue
d''16 
\override NoteHead #'color = #black
c''16  |
  }
}
Chords = \chordmode {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    r8 c8 r8 c8  |
    r8 g8:7 r8 g8  |
    r8 a8:m7 r8 a8:m  |
    r8 d8:m r8 d8:m7  |
    r4 r8 f8  |
    r8 g8:7 r8 g8  |
    r8 a8:m7 r8 a8:m7  |
    r8 r8 r8 r8  |
  }
}
Bass = {
  \tempo 4=120
  \clef "bass_8"
  \repeat unfold 4 {
\time 2/4
    
\override NoteHead #'color = #black
c,8 
\override NoteHead #'color = #darkblue
g,8 
\override NoteHead #'color = #black
c,8 
\override NoteHead #'color = #darkyellow
b,8  |
    
\override NoteHead #'color = #darkblue
b,4 
\override NoteHead #'color = #darkblue
b,4  |
    
\override NoteHead #'color = #black
a,,4 
\override NoteHead #'color = #black
a,4  |
    
\override NoteHead #'color = #black
d,4 
\override NoteHead #'color = #darkblue
f,4  |
    
\override NoteHead #'color = #black
f4 
\override NoteHead #'color = #darkblue
c4  |
    
\override NoteHead #'color = #black
g,4 
\override NoteHead #'color = #darkblue
b,4  |
    
\override NoteHead #'color = #black
a,,4 
\override NoteHead #'color = #darkblue
e,4  |
    
\override NoteHead #'color = #black
c4 
\override NoteHead #'color = #black
c4  |
  }
}
Drums = \drummode {
  \tempo 4=120
  \repeat unfold 4 {
\time 2/4
    bd4 sn8 bd8  |
    bd8 hh8 sn16 r16 sn8  |
    bd4 sn8 bd8  |
    bd8 hh8 sn8 sn16 sn16  |
    bd4 hh4  |
    bd4 sn4  |
    bd4 sn4  |
    bd4 bd8 bd16 bd16  |
  }
}
\score{
  <<
    \new Staff \with {midiInstrument = #"soprano sax"} \Melody
    \new Staff \with {midiInstrument = #"electric guitar (jazz)"} \Chords
    \new Staff \with {midiInstrument = #"electric bass (pick)"} \Bass
    \new DrumStaff \Drums
  >>
  \layout {}
  \midi {}
}
