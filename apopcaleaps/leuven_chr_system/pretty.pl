:-[chr_op].

pretty(File):-
    see(File),
    read(Cl),
    pretty1(File).

pretty1(end_of_file):-!,seen.
pretty1(Cl):-
    portray_clause(Cl),
    read(NCl),
    pretty1(NCl).

    
