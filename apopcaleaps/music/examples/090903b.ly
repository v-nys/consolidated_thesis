\version "2.12.1"
Melody = \relative c' {
  \clef treble
  \repeat unfold 4 {
\time 2/4
    e8 d16 e16 c4  |
    d4 f16 d16 c8  |
    g16 b16 b8 g4  |
    c16 b16 c8 e8 g8  |
  }
}
Chords = \chordmode {
  \clef treble
  \repeat unfold 4 {
\time 2/4
    c4 c8 c8:7  |
    f4 f16 f16 f16 f16  |
    g16 g16 g8 r16 r16 r16 g16:7  |
    c8 c8 c16 c16:7 c16:7 c16  |
  }
}
Bass = \relative c, {
  \clef bass
  \repeat unfold 4 {
\time 2/4
    c8 c8 c4  |
    f4 f8 f8  |
    g4 d4  |
    c4 c4  |
  }
}
Drums = \drummode {
  \repeat unfold 4 {
\time 2/4
    bd16 r16 hh16 hh16 sn16 r16 bd16 hh16  |
    bd8 hh16 hh16 sn8 hh16 hh16  |
    bd16 r16 hh8 sn4  |
    bd4 sn8 bd16 hh16  |
  }
}
\score{
  <<
    \new Staff \Melody
    \new Staff \Chords
    \new Staff \Bass
    \new DrumStaff \Drums
  >>
  \midi {}
  \layout {}
}
