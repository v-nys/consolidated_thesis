\version "2.12.1"
Melody = \relative c' {
  \clef treble
  \repeat unfold 4 {
\time 2/4
    c16 d16 e8 g4  |
    b4 g16 c16 b16 d16  |
    f16 g16 a16 c16 f8 c16 e16  |
    d16 a16 d16 c16 a4  |
  }
}
Chords = \chordmode {
  \clef treble
  \repeat unfold 4 {
\time 2/4
    c4 c16 c16 c8:7  |
    e8:m e8:m e4:m  |
    f16 f16 f8 r4  |
    d4:m d4:m  |
  }
}
Bass = \relative c, {
  \clef bass
  \repeat unfold 4 {
\time 2/4
    c4 g4  |
    e8 e8 e4  |
    f8 f16 f16 f4  |
    d4 d4  |
  }
}
Drums = \drummode {
  \repeat unfold 4 {
\time 2/4
    bd16 hh16 cb16 r16 sn16 hh16 hh8  |
    bd16 r16 hh16 r16 sn16 hh16 hh8  |
    bd4 sn16 r16 hh16 hh16  |
    bd16 r16 bd8 sn4  |
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
