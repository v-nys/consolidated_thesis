\version "2.12.1"
Melody = {
  \tempo 4=172
  \clef treble
  \repeat unfold 4 {
\time 2/4
    r8 c'16 e'16 e'4  |
    c'8 r8 c''4  |
    b'8 d''8 f''4  |
    c''4 g'4  |
    b'4 g'4  |
    f'4 f'4  |
    e'4 g'8 c''8  |
    e''4 c''4  |
  }
}
Chords = \chordmode {
  \tempo 4=172
  \clef treble
  \repeat unfold 4 {
\time 2/4
    r8 c8 r8 c8  |
    r8 a8:m7 r8 a8:m  |
    r4 r8 g8  |
    r8 c8 r8 c8  |
    r8 g8 g8 g8  |
    r8 f8 r8 f8:7  |
    r8 c8 r4  |
    r4 r4  |
  }
}
Bass = {
  \tempo 4=172
  \clef "bass_8"
  \repeat unfold 4 {
\time 2/4
    g,4 g,,4  |
    c,4 a,,8 g,,8  |
    g,,4 g,,8 r8  |
    c,8 g,8 g,8 c8  |
    d4 c4  |
    c8 c8 f4  |
    d4 d8 e8  |
    c,4 b,4  |
  }
}
Drums = \drummode {
  \tempo 4=172
  \repeat unfold 4 {
\time 2/4
    bd4 sn16 hh16 hh16 r16  |
    bd4 sn16 hh16 hh16 sn16  |
    bd16 hh16 hh8 sn16 r16 hh8  |
    bd4 sn8 hh16 sn16  |
    bd4 sn16 r16 hh8  |
    bd4 sn4  |
    bd8 sn8 sn4  |
    bd4 bd4  |
  }
}
\score{
  <<
    \new Staff \with {midiInstrument = #"trumpet"} \Melody
    \new Staff \with {midiInstrument = #"percussive organ"} \Chords
    \new Staff \with {midiInstrument = #"slap bass 1"} \Bass
    \new DrumStaff \Drums
  >>
  \midi {}
}
