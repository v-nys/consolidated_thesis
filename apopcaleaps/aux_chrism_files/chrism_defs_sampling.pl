
:- op(1102,xfx,[<==>,===>,<=/=>,==/=>]).

:- op(1160,xfx,times).
:- op(1150,fx,sample).
:- op(1150,fx,prob).
:- op(1150,fx,probf).
:- op(1150,fx,viterbi).
:- op(1150,fx,viterbif).
:- op(900,fx,'~').

:- op(1150,fx,ccall).


main_loop :-
    write('[CHRiSM] ?- '),
    read(Goal),
    (var(Goal) ->
        writeln('A variable is not a valid query.'),            %'
        fail
    ;
        true
    ),
    (Goal = end_of_file ->
        writeln('bye bye!'),
        halt
    ;
        true
    ),
    ( call(Goal) ->
        nl,
        fail 
    ;
        writeln('failed derivation'),
        fail
    ).
main_loop :-    
    main_loop.



$help_mess("~nType 'chrism_help' for usage notes.~n").   % Hook for B-Prolog

chrism_help :-
    format("Random switches:~n",[]),
    format(" msw(I,V)                -- the switch I randomly outputs the value V~n",[]),
    format(" set_sw(Sw,Params)       -- set parameters of a switch~n",[]),
    format(" get_sw(Sw,SwInfo)       -- get information of a switch~n",[]),
    nl,
    format("Builtins:~n",[]),
    format(" sample Goal             -- returns a random observation of a derivation from Goal~n",[]),
    format(" prob Observation        -- compute the probability of an observation~n",[]),
    format(" learn(ObservationList)  -- learn the parameters from a list of observations~n",[]),
    format(" learn                   -- learn the parameters from data_source~n",[]),
    nl,
    format("Observations:~n",[]),
    format(" Goal <==> Result        -- a result (final store) for Goal is Result~n",[]),
    format(" Goal ===> PartialResult -- a result for Goal contains PartialResult~n",[]),
    nl,
    format(" please consult the [currently non-existing] user's manual for details.~n",[]).


%:- p_not_table sample/1.
sample(Goal) :-
        chr_query(Goal,ResultList),
        list2conj(ResultList,Result),
        write(Goal),
        write('<==>'),
        writeq(Result),writeln('.').    %'


% does not work??
%(Q <=/=> R) :- \+ (Q <==> R).
%(Q ==/=> R) :- \+ (Q ===> R).

(Query <==> Result) :-
        add_result(Result,full),
        debugwriteln(trying(Query)),
        chr_query((Query,cleanup),ResultList),
        ( var(Result) ->
                list2conj(ResultList,Result)
        ;
                debugwriteln(found(ResultList)),
                chr_result_rest(Result,ResultList,[]),
                debugwriteln(goodGOODGOOD)
%                ,write('.')     %'
        ).

(Query ===> Result) :-
        add_result(Result, partial),
        chr_query((Query,cleanup),ResultList),
        ( var(Result) ->
                list2conj(ResultList,Result)
        ;
                chr_result_rest(Result,ResultList,_)
%                ,write('.')     %'
        ).

add_result(Result,X) :- 
        (ground(Result) ->
                result_status(X), result(Result)
        ;
                true
        ).


chr_result_rest((A,B),List,Rest) :-
        !,
        chr_result_rest(A,List,Rest1),
        chr_result_rest(B,Rest1,Rest).

chr_result_rest(true,List,List).

chr_result_rest(~(A),List,List) :-
        \+ chr_result_rest((A),List,_).
chr_result_rest(not(A),List,List) :-
        \+ chr_result_rest((A),List,_).
chr_result_rest(\+ A,List,List) :-
        \+ chr_result_rest((A),List,_).


chr_result_rest(A,List,Rest) :-
        select(A,List,Rest),!.


chr_result_rest(A,List,Rest) :- debugwriteln(not_good(A,List,Rest)), fail.



% no point in the following; learn and prob do not accept nonground stuff
%chr_result_rest(Builtin,List,List) :-
%        prolog_builtin(Builtin).
%prolog_builtin(A>B) :- A>B.
%prolog_builtin(A<B) :- A<B.
%prolog_builtin(A>=B) :- A>=B.
%prolog_builtin(A=<B) :- A=<B.
%prolog_builtin(A is B) :- A is B.
%prolog_builtin(A =:= B) :- A =:= B.
%prolog_builtin(A =/= B) :- A =/= B.


ccall(Q) :- semi_metacall(Q).

%:- p_table chr_query/2, semi_metacall/3, chr_semimetacall/3, '<==>'/2, '===>'/2.
:- p_table '<==>'/2, '===>'/2.
chr_query(Query,ResultList) :-
         semi_metacall(Query),
         findall(C,'$enumerate_constraints'(C),ResultList).

semi_metacall(X) :- var(X), !, writeln('Variable in query?'),fail.
semi_metacall((A,B)) :- !, semi_metacall(A), semi_metacall(B).
semi_metacall(G) :- functor(G,F,A), chr_constraint_predicate(F/A), !, chr_semimetacall(G).
semi_metacall(G) :- call(G).

chr_save_store(_X) :-
    true. % not doing this for now
%    writeln(start-save),
%    findall(K-V,enum_glob_vars(K,V),X),
%    writeln(saved(X)).


chr_load_store(_X) :-
    true. % not doing this for now
%    writeln(loading(X)),
%    set_all_global_vars(X).

%   retractall(swi_global_var_init(_,_)),
%   chr_init,
%   '$user__chr_initialization',

enum_glob_vars(K,V) :-
    swi_global_var_init(K,_),
    nb_getval(K,V).
enum_glob_vars(K,V) :-
    chr_runtime_global_variable(K),
    nb_getval(K,V).

set_all_global_vars([]).
set_all_global_vars([X-Y|Rest]) :-
    nb_setval(X,Y),
    set_all_global_vars(Rest).



conj2list(Conj,L) :-				%% transform conjunctions to list
  conj2list(Conj,L,[]).

conj2list(Conj,L,T) :-
  Conj = (G1,G2), !,
  conj2list(G1,L,T1),
  conj2list(G2,T1,T).
conj2list(G,[G | T],T).

list2conj([],true).
list2conj([X],X).
list2conj([X,Y|Z],(X,R)) :- list2conj([Y|Z],R).




