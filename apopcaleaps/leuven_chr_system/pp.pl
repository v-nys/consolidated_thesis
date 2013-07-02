:- include(chr_op).

pp(FName,Out) :-
	tell(Out),	
	open(FName,read,File),
	repeat,
	read_term(File,Term,[]),
	( Term == end_of_file ->
		!,
		close(File),
		told
	;
		portray_clause(Term),
		fail
	).
