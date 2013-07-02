\version "2.12.1"
Melody = {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    c'8 g8 fis8 g8  |
    b8 g16 a16 a4  |
    b4 b4  |
    ais4 a4  |
    g8 a8 g4  |
    b4 g8 a8  |
    b4 d'4  |
    c'4 g4  |
  }
}
Chords = \chordmode {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    r8 c8 r8 c8  |
    r8 d8:m r8 d8:m7  |
    r8 d8:m7 r8 d8:m  |
    r8 f8 r8 f8  |
    r8 c8 r8 c8  |
    r8 g8 r8 g8:7  |
    r4 r8 d8:m  |
    r4 r4  |
  }
}
Bass = {
  \tempo 4=120
  \clef "bass_8"
  \repeat unfold 4 {
\time 2/4
    c,4 g,4  |
    b4 b,4  |
    e,8 e,8 d,4  |
    a,,8 f,8 c8 f,8  |
    f,4 g,4  |
    g,8 r8 g4  |
    b,8 d8 b,4  |
    g,4 c,4  |
  }
}
Drums = \drummode {
  \tempo 4=120
  \repeat unfold 4 {
\time 2/4
    bd16 hh16 hh16 bd16 sn4  |
    bd16 r16 hh16 sn16 sn4  |
    bd4 sn16 hh16 hh8  |
    bd16 sn16 hh8 sn4  |
    bd16 r16 hh8 sn4  |
    bd8 bd8 sn4  |
    bd4 sn16 r16 hh16 cymc16  |
    bd4 cymc4  |
  }
}
\score{
  <<
    \new Staff \with {midiInstrument = #"soprano sax"} \Melody
    \new Staff \with {midiInstrument = #"electric guitar (jazz)"} \Chords
    \new Staff \with {midiInstrument = #"electric bass (pick)"} \Bass
    \new DrumStaff \Drums
  >>
  \midi {}
}
