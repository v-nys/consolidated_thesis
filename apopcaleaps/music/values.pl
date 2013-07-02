
group_switches('Chord seq.',[chord_choice(_)]).
group_switches('Rythm',[split_beat(_),join_notes(_,_,_)]).
group_switches('Melody-A',[note_choice(melody,_)]).
group_switches('Melody-C',[concrete(melody,_,_)]).
%group_switches('Melody',[note_choice(melody,_), concrete(melody,_,_)]).
group_switches('Bass-A',[note_choice(bass,_)]).
group_switches('Bass-C',[concrete(bass,_,_)]).
%group_switches('Bass',[note_choice(bass,_), concrete(bass,_,_)]).
group_switches('Chords',[chord_type(_,_)]).
group_switches('Drums',[drum_choice(_)]).
group_switches('Octaves',[octave_choice(_)]).

chaos_group(melody,[note_choice(melody,_), concrete(melody,_,_), split_beat(melody, join_notes(melody,_,_))]).
chaos_group(bass,[note_choice(bass,_), concrete(bass,_,_), split_beat(bass), join_notes(bass,_,_)]).
chaos_group(chords,[chord_type(_,_), split_beat(chords), join_notes(chords,_,_),chord_choice(_)]).
chaos_group(drums,[drum_choice(_), split_beat(drums), join_notes(drums,_,_)]).
chaos_group(overall,X) :-
        chaos_group(melody,A1),
        chaos_group(bass,A2),
        chaos_group(chords,A3),
        chaos_group(drums,A4),
        append([A1,A2,A3,A4,[octave_choice(_)]],X).
        

values(chord_choice(_),    [c   ,g   ,f   ,am  ,em  ,dm ]).
values(note_choice(_,_),[rest,tonic,mediant,dominant,approach,color,blues,scale,nonscale]).
%values(note_choice(_,_,_),[c,d,e,f,g,a,b,r]).
%values(note_choice(melody,_,_,_),[c,cis,d,dis,e,f,fis,g,gis,a,ais,b,r]).
%values(note_choice(bass,_,_,_),[c,cis,d,dis,e,f,fis,g,gis,a,ais,b,r]).
values(octave_choice(mid),[-2,-1,0,+1,+2]).
values(octave_choice(low),[0,+1,+2]).
values(octave_choice(high),[-2,-1,0]).
values(drum_choice(_),[bd,sn,hh,cymc,r]).
values(chord_type(_,_),[0,7,r]).







%values(scale(_),[yes,no]).


values(concrete(melody,C,R),Vals) :- findall(N,concrete_note(C,R,N),Vals).
values(concrete(bass,C,R),Vals) :- findall(N,concrete_note(C,R,N),Vals).

concrete_note(_,rest,r).
concrete_note(C,scale,N) :- concrete_note(C,approach,N).


concrete_note(c,tonic,c).
concrete_note(c,mediant,e).
concrete_note(c,dominant,g).
concrete_note(c,approach,f).
concrete_note(c,approach,d).
concrete_note(c,approach,b).
concrete_note(c,approach,a).
concrete_note(c,color,ais).
concrete_note(c,color,d).
concrete_note(c,blues,d).
concrete_note(c,blues,dis).
concrete_note(c,nonscale,cis).
concrete_note(c,nonscale,dis).
concrete_note(c,nonscale,fis).
concrete_note(c,nonscale,gis).
concrete_note(c,nonscale,ais).

concrete_note(g,tonic,g).
concrete_note(g,mediant,b).
concrete_note(g,dominant,d).
concrete_note(g,approach,c).
concrete_note(g,approach,a).
concrete_note(g,approach,f).
concrete_note(g,approach,e).
concrete_note(g,color,f).
concrete_note(g,color,a).
concrete_note(g,blues,c).
concrete_note(g,blues,dis).
concrete_note(g,nonscale,cis).
concrete_note(g,nonscale,dis).
concrete_note(g,nonscale,fis).
concrete_note(g,nonscale,gis).
concrete_note(g,nonscale,ais).

concrete_note(f,tonic,f).
concrete_note(f,mediant,a).
concrete_note(f,dominant,c).
concrete_note(f,approach,b).
concrete_note(f,approach,g).
concrete_note(f,approach,e).
concrete_note(f,approach,d).
concrete_note(f,color,dis).
concrete_note(f,color,g).
concrete_note(f,blues,d).
concrete_note(f,blues,dis).
concrete_note(f,blues,g).
concrete_note(f,nonscale,cis).
concrete_note(f,nonscale,dis).
concrete_note(f,nonscale,fis).
concrete_note(f,nonscale,gis).
concrete_note(f,nonscale,ais).

% blues: a c d dis e g
concrete_note(am,tonic,a).
concrete_note(am,mediant,c).
concrete_note(am,dominant,e).
concrete_note(am,approach,d).
concrete_note(am,approach,b).
concrete_note(am,approach,g).
concrete_note(am,approach,f).
concrete_note(am,color,g).
concrete_note(am,color,b).
concrete_note(am,blues,d).
concrete_note(am,blues,dis).
concrete_note(am,blues,g).
concrete_note(am,nonscale,cis).
concrete_note(am,nonscale,dis).
concrete_note(am,nonscale,fis).
concrete_note(am,nonscale,gis).
concrete_note(am,nonscale,ais).

concrete_note(em,tonic,e).
concrete_note(em,mediant,g).
concrete_note(em,dominant,b).
concrete_note(em,approach,d).
concrete_note(em,approach,f).
concrete_note(em,approach,a).
concrete_note(em,approach,c).
concrete_note(em,color,d).
concrete_note(em,color,f).
concrete_note(em,blues,c).
concrete_note(em,blues,d).
concrete_note(em,blues,dis).
concrete_note(em,nonscale,cis).
concrete_note(em,nonscale,dis).
concrete_note(em,nonscale,fis).
concrete_note(em,nonscale,gis).
concrete_note(em,nonscale,ais).

concrete_note(dm,tonic,d).
concrete_note(dm,mediant,f).
concrete_note(dm,dominant,a).
concrete_note(dm,approach,c).
concrete_note(dm,approach,e).
concrete_note(dm,approach,g).
concrete_note(dm,approach,b).
concrete_note(dm,color,c).
concrete_note(dm,color,e).
concrete_note(dm,blues,c).
concrete_note(dm,blues,dis).
concrete_note(dm,blues,g).
concrete_note(dm,nonscale,cis).
concrete_note(dm,nonscale,dis).
concrete_note(dm,nonscale,fis).
concrete_note(dm,nonscale,gis).
concrete_note(dm,nonscale,ais).


/*
concrete_note(M,Role,Note) :- 
        major_chord_nonc(M),
        concrete_note(c,Role,CNote), 
        CNote \= r,
        interval(c,M,Trans),
        interval(c,CNote,Int),
        TransInt is (Int+Trans) mod 12,
        interval(c,Note,TransInt).

concrete_note(M,Role,Note) :- 
        minor_chord_nonam(M,MT),
        concrete_note(am,Role,CNote), 
        CNote \= r,
        interval(c,MT,Trans),
        interval(c,CNote,Int),
        TransInt is (Int+Trans) mod 12,
        interval(c,Note,TransInt).

major_chord_nonc(g).
major_chord_nonc(f).

minor_chord_nonam(dm,d).
minor_chord_nonam(em,e).
*/
