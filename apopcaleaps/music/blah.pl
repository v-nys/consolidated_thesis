t(M) :-        meter(2,4), repeats(1), key(major), tempo(100),
                voice(drums), voice(bass), voice(chords), voice(melody),
                range(bass,g,1,c,3), range(melody,g,3,e,5),
                max_jump(bass,12), max_jump(melody,5), chord_style(offbeat),
                shortest_duration(drums,16), shortest_duration(bass,8),
                shortest_duration(chords,16), shortest_duration(melody,16),
                measures(M).
