\version "2.12.1"
Melody = \relative c'' {
  \tempo 4=100
  \clef treble
  \repeat unfold 4 {
\time 4/4
    c16 e16 c8 e4 c8 a16 g16 g16 f16 r16 g16  |
    f4 ~ f16 b16 c16 c16 a16 r16 a16 c16 f4  |
    g4 c16 g16 e16 a16 g4 c8 g16 f16  |
    g4 c16 a16 r8 e4 c8 e16 g16  |
  }
}
Chords = \chordmode {
  \clef treble
  \repeat unfold 4 {
\time 4/4
    c4 r4 c4 c4  |
    f4 f4 f4 f4  |
    c4 c4 c4:7 c4:7  |
    c4 r4 c4 ~ c4  |
  }
}
Bass = \relative c, {
  \clef "bass_8"
  \repeat unfold 4 {
\time 4/4
    c4 c4 g4 c8 ~ c8  |
    f4 f4 f4 c8 f8  |
    c8 c8 g4 c4 c8 g8  |
    c4 c4 ~ c8 c8 ~ c4  |
  }
}
Drums = \drummode {
  \repeat unfold 4 {
\time 4/4
    cymc4 hh8 bd8 sn4 bd8 hh8  |
    bd8 r8 r8 bd8 r8 r8 hh4  |
    bd4 hh4 sn4 bd4  |
    bd8 hh8 sn4 sn4 sn8 bd8  |
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
