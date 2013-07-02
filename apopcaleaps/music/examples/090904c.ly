\version "2.12.1"
Melody = \relative c'' {
  \tempo 4=100
  \clef treble
  \repeat unfold 2 {
\time 4/4
    g16 d16 r16 c16 c4 ~ c8 c16 r16 c8 e8  |
    g4 g8 g16 ~ g16 g4 ~ g4  |
    c16 g16 a16 a16 ~ a16 c16 ~ c16 r16 a4 e16 d16 a16 g16  |
    f16 g16 f16 c16 ~ c16 r16 c16 c16 f4 c4  |
  }
}
Chords = \chordmode {
  \clef treble
  \repeat unfold 2 {
\time 4/4
    c4 ~ c4 c4 c4  |
    g4 g4 g4 g4  |
    r4 a4:m a4:m7 a4:m  |
    f4 f4 ~ f4 f4  |
  }
}
Bass = \relative c, {
  \clef "bass_8"
  \repeat unfold 2 {
\time 4/4
    g4 g4 c4 c8 c8  |
    g4 g4 b4 g8 b8  |
    a8 a8 a4 a8 ~ a8 a8 a8  |
    f4 f4 ~ f4 ~ f4  |
  }
}
Drums = \drummode {
  \repeat unfold 2 {
\time 4/4
    cymc8 hh8 hh8 r8 sn4 hh8 hh8  |
    cymc8 hh8 hh8 r8 sn8 r8 bd4  |
    bd8 r8 bd4 sn8 r8 bd4  |
    bd4 sn8 r8 sn8 r8 sn4  |
  }
}
\score{
  <<
    \new Staff \with {midiInstrument = #"soprano sax"} \Melody
    \new Staff \with {midiInstrument = #"acoustic guitar (steel)"} \Chords
    \new Staff \with {midiInstrument = #"baritone sax"} \Bass
    \new DrumStaff \Drums
  >>
  \midi {}
  \layout {}
}
