

%values(chord_choice(_),    [c   ,g   ,f   ,am  ,em  ,dm  ]).
:- set_sw(chord_choice(c), [0.2 ,0.3 ,0.25,0.15,0.05,0.05]).
:- set_sw(chord_choice(g), [0.3 ,0.15,0.2 ,0.2 ,0.05,0.1 ]).
:- set_sw(chord_choice(f), [0.25,0.3 ,0.1 ,0.15,0.05,0.15]).
:- set_sw(chord_choice(am),[0.1 ,0.2 ,0.35,0.1 ,0.05,0.2 ]).
:- set_sw(chord_choice(em),[0.05,0.2 ,0.3 ,0.35,0.05,0.05]).
:- set_sw(chord_choice(dm),[0.05,0.2 ,0.35,0.2 ,0.05,0.15]).


:- set_sw(split_beat(melody),[0.4,0.6]).
:- set_sw(split_beat(bass),[0.2,0.8]).
:- set_sw(split_beat(drums),[0.5,0.5]).
:- set_sw(split_beat(chords),[0.9,0.1]).



%values(note_choice(_,_),[rest,tonic,mediant,dominant,approach,color,blues,scale,nonscale]).
:- set_sw(note_choice(melody,first),    [0.05,0.32,0.38,0.10,0.05,0.05,0,0.04,0.01]).
:- set_sw(note_choice(melody,strong),   [0.05,0.27,0.18,0.30,0.05,0.10,0,0.04,0.01]).
:- set_sw(note_choice(melody,weak),     [0.10,0.15,0.10,0.15,0.20,0.13,0,0.15,0.02]).
:- set_sw(note_choice(melody,prestrong),[0.05,0.05,0.05,0.20,0.35,0.15,0,0.12,0.03]).
:- set_sw(note_choice(melody,weakest),  [0.10,0.05,0.05,0.15,0.30,0.15,0,0.17,0.03]).

:- set_sw(note_choice(bass,first),    [0.00,0.70,0.10,0.10,0.05,0.05,0,0,0]).
:- set_sw(note_choice(bass,strong),   [0.00,0.30,0.10,0.50,0.05,0.05,0,0,0]).
:- set_sw(note_choice(bass,weak),     [0.10,0.15,0.10,0.45,0.10,0.10,0,0,0]).
:- set_sw(note_choice(bass,prestrong),[0.05,0.25,0.05,0.25,0.35,0.05,0,0,0]).
:- set_sw(note_choice(bass,weakest),  [0.10,0.15,0.15,0.15,0.30,0.10,0,0.05,0]).



%:- set_sw(octave_choice,[0.6,0.2,0.2]).
%values(octave_choice(mid),[-2,-1,0,+1,+2]).
%values(octave_choice(low),[0,+1,+2]).
%values(octave_choice(high),[-2,-1,0]).
:- set_sw(octave_choice(mid),[0.05,0.2,0.5,0.2,0.05]).
:- set_sw(octave_choice(low),[0.6,0.3,0.1]).
:- set_sw(octave_choice(high),[0.1,0.3,0.6]).

%values(drum_choice(_),          [bd  ,sn  ,hh  ,cymc,r   ]).
:- set_sw(drum_choice(first),    [0.9 ,0   ,0   ,0.1 ,0   ]).
:- set_sw(drum_choice(strong),   [0   ,0.95,0   ,0   ,0.05]).
:- set_sw(drum_choice(weak),     [0.1 ,0.05,0.8 ,0   ,0.05]).
:- set_sw(drum_choice(weakest),  [0   ,0.05,0.4 ,0   ,0.55]).
:- set_sw(drum_choice(prestrong),[0.35,0.4 ,0.1 ,0.05,0.1 ]).








%values(chord_type(_,_),[0,7,r]).
:- set_sw(chord_type(offbeat,first),    [0.05 ,0   ,0.95]).
:- set_sw(chord_type(offbeat,strong),   [0.1 ,0   ,0.9]).
:- set_sw(chord_type(offbeat,weak),     [0.9 ,0.05,0.05]).
:- set_sw(chord_type(offbeat,weakest),  [0.025 ,0.025 ,0.95]).
:- set_sw(chord_type(offbeat,prestrong),[0.1 ,0.2 ,0.7]).

:- set_sw(chord_type(onbeat,first),    [1 ,0   ,0]).
:- set_sw(chord_type(onbeat,strong),   [0.6 ,0.1   ,0.3]).
:- set_sw(chord_type(onbeat,weak),     [0.2 ,0.2,0.6]).
:- set_sw(chord_type(onbeat,weakest),  [0.025 ,0.025 ,0.95]).
:- set_sw(chord_type(onbeat,prestrong),[0.1 ,0.1 ,0.8]).

% join_notes(Voice,Same_Measure?,Same_Count?)
:- set_sw(join_notes(melody,yes,yes), [0.25,0.75]).
:- set_sw(join_notes(melody,yes,no),  [0.15,0.85]).
:- set_sw(join_notes(melody,no ,no),  [0.1,0.9]).
:- set_sw(join_notes(chords,yes,yes), [0.2,0.8]).
:- set_sw(join_notes(chords,yes,no),  [0.1,0.9]).
:- set_sw(join_notes(chords,no ,no),  [0  ,1]).
:- set_sw(join_notes(bass,yes,yes),   [0.1,0.9]).
:- set_sw(join_notes(bass,yes,no),    [0  ,1]).
:- set_sw(join_notes(bass,no,no),     [0  ,1]).

%:- set_sw(scale(melody), [0.8, 0.2]).
%:- set_sw(scale(bass), [1, 0]).



:- set_all_concrete(melody).
:- set_all_concrete(bass).
set_all_concrete(N) :- chord(C),concrete_note(C,R,_), set_sw(concrete(N,C,R)), fail.
set_all_concrete(_N).

chord(c).
chord(f).
chord(g).
chord(am).
chord(em).
chord(dm).