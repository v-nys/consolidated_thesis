:- module(copy_term_nat,
	[ copy_term_nat/2 
	]).

copy_term_nat(T,T1):-c_COPY_TERM(T,T1),!.
copy_term_nat(T,T1):-
   partial_copy_term(T,T1,_).

partial_copy_term(T,T1):-
   partial_copy_term(T,T1,Table).

partial_copy_term(X,Y,Table):-
   susp_var(X), !,
   partial_copy_lookup_regist(X,Y,Table).
partial_copy_term(X,Y,Table):-
   var(X), !,
   partial_copy_lookup_regist(X,Y,Table).
partial_copy_term(X,Y,Table):-
   integer(X), !,
   Y=X.
partial_copy_term(X,Y,Table):-
   atom(X), !,
   Y=X.
partial_copy_term(X,Y,Table):-
   functor(X,F,N),
   functor(Y,F,N),
   partial_copy_term_args(N,X,Y,Table).

partial_copy_lookup_regist(X,Y,Table) :- 
	( var(Table) -> 
		Table=[(X,Y)|_] 
	;
		Table=[(X1,Y1)|Tail],
		( X == X1 ->
			Y = Y1
		;
			partial_copy_lookup_regist(X,Y,Tail)
		)
	).
% partial_copy_lookup_regist(X,Y,[(X1,Y1)|_]) :- X==X1 : Y=Y1 .
% partial_copy_lookup_regist(X,Y,[_|Table]) :- true : partial_copy_lookup_regist(X,Y,Table).
% 
partial_copy_term_args(N,X,Y,Table):-N=:=0, !,  true.
partial_copy_term_args(N,X,Y,Table):-
   arg(N,X,A1),
   arg(N,Y,A2),
   partial_copy_term(A1,A2,Table),
   N1 is N-1,
   partial_copy_term_args(N1,X,Y,Table).

