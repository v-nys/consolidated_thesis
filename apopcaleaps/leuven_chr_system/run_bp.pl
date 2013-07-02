% Support module modifier operator
%:-set_prolog_flag(redefine_builtin,on).
:-set_prolog_flag(singleton,off).

:-dynamic message/3.

:-op(600,xfy,':').

(X:Y) :- %write(user,(X:Y)),nl(user),
	call(Y).

preload:-
    load_module(chr_swi_bootstrap),
    load_module(chr_runtime),
    load_module(attrvar),
    %
    used_modules(Ms),
    load_modules(Ms),
    %
    chr_modules(CHRMs),
    load_modules(CHRMs).

load_modules(Ms):-
    member(M,Ms),load_module(M),fail.
load_modules(Ms).

/* As B-Prolog does not support modules, load_modules(Files) load
    the CHR files after ripping off module names. For example, 
    a clause "m1:p :- m2:q" is translated into "p:-q". Notice 
    that name confliction may occur if the same predicate name is
    defined by multiple modules.
*/
load_module(M):-
    read_module(M,Cls,[]),
    compile_clauses(Cls).

consult_module(M):-
    read_module(M,Cls,[]),
    consult_clauses(Cls).

dump_module(M,Out):-
    read_module(M,Cls,[]),
    open(Out,write,S),
    dump_clauses(S,Cls),
    close(S).

consult_clauses(Cls):-
    phase_0_process(Cls,Prog,0), % 1 -eliminate disjunctions
    consult_preds(Prog,_).

dump_clauses(S,[]).
dump_clauses(S,[Cl|Cls]):-
    portray_clause(S,Cl),
    dump_clauses(S,Cls).

assert_clauses([]).
assert_clauses([Cl|Cls]):-
    assert(Cl),
    assert_clauses(Cls).

read_modules([],Cls,Cls).
read_modules([M|Ms],Cls,ClsR):-
    read_module(M,Cls,Cls1),
    read_modules(Ms,Cls1,ClsR).

read_module(M,Cls,ClsR):-
    atom(M),
    exists(M),!,
    read_proc_clauses(M,Cls,ClsR).
read_module(M,Cls,ClsR):-
    atom(M),
    plus_ext(M,pl,M1),
    exists(M1),!,
    read_proc_clauses(M1,Cls,ClsR).
read_module(M,Cls,ClsR):-
    throw(wrong_module_name(M)).

read_proc_clauses(M,Cls,ClsR):-
    see(M),
    read(Cl),
    read_proc_clauses1(Cl,Cls,ClsR),
    seen.

read_proc_clauses1(end_of_file,Cls,ClsR):-!,Cls=ClsR.
read_proc_clauses1(Cl,Cls,ClsR):-
    Cls=[NCl|Cls1],
    rip_module_name(Cl,NCl),
    read(NextCl),
    read_proc_clauses1(NextCl,Cls1,ClsR).

rip_module_name((:-dynamic B),NCl):-!,
    NCl=(:-dynamic NB),
    rip_module_name_body(B,NB).
rip_module_name((:-multifile B),NCl):-!,
    NCl=(:-multifile NB),
    rip_module_name_body(B,NB).
rip_module_name((H:-B),NCl):-!,
    NCl=(NH:-NB),
    (H=(M:H1)->NH=H1;NH=H),
    rip_module_name_body(B,NB).
rip_module_name((H-->B),NCl):-!,
    NCl=(NH-->NB),
    (H=(M:H1)->NH=H1;NH=H),
    rip_module_name_body(B,NB).
rip_module_name(H,NH):-
    (H=(M:H1)->NH=H1;NH=H).

rip_module_name_body(G,NB):-var(G),!,NB=G.
rip_module_name_body((Var^G),NB):-!,
    NB=(Var^NG),
    rip_module_name_body(G,NG).
rip_module_name_body((G1,G2),NB):-!,
    NB=(NG1,NG2),
    rip_module_name_body(G1,NG1),
    rip_module_name_body(G2,NG2).
rip_module_name_body((G1;G2),NB):-!,
    NB=(NG1;NG2),
    rip_module_name_body(G1,NG1),
    rip_module_name_body(G2,NG2).
rip_module_name_body((G1->G2),NB):-!,
    NB=(NG1->NG2),
    rip_module_name_body(G1,NG1),
    rip_module_name_body(G2,NG2).
rip_module_name_body(not(G),NB):-!,
    NB=not(NG),
    rip_module_name_body(G,NG).
rip_module_name_body(\+ G,NB):-!,
    NB= (\+ NG),
    rip_module_name_body(G,NG).
rip_module_name_body(call(G),NB):-!,
    NB= call(NG),
    rip_module_name_body(G,NG).
rip_module_name_body(findall(Template,G,Bag),NB):-!,
    NB= findall(Template,NG,Bag),
    rip_module_name_body(G,NG).
rip_module_name_body(bagof(Template,G,Bag),NB):-!,
    NB= bagof(Template,NG,Bag),
    rip_module_name_body(G,NG).
rip_module_name_body(setof(Template,G,Bag),NB):-!,
    NB= setof(Template,NG,Bag),
    rip_module_name_body(G,NG).
rip_module_name_body(forall(X,Xs,G),NB):-!,
    NB= forall(X,Xs,NG),
    rip_module_name_body(G,NG).
rip_module_name_body(forsome(X,Xs,G),NB):-!,
    NB= forsome(X,Xs,NG),
    rip_module_name_body(G,NG).
rip_module_name_body(find_with_var_identity(Template, IdVars, G, Answers),NB):-!,
    NB= find_with_var_identity(Template, IdVars, NG, Answers),
    rip_module_name_body(G,NG).
rip_module_name_body((M:G),NB):-!, NB=G.
rip_module_name_body(G,NB):-NB=G.

used_modules([assoc,
              oset,
  	       gensym,
	       ordsets,
  	       hprolog,
	       pairlist,
	       binomialheap,
	       find,
	       lists,
	       a_star,
	       listmap,
	       clean_code,
	       builtins]).


chr_modules([
	     chr_runtime,
	     chr_compiler_errors,
	     chr_hashtable_store,
	     % chr_compiler_options,
	     chr_compiler_utility,
	     chr_messages,
	     chr_swi]).


%Ignore module declarations
use_module(X).
use_module(X,Y).

% SWI primitives on global variable 
% b_setval(chr_global,Y):-true :
%     global_heap_set(chr_global,Y).
b_setval(X,Y):-
    global_heap_set(X,Y).

:- dynamic swi_global_var_init/2.

nb_setval(chr_global,Y):-true :
    global_heap_set(chr_global,Y).
nb_setval(X,Y):-
    ( retractall(swi_global_var_init(X,_)) ; true),!,
    assert(swi_global_var_init(X,Y)),
    global_heap_set(X,Y).


% nb_getval(chr_global,Y):-true :
%     (is_global_heap(chr_global)->
%      global_heap_get(chr_global,Y);
%      throw('global heap variable chr_global does not exist.')).
nb_getval(X,Y):-
    	( is_global_heap(X) ->
		global_heap_get(X,Y)
	; swi_global_var_init(X,Y1) ->
		global_heap_set(X,Y1),
		Y = Y1
	;
     		throw('global variable does not exist.'(X))
	).

memberchk(X,Xs):-
    member(X,Xs),!.

succ(I,Succ):-
    integer(I),!,Succ is I+1.
succ(I,Succ):-
    integer(Succ),!,I is Succ-1.
succ(I,Succ):-
    throw(wrong_arguments,succ(I,Succ)).

% remove meta_predicate declaration

chr_option(X,Y).

chr_constraint(X).

style_check(X).

print_message(Level,Mes):-
    (message(Mes,[Format-D|_],[])->
     write('%%'),format(Format,D);
     format("%%~w:~w~n",[Level,Mes])).

%file_base_name(File, Base):-
%    Base=File.

include(_).

predsort(Pred,List,SortedList) :-
	predsort(List,Pred,[],SortedList).

predsort([],_,Acc,Acc).
predsort([X|Xs],Pred,Acc,Result) :-
	predsort_insert(Acc,X,Pred,NAcc),
	predsort(Xs,Pred,NAcc,Result).

predsort_insert([],X,_,[X]).
predsort_insert([Y|Ys],X,Pred,List) :-
	Call =.. [Pred,R,X,Y],
	call(Call),
	( R == (>) ->
		List = [Y|Tail],
		predsort_insert(Ys,X,Pred,Tail)
	;
		List = [X,Y|Ys]
	).
	
maplist(Pred,Xs,Ys) :-
	maplist_iter(Xs,Pred,Ys).

maplist_iter([],_,[]).
maplist_iter([X|Xs],Pred,[Y|Ys]) :-
	Pred =.. PartialList,
	append(PartialList,[X,Y],FullList),
	Call =.. FullList,
	call(Call),
	maplist_iter(Xs,Pred,Ys).

maplist(Pred,Xs) :-
	maplist_iter(Xs,Pred).

maplist_iter([],_).
maplist_iter([X|Xs],Pred) :-
	Pred =.. PartialList,
	append(PartialList,[X],FullList),
	Call =.. FullList,
	call(Call),
	maplist_iter(Xs,Pred).

