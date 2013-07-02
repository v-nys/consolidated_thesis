\version "2.12.1"
Melody = \relative c'' {
  \tempo 4=80
  \clef treble
  \repeat unfold 2 {
\time 4/4
    e16 d16 g16 r16 e8 c8 f8 c8 g4  |
    a16 b16 a16 b16 e8 a16 e16 e4 e4  |
    c8 a8 f4 c4 f16 e16 a16 b16  |
    a16 d16 a8 ~ a4 c4 a4  |
  }
}
Chords = \chordmode {
  \clef treble
  \repeat unfold 2 {
\time 4/4
    c4 c4 c4:7 c4  |
    a4:m r4 a4:m7 r4  |
    f4 r4 f4 f4  |
    a4:m a4:m a4:m ~ a4:m  |
  }
}
Bass = \relative c, {
  \clef "bass_8"
  \repeat unfold 2 {
\time 4/4
    c4 c4 g4 g8 c8  |
    a4 a4 a8 a8 a8 e8  |
    f8 f8 f4 c4 f4  |
    a4 a8 a8 a4 a4  |
  }
}
Drums = \drummode {
  \repeat unfold 2 {
\time 4/4
    bd8 hh8 r4 sn8 r8 hh8 sn8  |
    bd4 hh4 sn4 bd8 r8  |
    bd4 bd4 sn4 hh4  |
    cymc8 r8 hh4 sn4 bd4  |
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
