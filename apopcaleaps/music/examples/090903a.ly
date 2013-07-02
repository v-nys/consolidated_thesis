\version "2.12.1"
Melody = \relative c' {
  \clef treble
  \repeat unfold 3 {
\time 2/4
    c4 f4  |
    e16 c16 a8 a8 e16 a16  |
    f16 d16 f8 f4  |
    f4 a16 g16 c16 d16  |
    a16 c16 a8 a8 e16 b16  |
    a16 f16 f16 d16 f8 a16 c16  |
    e8 g8 g4  |
    d4 b4  |
  }
}
Bass = \relative c, {
  \clef bass
  \repeat unfold 3 {
\time 2/4
    c4 g4  |
    a4 a16 b16 a16 e16  |
    f4 f4  |
    f16 g16 f8 f4  |
    a4 a8 a8  |
    d4 d4  |
    e4 e8 e16 b16  |
    g8 g16 d16 g8 g8  |
  }
}
Drums = \drummode {
  \repeat unfold 3 {
\time 2/4
    bd16 hh16 bd16 sn16 cb4  |
    bd4 cb4  |
    bd8 hh16 hh16 sn16 r16 cb16 hh16  |
    bd4 sn4  |
    bd16 r16 hh16 hh16 sn4  |
    bd16 hh16 hh16 hh16 sn16 r16 hh16 bd16  |
    bd16 sn16 hh16 r16 sn16 hh16 hh16 bd16  |
    bd8 hh8 cb16 hh16 bd16 hh16  |
  }
}
\score{
  <<
    \new Staff \Melody
    \new Staff \Bass
    \new DrumStaff \Drums
  >>
  \midi {}
  \layout {}
}
