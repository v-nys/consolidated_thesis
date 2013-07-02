% Example queries:


% play, show,     meter(2,4), repeats(1), key(major), tempo(100),                 voice(drums), voice(bass), voice(chords), voice(melody),                 range(bass,g,1,c,3), range(melody,g,3,e,5),                 max_jump(bass,12), max_jump(melody,5), chord_style(offbeat),                shortest_duration(drums,16), shortest_duration(bass,8),                shortest_duration(chords,16), shortest_duration(melody,16),                measures(4), write_notes.

:- chrism e, t, t/1, u, s, v, s/1, w/1, w2/1.
e <=> play, show, t, write_notes.
t <=> t(8).
t(M) <=>        meter(2,4), repeats(1), key(major), tempo(100),
                voice(drums), voice(bass), voice(chords), voice(melody),
                range(bass,g,1,c,3), range(melody,g,3,e,5),
                max_jump(bass,12), max_jump(melody,5), chord_style(offbeat),
                shortest_duration(drums,16), shortest_duration(bass,8),
                shortest_duration(chords,16), shortest_duration(melody,16),
                measures(M).

u <=>         meter(2,4), repeats(1), key(major), tempo(100),
                voice(bass), voice(melody),
                range(bass,g,1,c,3), range(melody,g,3,e,5),
                max_jump(bass,12), max_jump(melody,5), 
                shortest_duration(bass,8),
                shortest_duration(melody,16),
                measures(1).

s <=>        meter(2,4), repeats(1), key(major), tempo(100),
                voice(melody),
                range(melody,g,3,e,5),
                max_jump(melody,5), 
                shortest_duration(melody,16),
                measures(1).


s(N) <=>        meter(2,4), repeats(1), key(major), tempo(100),
                voice(melody), range(melody,g,3,e,5),
                max_jump(melody,5), 
                shortest_duration(melody,8),
                measures(N).

w(N) <=>        meter(2,4), repeats(1), key(major), tempo(100),
                voice(drums), 
                shortest_duration(drums,4),
                measures(N).

w2(N) <=>        meter(2,4), repeats(1), key(major), tempo(100),
                voice(drums), 
                shortest_duration(drums,8),
                measures(N).


v <=>     meter(2,4), %repeats(1), 
                key(major), %tempo(100),
                measures(3).
