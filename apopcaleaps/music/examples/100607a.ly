\version "2.12.1"
Melody = {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    c'4 r4  |
    b'8 g'16 a'16 g'4  |
    c''4 a'8 e'8  |
    g'4 g'4  |
    a'4 f'4  |
    g'8 g'8 a'8 g'8  |
    d'8 e'8 r16 r16 f'8  |
    e'4 c'4  |
  }
}
Chords = \chordmode {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    r8 c8 r8 c8  |
    r8 g8 r8 g8  |
    r8 f8 r8 f8  |
    r8 c8 r4  |
    r8 f8 f8 f8  |
    r8 g8 r8 g8  |
    r8 d8:m r4  |
    c4 r4  |
  }
}
Bass = {
  \tempo 4=120
  \clef "bass_8"
  \repeat unfold 4 {
\time 2/4
    c,4 g,4  |
    g,4 g,,8 f,8  |
    f8 c,8 c,4  |
    c8 r8 c4  |
    f,4 c4  |
    g,4 d,8 f8  |
    d8 d8 a,4  |
    g,,4 c,4  |
  }
}
Drums = \drummode {
  \tempo 4=120
  \repeat unfold 4 {
\time 2/4
    bd8 hh8 sn4  |
    bd4 sn8 hh8  |
    bd8 hh16 sn16 sn4  |
    bd4 sn16 hh16 hh16 sn16  |
    bd4 sn8 hh8  |
    bd4 sn16 hh16 hh8  |
    bd4 sn16 hh16 hh8  |
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
