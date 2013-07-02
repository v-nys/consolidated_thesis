\version "2.12.1"
Melody = {
  \tempo 4=140
  \clef treble
  \repeat unfold 4 {
\time 4/4
    r16 e'16 d'16 c'16  ~ c'4 dis'16 d'16 g'16 dis'16 g'16  ~ g'16  ~ g'16 dis''16  |
    r16  ~ r16 r16 b'16 e'16 d'16  ~ d'16 c'16 r16 r16 a'16  ~ a'16 g'4  |
    r4 d''16 dis''16 c''16 f'16 a'16 g'16  ~ g'8  ~ g'8 a'8  |
    c''16 dis'16 f'16 e'16 dis'16 d'16 d'8 b'4 a'16 r16 g'16 r16  |
    e'4 a'4 g'4 d''16 d''16 a''16 g''16  |
    b'8 d'8 c'4 d'4 c'4  |
    b4 c'4  ~ c'16 dis'16 g'16 a'16 d'4  |
    r4 a'4 c''4 c''4  |
  }
}
Chords = \chordmode {
  \tempo 4=140
  \clef treble
  \repeat unfold 4 {
\time 4/4
    a4:m7 r4 r4 r4  |
    e4:m7 e4:m7 e8:m r8 r4  |
    f8 r8 f4:7 r4 f4:7  |
    g4 r4 g4 r4  |
    c4 r4 c4 r4  |
    g4:7 r4  ~ r4 r4  |
    g8:7 r8 r4 g4 r4  |
    a4:m7 a4:m a4:m7 a4:m  |
  }
}
Bass = {
  \tempo 4=140
  \clef "bass_8"
  \repeat unfold 4 {
\time 4/4
    a,16 d,16 dis,8 a,,16 g,,16 g,,16 g,,16 g,,16 g,16 a,16 g,16 g,16 a,16 a,,8  |
    e16 c16 c8 b,4 e,8 g,16 d,16 d4  |
    c4 g,4 f,8 a,16 r16 a,16 d16 c8  |
    g,,16 a,16 g,16 c,16 d,16 d,16 r8 b,16 a,16 b,8 b,,16 a,,16 g,,8  |
    a,,8 a,,16 g,,16 r16 a,,16 g,,16 d,16 e,16 g,,16 c,16 a,16 g,8 c16 a,16  |
    g,16 g,,16 g,,8 d16 g,16 g,16 c,16 d,4 d,4  |
    g,16 c,16 c,8 d,16 d,16 d,16 g,,16 c,16 d,16 e16 dis16 d8 dis16 b,16  |
    a,,4 a,,4 d,4 dis,4  |
  }
}
Drums = \drummode {
  \tempo 4=140
  \repeat unfold 4 {
\time 4/4
    bd4 hh4 sn4 hh4  |
    bd4 hh16 r16 r16 r16 sn4 hh4  |
    bd4 hh16 r16 cymc8 sn16 sn16 sn8 hh4  |
    bd4 bd16 sn16 sn8 hh8 r16 hh16 hh4  |
    bd16 hh16 r8 hh8 bd16 hh16 hh8 r8 hh4  |
    bd8 r8 hh4 sn4 bd4  |
    bd4 hh8 sn16 r16 sn4 hh4  |
    bd4 bd4 bd4 bd4  |
  }
}
\score{
  <<
    \new Staff \with {midiInstrument = #"alto sax"} \Melody
    \new Staff \with {midiInstrument = #"electric guitar (jazz)"} \Chords
    \new Staff \with {midiInstrument = #"electric bass (pick)"} \Bass
    \new DrumStaff \Drums
  >>
  \layout {}
  \midi {}
}
