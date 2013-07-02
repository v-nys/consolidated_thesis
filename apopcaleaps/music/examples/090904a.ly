\version "2.12.1"
Melody = \relative c'' {
  \tempo 4=100
  \clef treble
  \repeat unfold 4 {
\time 4/4
    g8 g8 g8 c8 c4 e4  |
    a4 e4 a4 c8 a8  |
    f8 a8 f8 c8 f8 f8 a8 a8  |
    a4 a8 a8 d8 a8 d4  |
  }
}
Chords = \chordmode {
  \clef treble
  \repeat unfold 4 {
\time 4/4
    c4 c4 c4:7 c4  |
    a4:m a4:m a4:m r4  |
    f4 f4:7 f4 r4  |
    d4:m d4:m d4:m d4:m  |
  }
}
Bass = \relative c, {
  \clef "bass_8"
  \repeat unfold 4 {
\time 4/4
    g4 c4 g4 g4  |
    a4 a4 a4 a4  |
    f4 f4 f4 f4  |
    d4 d4 a4 d4  |
  }
}
Drums = \drummode {
  \repeat unfold 4 {
\time 4/4
    bd8 hh8 bd8 r8 sn4 hh4  |
    bd8 r8 r4 sn4 sn4  |
    bd8 hh8 hh4 sn8 r8 hh4  |
    bd4 sn4 sn4 bd4  |
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
