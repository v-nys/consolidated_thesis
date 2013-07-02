\version "2.12.1"
Melody = {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    a'16 d''16 e''16 e''16 c''16  ~ c''16 a'8  |
    g'4 g'16 d'16 g'16 e'16  |
    b16 a16 d'16 d'16 g'4  |
    e'4 g'8 g'16 f'16  |
    g'4 b'16 r16 d''16 r16  |
    a'4 c''4  |
    e''8 c''16 c''16 d''4  |
    c''4 c''4  |
  }
}
Chords = \chordmode {
  \tempo 4=120
  \clef treble
  \repeat unfold 4 {
\time 2/4
    a4:m r8 a8:m  |
    r4 r4  |
    r4 r4  |
    r4 r4  |
    r4 r4  |
    r4 r4  |
    r4 r4  |
    r4 r4  |
  }
}
Bass = {
  \tempo 4=120
  \clef "bass_8"
  \repeat unfold 4 {
\time 2/4
    a,8 r8 b,8 b,8  |
    e,8 r8 a,8 b,8  |
    b,,8 d,8 d,8 a,,8  |
    b,,8 c,8 c8 g,8  |
    g,8 b,8 d8 b,8  |
    f,8 c8 c,8 c,8  |
    g,8 g,,8 g,,8 c,8  |
    a,4 a,4  |
  }
}
Drums = \drummode {
  \tempo 4=120
  \repeat unfold 4 {
\time 2/4
    bd16 r16 hh8 sn4  |
    bd8 hh16 r16 sn8 hh16 sn16  |
    bd8 hh8 sn4  |
    bd4 sn8 hh16 bd16  |
    cymc4 sn4  |
    bd4 sn16 r16 hh16 bd16  |
    bd4 sn4  |
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
  \layout {}
  \midi {}
}
