\version "2.12.1"
Melody = {
  \tempo 4=110
  \clef treble
  \repeat unfold 4 {
\time 2/4
    g'4 e'4  |
    c'8 ~ c'8 a4  |
    a16 d'16 e'8 e'4  |
    f'4 ~ f'4  |
    e'4 e'8 a'8  |
    b'4 e''4  |
    a''8 e''8 c''4  |
    a'8 ~ a'8 e'4  |
    a'4 e'4  |
    a'4 d''4  |
    f''4 d''4  |
    r4 a'4  |
    c''4 c''4  |
    a'8 c''8 r4  |
    g''4 r8 f'16 a'16  |
    r4 r4  |
  }
}
Chords = \chordmode {
  \tempo 4=110
  \clef treble
  \repeat unfold 4 {
\time 2/4
    r8 c8 r4  |
    r8 f8 r8 f8:7  |
    r8 a8:m7 r8 a8:m  |
    r8 f8 r8 f8  |
    r4 a8:m a8:m  |
    r8 e8:m r8 e8:m  |
    r8 a8:m r8 a8:m  |
    r8 a8:m r8 a8:m  |
    a8:m a8:m r8 a8:m  |
    r8 d8:m r8 d8:m  |
    r8 d8:m r8 d8:m  |
    r8 f8 f8 r8  |
    r8 a8:m r8 a8:m  |
    f8 f8 r8 f8  |
    r4 c8 c8:7  |
    r4 r4  |
  }
}
Bass = {
  \tempo 4=110
  \clef "bass_8"
  \repeat unfold 4 {
\time 2/4
    c,4 g,4  |
    a,4 r4  |
    a,4 a,8 e,8  |
    f,8 r8 a,,8 r8  |
    a,4 c4  |
    g,8 b,8 b,,4  |
    a,,4 c,8 e,8  |
    a,,4 a,,8 a,,8  |
    a,,8 a,,8 a,4  |
    d,4 d,8 c,8  |
    d4 a,4  |
    r4 c4  |
    a4 a,4  |
    f,4 a,4  |
    r4 c,4  |
    c4 c4  |
  }
}
Drums = \drummode {
  \tempo 4=110
  \repeat unfold 4 {
\time 2/4
    bd16 r16 hh8 sn4  |
    bd4 sn4  |
    bd4 sn16 r16 hh16 sn16  |
    bd4 sn4  |
    bd8 hh8 sn4  |
    bd4 r8 hh8  |
    bd4 sn16 r16 hh8  |
    bd4 sn4  |
    cymc4 sn4  |
    bd4 sn16 r16 hh16 sn16  |
    bd4 sn16 hh16 bd8  |
    bd16 sn16 hh8 sn4  |
    bd8 hh16 bd16 sn4  |
    bd16 hh16 r16 sn16 sn16 r16 hh8  |
    bd4 sn8 hh16 bd16  |
    cymc4 bd4  |
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
  \layout {}
}
