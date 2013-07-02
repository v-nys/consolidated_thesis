
:- set_prolog_flag(warning,off).

use_module(_).
module(_,_).

%   File   : ASSOC.PL
%   Author : R.A.O'Keefe
%   Updated: 9 November 1983
%   Purpose: Binary tree implementation of "association lists".

%   Note   : the keys should be ground, the associated values need not be.

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Adapted for SWI-Prolog by Jan Wielemaker, January 2004.

To the best of my knowledge, this file   is in the public domain and can
therefore safely be distributed with SWI-Prolog and used in applications
without restrictions.

Various versions of this file exists. This   one  is copied from the YAP
library. The SICStus library contains  one   using  ALV  trees to ensure
proper balancing. Although based  on  this   library  they  changed  the
argument order of some of the predicates.

Richard O'Keefe has told me he  is  working   on  a  new version of this
library. This new version, as it becomes available, is likely to replace
this one.

If you wish to use this library  in   an  application, be aware that its
interface may change. If the new version   becomes  available it will be
documented in the SWI-Prolog Reference Manual.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

:- module(assoc,
	  [ assoc_to_list/2,		% +Assoc, -List
	    empty_assoc/1,		% -Assoc
	    gen_assoc/3,		% +Assoc, ?Key, ?Value
	    get_assoc/3,		% +Key, +Assoc, -Value
	    get_assoc/5,		% +Key, +Assoc, +Old, -NewAssoc, +New
	    list_to_assoc/2,		% +List, -Assoc
	    map_assoc/3,		% :Goal, +AssocIn, -AssocOut
	    ord_list_to_assoc/2,	% +List, -Assoc
	    put_assoc/4			% +Key, +Assoc, +Value, -NewAssoc
	  ]).

%:- meta_predicate map_assoc(:, ?, ?).

empty_assoc(t).

assoc_to_list(Assoc, List) :-
	assoc_to_list(Assoc, List, []).


assoc_to_list(t(Key,Val,L,R), List, Rest) :-
	assoc_to_list(L, List, [Key-Val|More]),
	assoc_to_list(R, More, Rest).
assoc_to_list(t, List, List).


gen_assoc(t(_,_,L,_), Key, Val) :-
	gen_assoc(L, Key, Val).
gen_assoc(t(Key,Val,_,_), Key, Val).
gen_assoc(t(_,_,_,R), Key, Val) :-
	gen_assoc(R, Key, Val).


get_assoc(Key, t(K,V,L,R), Val) :-
	compare(Rel, Key, K),
	get_assoc(Rel, Key, V, L, R, Val).


get_assoc(=, _, Val, _, _, Val).
get_assoc(<, Key, _, Tree, _, Val) :-
	get_assoc(Key, Tree, Val).
get_assoc(>, Key, _, _, Tree, Val) :-
	get_assoc(Key, Tree, Val).


get_assoc(Key, t(K,V,L,R), Val, t(K,NV,NL,NR), NVal) :-
	compare(Rel, Key, K),
	get_assoc(Rel, Key, V, L, R, Val, NV, NL, NR, NVal).


get_assoc(=, _, Val, L, R, Val, NVal, L, R, NVal).
get_assoc(<, Key, V, L, R, Val, V, NL, R, NVal) :-
	get_assoc(Key, L, Val, NL, NVal).
get_assoc(>, Key, V, L, R, Val, V, L, NR, NVal) :-
	get_assoc(Key, R, Val, NR, NVal).


list_to_assoc(List, Assoc) :-
	list_to_assoc(List, t, Assoc).

list_to_assoc([], Assoc, Assoc).
list_to_assoc([Key-Val|List], Assoc0, Assoc) :-
	put_assoc(Key, Assoc0, Val, AssocI),
	list_to_assoc(List, AssocI, Assoc).

ord_list_to_assoc(Keys, Assoc) :-
	length(Keys, L),
	ord_list_to_assoc(L, Keys, Assoc, []).

ord_list_to_assoc(0, List, t, List) :- !.
ord_list_to_assoc(N, List, t(Key,Val,L,R), Rest) :-
	A is (N-1)//2,
	Z is (N-1)-A,
	ord_list_to_assoc(A, List, L, [Key-Val|More]),
	ord_list_to_assoc(Z, More, R, Rest).


map_assoc(Pred, t(Key,Val,L0,R0), t(Key,Ans,L1,R1)) :- !,
	map_assoc(Pred, L0, L1),
	call(Pred, Val, Ans),
	map_assoc(Pred, R0, R1).
map_assoc(_, t, t).


put_assoc(Key, t(K,V,L,R), Val, New) :- !,
	compare(Rel, Key, K),
	put_assoc(Rel, Key, K, V, L, R, Val, New).
put_assoc(Key, t, Val, t(Key,Val,t,t)).


put_assoc(=, Key, _, _, L, R, Val, t(Key,Val,L,R)).
put_assoc(<, Key, K, V, L, R, Val, t(K,V,Tree,R)) :-
	put_assoc(Key, L, Val, Tree).
put_assoc(>, Key, K, V, L, R, Val, t(K,V,L,Tree)) :-
	put_assoc(Key, R, Val, Tree).



/*  $Id: chr_hashtable_store.pl,v 1.9 2006/03/10 14:13:15 toms Exp $

    Part of CHR (Constraint Handling Rules)

    Author:        Tom Schrijvers
    E-mail:        Tom.Schrijvers@cs.kuleuven.be
    WWW:           http://www.swi-prolog.org
    Copyright (C): 2003-2004, K.U. Leuven

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/
% author: Tom Schrijvers
% email:  Tom.Schrijvers@cs.kuleuven.be
% copyright: K.U.Leuven, 2004

:- module(chr_hashtable_store,
	[ new_ht/1,
	  lookup_ht/3,
	  insert_ht/3,
	  delete_ht/3,
	  value_ht/2
	]).

:- use_module(assoc).
:- use_module(lists).


new_ht(ht(Assoc)) :- empty_assoc(Assoc).

lookup_ht(ht(Assoc),Key,List) :-
	get_assoc(Key,Assoc,List).
		
insert_ht(HT,Key,Value) :-
	HT = ht(Assoc),
	( get_assoc(Key,Assoc,List) ->
		put_assoc(Key,Assoc,[Value|List],NAssoc)
	;
		put_assoc(Key,Assoc,[Value],NAssoc)
	),
	setarg(1,HT,NAssoc).

delete_ht(HT,Key,Value) :-
	HT = ht(Assoc),
	( get_assoc(Key,Assoc,List) ->
		delete(List,Value,NList),
		put_assoc(Key,Assoc,NList,NAssoc),
		setarg(1,HT,NAssoc)
	;
		true
	)        
        , !.


value_ht(HT,Value) :-
        HT = ht(Assoc),
	gen_assoc(Assoc,_,List),
	member(Value,List).


/*  $Id: lists.pl,v 1.5 2004/09/21 14:22:23 jan Exp $

    Part of SWI-Prolog

    Author:        Jan Wielemaker and Richard O'Keefe
    E-mail:        jan@swi.psy.uva.nl
    WWW:           http://www.swi-prolog.org
    Copyright (C): 1985-2002, University of Amsterdam

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.
*/

:- module(lists,
	[ member/2,
	  append/3,
	  nextto/3,			% ?X, ?Y, ?List
%	  nth1/3,
	  reverse/2,			% +List, -Reversed
	  permutation/2,		% ?List, ?Permutation
	  numlist/3,			% +Low, +High, -List

	  is_set/1,			% set manipulation
	  list_to_set/2,		% +List, -Set
	  intersection/3,
	  union/3,
	  subset/2,
	  subtract/3,
	  memberchk/2
	]).
%:- set_prolog_flag(generate_debug_info, false).

/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Some of these predicates are copied from   "The  Craft of Prolog" and/or
the DEC-10 Prolog library (LISTRO.PL). Contributed by Richard O'Keefe.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */

%	member(?Elem, ?List)
%	
%	True if Elem is a member of List

%member(X, [X|_]).
%member(X, [_|T]) :-
%	member(X, T).

%	append(?List1, ?List2, ?List1AndList2)
%	
%	List1AndList2 is the concatination of List1 and List2

%append([], L, L).
%append([H|T], L, [H|R]) :-
%	append(T, L, R).

%	nextto(?X, ?Y, ?List)
%	
%	True of Y follows X in List.

nextto(X, Y, [X,Y|_]).
nextto(X, Y, [_|Zs]) :-
	nextto(X, Y, Zs).
/*  nth0/3, nth1/3 are improved versions from
    Martin Jansche <martin@pc03.idf.uni-heidelberg.de>
*/

%%  nth0(?Index, ?List, ?Elem)
%%  is true when Elem is the Index'th element of List.  Counting starts
%%  at 0.  [This is a faster version of the original SWI-Prolog predicate.]
/*
nth0(Index, List, Elem) :-
        integer(Index), !,
        Index >= 0,
        nth0_det(Index, List, Elem).    %% take nth deterministically
nth0(Index, List, Elem) :-
        var(Index), !,
        nth_gen(List, Elem, 0, Index).  %% match

nth0_det(0, [Elem|_], Elem) :- !.
nth0_det(1, [_,Elem|_], Elem) :- !.
nth0_det(2, [_,_,Elem|_], Elem) :- !.
nth0_det(3, [_,_,_,Elem|_], Elem) :- !.
nth0_det(4, [_,_,_,_,Elem|_], Elem) :- !.
nth0_det(5, [_,_,_,_,_,Elem|_], Elem) :- !.
nth0_det(N, [_,_,_,_,_,_   |Tail], Elem) :-
        M is N - 6,
        nth0_det(M, Tail, Elem).

nth_gen([Elem|_], Elem, Base, Base).
nth_gen([_|Tail], Elem, N, Base) :-
        %succ(N, M),
        M is N+1,
        nth_gen(Tail, Elem, M, Base).


%%  nth1(?Index, ?List, ?Elem)
%%  Is true when Elem is the Index'th element of List.  Counting starts
%%  at 1.  [This is a faster version of the original SWI-Prolog predicate.]

nth1(Index1, List, Elem) :-
        integer(Index1), !,
        Index0 is Index1 - 1,
        nth0_det(Index0, List, Elem).   %% take nth deterministically
nth1(Index, List, Elem) :-
        var(Index), !,
        nth_gen(List, Elem, 1, Index).  %% match
*/

%	reverse(?List1, ?List2)
%
%	Is true when the elements of List2 are in reverse order compared to
%	List1.

%reverse(Xs, Ys) :-
%    reverse(Xs, [], Ys, Ys).

%reverse([], Ys, Ys, []).
%reverse([X|Xs], Rs, Ys, [_|Bound]) :-
%    reverse(Xs, [X|Rs], Ys, Bound).


%	premutation(?Xs, ?Ys)
%	
%	permutation(Xs, Ys) is true when Xs is a permutation of Ys. This
%	can solve for Ys given Xs or Xs given Ys, or even enumerate Xs
%	and Ys together.

permutation(Xs, Ys) :-
	permutation(Xs, Ys, Ys).

permutation([], [], []).
permutation([X|Xs], Ys1, [_|Bound]) :-
	permutation(Xs, Ys, Bound),
	select(X, Ys1, Ys).

%	numlist(+Low, +High, -List)
%	
%	List is a list [Low, Low+1, ... High]

numlist(L, U, Ns) :-
    integer(L), integer(U), L =< U,
    numlist_(L, U, Ns).

numlist_(L, U, [L|Ns]) :-
    (   L =:= U
    ->  Ns = []
    ;   M is L + 1,
	numlist_(M, U, Ns)
    ).


		/********************************
		*       SET MANIPULATION        *
		*********************************/

%	is_set(+Set)
%	is True if Set is a proper list without duplicates.

is_set(0) :- !, fail.		% catch variables
is_set([]) :- !.
is_set([H|T]) :-
	memberchk(H, T), !, 
	fail.
is_set([_|T]) :-
	is_set(T).

%	list_to_set(+List, ?Set)
%
%	Is true when Set has the same element as List in the same order.
%	The left-most copy of the duplicate is retained.

list_to_set(List, Set) :-
	list_to_set_(List, Set0),
	Set = Set0.

list_to_set_([], R) :-
	close_list(R).
list_to_set_([H|T], R) :-
	memberchk(H, R), !, 
	list_to_set_(T, R).

close_list([]) :- !.
close_list([_|T]) :-
	close_list(T).


%	intersection(+Set1, +Set2, -Set3)
%
%	Succeeds if Set3 unifies with the intersection of Set1 and Set2

intersection([], _, []) :- !.
intersection([X|T], L, Intersect) :-
	memberchk(X, L), !, 
	Intersect = [X|R], 
	intersection(T, L, R).
intersection([_|T], L, R) :-
	intersection(T, L, R).


%	union(+Set1, +Set2, -Set3)
%	Succeeds if Set3 unifies with the union of Set1 and Set2

union([], L, L) :- !.
union([H|T], L, R) :-
	memberchk(H, L), !, 
	union(T, L, R).
union([H|T], L, [H|R]) :-
	union(T, L, R).


%	subset(+SubSet, +Set)
%	Succeeds if all elements of SubSet belong to Set as well.
%

subset([], _) :- !.
subset([E|R], Set) :-
	memberchk(E, Set), 
	subset(R, Set).


%	subtract(+Set, +Delete, -Result)
%
%	Delete all elements from `Set' that occur in `Delete' (a set) and
%	unify the result with `Result'.

subtract([], _, []) :- !.
subtract([E|T], D, R) :-
	memberchk(E, D), !,
	subtract(T, D, R).
subtract([H|T], D, [H|R]) :-
	subtract(T, D, R).


memberchk(X,[Y|Z]) :- X==Y.
memberchk(X,[_|Z]) :- memberchk(X,Z).


/*  $Id: chr_runtime.pl,v 1.18 2006/04/11 14:21:17 toms Exp $

    Part of CHR (Constraint Handling Rules)

    Author:        Christian Holzbaur and Tom Schrijvers
    E-mail:        christian@ai.univie.ac.at
		   Tom.Schrijvers@cs.kuleuven.be
    WWW:           http://www.swi-prolog.org
    Copyright (C): 2003-2004, K.U. Leuven

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    As a special exception, if you link this library with other files,
    compiled with a Free Software compiler, to produce an executable, this
    library does not by itself cause the resulting executable to be covered
    by the GNU General Public License. This exception does not however
    invalidate any other reasons why the executable file might be covered by
    the GNU General Public License.

    Distributed with SWI-Prolog under the above conditions with
    permission from the authors.
*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%       _                             _   _                
%%   ___| |__  _ __   _ __ _   _ _ __ | |_(_)_ __ ___   ___ 
%%  / __| '_ \| '__| | '__| | | | '_ \| __| | '_ ` _ \ / _ \`
%% | (__| | | | |    | |  | |_| | | | | |_| | | | | | |  __/
%%  \___|_| |_|_|    |_|   \__,_|_| |_|\__|_|_| |_| |_|\___|
%%
%% hProlog CHR runtime:
%%
%% 	* based on the SICStus CHR runtime by Christian Holzbaur
%% 
%%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          %  Constraint Handling Rules		      version 2.2 %
%%          %								  %
%%          %  (c) Copyright 1996-98					  %
%%          %  LMU, Muenchen						  %
%% 	    %								  %
%%          %  File:   chr.pl						  %
%%          %  Author: Christian Holzbaur	christian@ai.univie.ac.at %
%%          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
%%	
%%	* modified by Tom Schrijvers, K.U.Leuven, Tom.Schrijvers@cs.kuleuven.be
%%		- ported to hProlog
%%		- modified for eager suspension removal
%%
%%      * First working version: 6 June 2003
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SWI-Prolog changes
%% 
%% 	* Added initialization directives for saved-states
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- module(chr_runtime,
	  [ 'chr sbag_del_element'/3,
	    'chr sbag_member'/2,
	    'chr merge_attributes'/3,

	    'chr run_suspensions'/1,
	    'chr run_suspensions_loop'/1,
	    
	    'chr run_suspensions_d'/1,
	    'chr run_suspensions_loop_d'/1,

	    'chr insert_constraint_internal'/5,
	    'chr remove_constraint_internal'/2,
	    'chr allocate_constraint'/4,
	    'chr activate_constraint'/3,

	    'chr default_store'/1,

	    'chr via_1'/2,
	    'chr via_2'/3,
	    'chr via'/2,
	    'chr newvia_1'/2,
	    'chr newvia_2'/3,
	    'chr newvia'/2,

	    'chr lock'/1,
	    'chr unlock'/1,
	    'chr not_locked'/1,
	    'chr none_locked'/1,

	    'chr update_mutable'/2,
	    'chr get_mutable'/2,
	    'chr create_mutable'/2,

	    'chr novel_production'/2,
	    'chr extend_history'/2,
	    'chr empty_history'/1,

	    'chr gen_id'/1,

	    'chr debug_event'/1,
	    'chr debug command'/2,	% Char, Command

	    'chr chr_indexed_variables'/2,

	    chr_show_store/1,	% +Module
	    find_chr_constraint/1,

	    chr_trace/0,
	    chr_notrace/0,
	    chr_leash/1
	  ]).

%% SWI begin
%% :- set_prolog_flag(generate_debug_info, false).
%% SWI end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                       
:- use_module(hprolog).
%:- include(chr_op).

%% SICStus begin
%% :- use_module(library(lists),[memberchk/2]).
%% :- use_module(library(terms),[term_variables/2]).
%% :- use_module(hpattvars).
%% :- use_module(b_globval).
%% SICStus end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   I N I T I A L I S A T I O N

%% SWI begin
%:- dynamic user:exception/3.
%:- multifile user:exception/3.

%user:exception(undefined_global_variable, Name, retry) :-
%	chr_runtime_global_variable(Name),
%	chr_init.

chr_runtime_global_variable(chr_id).
chr_runtime_global_variable(chr_global).
%chr_runtime_global_variable(chr_debug).
%chr_runtime_global_variable(chr_debug_history).

chr_init :-
	nb_setval(chr_id,0),
	nb_setval(chr_global,_).
%	nb_setval(chr_debug,mutable(off)),          % XXX
%	nb_setval(chr_debug_history,mutable([],0)). % XXX
%% SWI end

%% SICStus begin
%% chr_init :-
%% 	        nb_setval(chr_id,0).
%% SICStus end

:- initialization chr_init.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Contents of former chr_debug.pl
%   
%	chr_show_store(+Module)
%	
%	Prints all suspended constraints of module   Mod to the standard
%	output.

css :- chr_show_store(blah).

css2 :- chr_show_store2, writeln('.'). %'

chr_show_store2 :-
	(
		'$enumerate_constraints'(Constraint),
                writeln(','),
		writeq(Constraint), 
		fail
	;
		true
	).


chr_show_store(_Mod) :-
	(
		%Mod:
		'$enumerate_constraints'(Constraint),
		print(Constraint),nl, % allows use of portray to control printing

		fail
	;
		true
	).

find_chr_constraint(Constraint) :-
	%chr:
	%'$chr_module'(Mod),
	%Mod:
	'$enumerate_constraints'(Constraint).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inlining of some goals is good for performance
% That's the reason for the next section
% There must be correspondence with the predicates as implemented in chr_mutable.pl
% so that       user:goal_expansion(G,G). also works (but do not add such a rule)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SWI begin
%:- multifile user:goal_expansion/2.
%:- dynamic   user:goal_expansion/2.

%user:goal_expansion('chr get_mutable'(Val,Var),    Var=mutable(Val)).
%user:goal_expansion('chr update_mutable'(Val,Var), setarg(1,Var,Val)).
%user:goal_expansion('chr create_mutable'(Val,Var), Var=mutable(Val)).
%user:goal_expansion('chr default_store'(X),        nb_getval(chr_global,X)).
%% SWI end

% goal_expansion seems too different in SICStus 4 for me to cater for in a
% decent way at this moment - so I stick with the old way to do this
% so that it doesn't get lost, the code from Mats for SICStus 4 is included in comments


%% Mats begin
%% goal_expansion('chr get_mutable'(Val,Var),    Lay, _M, get_mutable(Val,Var), Lay).
%% goal_expansion('chr update_mutable'(Val,Var), Lay, _M, update_mutable(Val,Var), Lay).
%% goal_expansion('chr create_mutable'(Val,Var), Lay, _M, create_mutable(Val,Var), Lay).
%% goal_expansion('chr default_store'(A),        Lay, _M, global_term_ref_1(A), Lay).
%% Mats begin


%% SICStus begin
%% :- multifile user:goal_expansion/2.
%% :- dynamic   user:goal_expansion/2.
%% 
%% user:goal_expansion('chr get_mutable'(Val,Var),    get_mutable(Val,Var)).
%% user:goal_expansion('chr update_mutable'(Val,Var), update_mutable(Val,Var)).
%% user:goal_expansion('chr create_mutable'(Val,Var), create_mutable(Val,Var)).
%% user:goal_expansion('chr default_store'(A),        global_term_ref_1(A)).
%% SICStus end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr run_suspensions'( Slots) :-
	    run_suspensions( Slots).

'chr run_suspensions_loop'([]).
'chr run_suspensions_loop'([L|Ls]) :-
	run_suspensions(L),
	'chr run_suspensions_loop'(Ls).

run_suspensions([]).
run_suspensions([S|Next] ) :-
	arg( 2, S, Mref), % ARGXXX
	'chr get_mutable'( Status, Mref),
	( Status==active ->
	    'chr update_mutable'( triggered, Mref),
	    arg( 4, S, Gref), % ARGXXX
	    'chr get_mutable'( Gen, Gref),
	    Generation is Gen+1,
	    'chr update_mutable'( Generation, Gref),
	    arg( 3, S, Goal), % ARGXXX
	    call( Goal),
	    'chr get_mutable'( Post, Mref),
	    ( Post==triggered ->
		'chr update_mutable'( active, Mref)	% catching constraints that did not do anything
	    ;
		true
	    )
	;
	    true
	),
	run_suspensions( Next).

'chr run_suspensions_d'( Slots) :-
	    run_suspensions_d( Slots).

'chr run_suspensions_loop_d'([]).
'chr run_suspensions_loop_d'([L|Ls]) :-
	run_suspensions_d(L),
	'chr run_suspensions_loop_d'(Ls).

run_suspensions_d([]).
run_suspensions_d([S|Next] ) :-
	arg( 2, S, Mref), % ARGXXX
	'chr get_mutable'( Status, Mref),
	( Status==active ->
	    'chr update_mutable'( triggered, Mref),
	    arg( 4, S, Gref), % ARGXXX
	    'chr get_mutable'( Gen, Gref),
	    Generation is Gen+1,
	    'chr update_mutable'( Generation, Gref),
	    arg( 3, S, Goal), % ARGXXX
	    ( 
		'chr debug_event'(wake(S)),
	        call( Goal)
	    ;
		'chr debug_event'(fail(S)), !,
		fail
	    ),
	    (
		'chr debug_event'(exit(S))
	    ;
		'chr debug_event'(redo(S)),
		fail
	    ),	
	    'chr get_mutable'( Post, Mref),
	    ( Post==triggered ->
		'chr update_mutable'( active, Mref)   % catching constraints that did not do anything
	    ;
		true
	    )
	;
	    true
	),
	run_suspensions_d( Next).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%locked:attr_unify_hook(_,_) :- fail.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr lock'(T) :-
	( var(T)
	-> put_attr(T, locked, x)
        ;  term_variables(T,L),
           lockv(L)
	).

lockv([]).
lockv([T|R]) :- put_attr( T, locked, x), lockv(R).

'chr unlock'(T) :-
	( var(T)
	-> del_attr(T, locked)
	;  term_variables(T,L),
           unlockv(L)
	).

unlockv([]).
unlockv([T|R]) :- del_attr( T, locked), unlockv(R).

'chr none_locked'( []).
'chr none_locked'( [V|Vs]) :-
	( get_attr(V, locked, _) ->
		fail
	;
		'chr none_locked'(Vs)
	).

'chr not_locked'(V) :-
	( var( V) ->
  		( get_attr( V, locked, _) ->
			fail
		;
			true
		)
	;
		true
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Eager removal from all chains.
%
'chr remove_constraint_internal'( Susp, Agenda) :-
	arg( 2, Susp, Mref), % ARGXXX
	'chr get_mutable'( State, Mref), 
	'chr update_mutable'( removed, Mref),		% mark in any case
	( compound(State) ->			% passive/1
	    Agenda = []
	; State==removed ->
	    Agenda = []
	%; State==triggered ->
	%     Agenda = []
	;
            Susp =.. [_,_,_,_,_,_,_|Args],
	    term_variables( Args, Vars),
	    'chr default_store'( Global),
	    Agenda = [Global|Vars]
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr newvia_1'(X,V) :-
	( var(X) ->
		X = V
	; 
		nonground(X,V)
	).

'chr newvia_2'(X,Y,V) :- 
	( var(X) -> 
		X = V
	; var(Y) ->
		Y = V
	; compound(X), nonground(X,V) ->
		true
	; 
		compound(Y), nonground(Y,V)
	).

%
% The second arg is a witness.
% The formulation with term_variables/2 is
% cycle safe, but it finds a list of all vars.
% We need only one, and no list in particular.
%
'chr newvia'(L,V) :- nonground(L,V).
%~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-

'chr via_1'(X,V) :-
	( var(X) ->
		X = V
	; atomic(X) ->
		'chr default_store'(V)
	; nonground(X,V) ->
		true
	;
		'chr default_store'(V)
	).

'chr via_2'(X,Y,V) :- 
	( var(X) -> 
		X = V
	; var(Y) ->
		Y = V
	; compound(X), nonground(X,V) ->
		true
	; compound(Y), nonground(Y,V) ->
		true
	;
		'chr default_store'(V)
	).

%
% The second arg is a witness.
% The formulation with term_variables/2 is
% cycle safe, but it finds a list of all vars.
% We need only one, and no list in particular.
%
'chr via'(L,V) :-
	( nonground(L,V) ->
		true
	;
		'chr default_store'(V)
	).

nonground( Term, V) :-
	term_variables( Term, Vs),
	Vs = [V|_].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr novel_production'( Self, Tuple) :-
	arg( 5, Self, Ref), % ARGXXX
	'chr get_mutable'( History, Ref),
	( get_ds( Tuple, History, _) ->
	    fail
	;
	    true
	).

%
% Not folded with novel_production/2 because guard checking
% goes in between the two calls.
%
'chr extend_history'( Self, Tuple) :-
	arg( 5, Self, Ref), % ARGXXX
	'chr get_mutable'( History, Ref),
	put_ds( Tuple, History, x, NewHistory),
	'chr update_mutable'( NewHistory, Ref).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
constraint_generation( Susp, State, Generation) :-
	arg( 2, Susp, Mref), % ARGXXX
	'chr get_mutable'( State, Mref),
	arg( 4, Susp, Gref), % ARGXXX
	'chr get_mutable'( Generation, Gref). 	% not incremented meanwhile 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr allocate_constraint'( Closure, Self, F, Args) :-
	Self =.. [suspension,Id,Mref,Closure,Gref,Href,F|Args], % SUSPXXX
	'chr create_mutable'(0, Gref),
	'chr empty_history'(History),
	'chr create_mutable'(History, Href),
	'chr create_mutable'(passive(Args), Mref),
	'chr gen_id'( Id).

%
% 'chr activate_constraint'( -, +, -).
%
% The transition gc->active should be rare
%
'chr activate_constraint'( Vars, Susp, Generation) :-
	arg( 2, Susp, Mref), % ARGXXX
	'chr get_mutable'( State, Mref),
	'chr update_mutable'( active, Mref),
	( nonvar(Generation) ->			% aih
	    true
	;
	    arg( 4, Susp, Gref), % ARGXXX
	    'chr get_mutable'( Gen, Gref),
	    Generation is Gen+1,
	    'chr update_mutable'( Generation, Gref)
	),
	( compound(State) ->			% passive/1
	    term_variables( State, Vs),
	    'chr none_locked'( Vs),
	    Vars = [Global|Vs],
	    'chr default_store'(Global)
	; State == removed ->			% the price for eager removal ...
	    Susp =.. [_,_,_,_,_,_,_|Args],
	    term_variables( Args, Vs),
	    Vars = [Global|Vs],
	    'chr default_store'(Global)
	;
	    Vars = []
	).

'chr insert_constraint_internal'([Global|Vars], Self, Closure, F, Args) :-
	'chr default_store'(Global),
	term_variables(Args,Vars),
	'chr none_locked'(Vars),
	Self =.. [suspension,Id,Mref,Closure,Gref,Href,F|Args], % SUSPXXX
	'chr create_mutable'(active, Mref),
	'chr create_mutable'(0, Gref),
	'chr empty_history'(History),
	'chr create_mutable'(History, Href),
	'chr gen_id'(Id).

insert_constraint_internal([Global|Vars], Self, Term, Closure, F, Args) :-
	'chr default_store'(Global),
	term_variables( Term, Vars),
	'chr none_locked'( Vars),
	'chr empty_history'( History),
	'chr create_mutable'( active, Mref),
	'chr create_mutable'( 0, Gref),
	'chr create_mutable'( History, Href),
	'chr gen_id'( Id),
	Self =.. [suspension,Id,Mref,Closure,Gref,Href,F|Args]. % SUSPXXX

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr empty_history'( E) :- empty_ds( E).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr gen_id'( Id) :-
	nb_getval(chr_id,Id),
	NextId is Id + 1,
	nb_setval(chr_id,NextId).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% SWI begin
'chr create_mutable'(V,mutable(V)).
'chr get_mutable'(V,mutable(V)).  
'chr update_mutable'(V,M) :- setarg(1,M,V).
%% SWI end

%% SICStus begin
%% 'chr create_mutable'(Val, Mut) :- create_mutable(Val, Mut).
%% 'chr get_mutable'(Val, Mut) :- get_mutable(Val, Mut).
%% 'chr update_mutable'(Val, Mut) :- update_mutable(Val, Mut).
%% SICStus end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SWI begin
'chr default_store'(X) :- nb_getval(chr_global,X).
%% SWI end

%% SICStus begin
%% 'chr default_store'(A) :- global_term_ref_1(A).
%% SICStus end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%'chr sbag_member'( Head, [Head]) :- !.
%'chr sbag_member'( Head, [Head|Tail]).
%'chr sbag_member'( Elem, [_|Tail]) :- 
%    'chr sbag_member'( Elem, Tail).
        
'chr sbag_member'( Element, [Head|Tail]) :-
      sbag_member( Element, Tail, Head).

% auxiliary to avoid choicepoint for last element
        % does it really avoid the choicepoint? -jon
 sbag_member( E, _,	     E).
 sbag_member( E, [Head|Tail], _) :-
 	sbag_member( E, Tail, Head).
 
'chr sbag_del_element'( [],	  _,	[]).
'chr sbag_del_element'( [X|Xs], Elem, Set2) :-
	( X==Elem ->
	    Set2 = Xs
	;
	    Set2 = [X|Xss],
	    'chr sbag_del_element'( Xs, Elem, Xss)
	).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'chr merge_attributes'([],Ys,Ys).
'chr merge_attributes'([X | Xs],YL,R) :-
  ( YL = [Y | Ys] ->
      arg(1,X,XId), % ARGXXX
      arg(1,Y,YId),	 % ARGXXX
       ( XId < YId ->
           R = [X | T],
           'chr merge_attributes'(Xs,YL,T)
       ; XId > YId ->
           R = [Y | T],
           'chr merge_attributes'([X|Xs],Ys,T)
       ;
           R = [X | T],
           'chr merge_attributes'(Xs,Ys,T)
       )    
  ;
       R = [X | Xs]
  ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:- multifile
%	chr:debug_event/2,		% +State, +Event
%	chr:debug_interact/3.		% +Event, +Depth, -Command
/*
'chr debug_event'(Event) :-
	nb_getval(chr_debug,mutable(State)),  % XXX
	( State == off ->
		true
	; %chr:
	    debug_event(State, Event) ->
		true
	; 	debug_event(State,Event)
	).

chr_trace :-
	nb_setval(chr_debug,mutable(trace)).
chr_notrace :-
	nb_setval(chr_debug,mutable(off)).

%	chr_leash(+Spec)
%	
%	Define the set of ports at which we prompt for user interaction

chr_leash(Spec) :-
	leashed_ports(Spec, Ports),
	nb_setval(chr_leash,mutable(Ports)).

leashed_ports(none, []).
leashed_ports(off,  []).
leashed_ports(all,  [call, exit, redo, fail, wake, try, apply, insert, remove]).
leashed_ports(default, [call,exit,fail,wake,apply]).
leashed_ports(One, Ports) :-
	atom(One), One \== [], !,
	leashed_ports([One], Ports).
leashed_ports(Set, Ports) :-
	sort(Set, Ports),		% make unique
	leashed_ports(all, All),
	valid_ports(Ports, All).

valid_ports([], _).
valid_ports([H|T], Valid) :-
	(   memberchk(H, Valid)
	->  true
	;   throw(error(domain_error(chr_port, H), _))
	),
	valid_ports(T, Valid).


:- initialization
   leashed_ports(default, Ports),
   nb_setval(chr_leash, mutable(Ports)).

%	debug_event(+State, +Event)


%debug_event(trace, Event) :-
%	functor(Event, Name, Arity),
%	writeln(Name/Arity), fail.
debug_event(trace,Event) :- 
	Event = call(_), !,
	get_debug_history(History,Depth),
	NDepth is Depth + 1,
	chr_debug_interact(Event,NDepth), 
	set_debug_history([Event|History],NDepth).
debug_event(trace,Event) :- 
	Event = wake(_), !,
	get_debug_history(History,Depth),
	NDepth is Depth + 1,
	chr_debug_interact(Event,NDepth), 
	set_debug_history([Event|History],NDepth).
debug_event(trace,Event) :-
	Event = redo(_), !,
	get_debug_history(_History, Depth),
	chr_debug_interact(Event, Depth).
debug_event(trace,Event) :- 
	Event = exit(_),!,
	get_debug_history([_|History],Depth),
	chr_debug_interact(Event,Depth),
	NDepth is Depth - 1,
	set_debug_history(History,NDepth). 
debug_event(trace,Event) :- 
	Event = fail(_),!,
	get_debug_history(_,Depth),
	chr_debug_interact(Event,Depth). 
debug_event(trace, Event) :-
	Event = remove(_), !,
	get_debug_history(_,Depth),
	chr_debug_interact(Event, Depth).
debug_event(trace, Event) :-
	Event = insert(_), !,
	get_debug_history(_,Depth),
	chr_debug_interact(Event, Depth).
debug_event(trace, Event) :-
	Event = try(_,_,_,_), !,
	get_debug_history(_,Depth),
	chr_debug_interact(Event, Depth).
debug_event(trace, Event) :- 
	Event = apply(_,_,_,_), !,
	get_debug_history(_,Depth),
	chr_debug_interact(Event,Depth). 

debug_event(skip(_,_),Event) :- 
	Event = call(_), !,
	get_debug_history(History,Depth),
	NDepth is Depth + 1,
	set_debug_history([Event|History],NDepth).
debug_event(skip(_,_),Event) :- 
	Event = wake(_), !,
	get_debug_history(History,Depth),
	NDepth is Depth + 1,
	set_debug_history([Event|History],NDepth).
debug_event(skip(SkipSusp,SkipDepth),Event) :- 
	Event = exit(Susp),!,
	get_debug_history([_|History],Depth),
	( SkipDepth == Depth,
	  SkipSusp == Susp -> 
		set_chr_debug(trace),
		chr_debug_interact(Event,Depth)
	;
		true
	),
	NDepth is Depth - 1,
	set_debug_history(History,NDepth). 
debug_event(skip(_,_),_) :- !,
	true.

%	chr_debug_interact(+Event, +Depth)
%	
%	Interact with the user on Event that took place at Depth.  First
%	calls chr:debug_interact(+Event, +Depth, -Command) hook. If this
%	fails the event is printed and the system prompts for a command.

chr_debug_interact(Event, Depth) :-
	%chr:
	debug_interact(Event, Depth, Command), !,
	handle_debug_command(Command,Event,Depth).
chr_debug_interact(Event, Depth) :-
	print_event(Event, Depth),
	(   leashed(Event)
	->  ask_continue(Command)
	;   Command = creep
	),
	handle_debug_command(Command,Event,Depth).

leashed(Event) :-
	functor(Event, Port, _),
	nb_getval(chr_leash, mutable(Ports)),
	memberchk(Port, Ports).

ask_continue(Command) :-
	print_message(debug, chr(prompt)),
	get_single_char(CharCode),
	(   CharCode == -1
	->  Char = end_of_file
	;   char_code(Char, CharCode)
	),
	(   debug_command(Char, Command)
	->  print_message(debug, chr(command(Command)))
	;   print_message(help, chr(invalid_command)),
	    ask_continue(Command)
	).


'chr debug command'(Char, Command) :-
	debug_command(Char, Command).

debug_command(c, creep).
debug_command(' ', creep).
debug_command('\r', creep).
debug_command(s, skip).
debug_command(g, ancestors).
debug_command(n, nodebug).
debug_command(a, abort).
debug_command(f, fail).
debug_command(b, break).
debug_command(?, help).
debug_command(h, help).
debug_command(end_of_file, exit).


handle_debug_command(creep,_,_) :- !.
handle_debug_command(skip, Event, Depth) :- !,
	Event =.. [Type|Rest],
	( Type \== call,
	  Type \== wake ->
		handle_debug_command('c',Event,Depth)
	;
		Rest = [Susp],
		set_chr_debug(skip(Susp,Depth))
	).
	
handle_debug_command(ancestors,Event,Depth) :- !,
	print_chr_debug_history,
	chr_debug_interact(Event,Depth).	
handle_debug_command(nodebug,_,_) :- !,
	chr_notrace.
handle_debug_command(abort,_,_) :- !,
	abort.
handle_debug_command(exit,_,_) :- !,
	halt.
handle_debug_command(fail,_,_) :- !,
	fail.
handle_debug_command(break,Event,Depth) :- !,
	break,
	chr_debug_interact(Event,Depth).
handle_debug_command(help,Event,Depth) :- !,
	print_message(help, chr(debug_options)),
	chr_debug_interact(Event,Depth).	
handle_debug_command(Cmd, _, _) :- 
	throw(error(domain_error(chr_debug_command, Cmd), _)).

print_chr_debug_history :-
	get_debug_history(History,Depth),
	print_message(debug, chr(ancestors(History, Depth))).

print_event(Event, Depth) :-
	print_message(debug, chr(event(Event, Depth))).

%	{set,get}_debug_history(Ancestors, Depth)
%	
%	Set/get the list of ancestors and the depth of the current goal.

get_debug_history(History,Depth) :-
	nb_getval(chr_debug_history,mutable(History,Depth)).

set_debug_history(History,Depth) :-
	nb_getval(chr_debug_history,Mutable),
	setarg(1,Mutable,History),
	setarg(2,Mutable,Depth).

set_chr_debug(State) :-
	nb_getval(chr_debug,Mutable),
	setarg(1,Mutable,State).

'chr chr_indexed_variables'(Susp,Vars) :-
        Susp =.. [_,_,_,_,_,_,_|Args],
	term_variables(Args,Vars).
*/

:- module(hprolog,
	  [ append/2,		        % +ListOfLists, -List
	    substitute/4,		% +OldVal, +OldList, +NewVal, -NewList
	    memberchk_eq/2,		% +Val, +List
	    intersect_eq/3,		% +List1, +List2, -Intersection
	    list_difference_eq/3,	% +List, -Subtract, -Rest
	    take/3,			% +N, +List, -FirstElements
	    drop/3,			% +N, +List, -LastElements
	    max_go_list/2,		% +List, -Max
	    or_list/2,			% +ListOfInts, -BitwiseOr
	    sublist/2,			% ?Sublist, +List
	    bounded_sublist/3,		% ?Sublist, +List, +Bound
	    min_list/2,
	    chr_delete/3,
	    init_store/2,
	    get_store/2,
	    update_store/2,
	    make_get_store_goal/3,
	    make_update_store_goal/3,
	    make_init_store_goal/3,

	    empty_ds/1,
	    ds_to_list/2,
	    get_ds/3,
	    put_ds/4

	    
	  ]).

:- use_module(library(lists)).
:- use_module(library(assoc)).

empty_ds(DS) :- empty_assoc(DS).
ds_to_list(DS,LIST) :- assoc_to_list(DS,LIST).
get_ds(A,B,C) :- get_assoc(A,B,C).
put_ds(A,B,C,D) :- put_assoc(A,B,C,D).


init_store(Name,Value) :- nb_setval(Name,Value).

get_store(Name,Value) :- nb_getval(Name,Value).

update_store(Name,Value) :- b_setval(Name,Value).

make_init_store_goal(Name,Value,Goal) :- Goal = nb_setval(Name,Value).

make_get_store_goal(Name,Value,Goal) :- Goal = nb_getval(Name,Value).

make_update_store_goal(Name,Value,Goal) :- Goal = b_setval(Name,Value).


		 /*******************************
		 *      MORE LIST OPERATIONS	*
		 *******************************/

%	append(+ListOfLists, -List)
%	
%	Convert a one-level nested list into a flat one.  E.g.
%	append([[a,b], [c]], X) --> X = [a,b,c].  See also
%	flatten/3.

append([],[]).
append([X|Xs],L) :-
	append(X,T,L),
	append(Xs,T).


%	substitute(+OldVal, +OldList, +NewVal, -NewList)
%	
%	Substitute OldVal by NewVal in OldList and unify the result
%	with NewList.  JW: Shouldn't this be called substitute_eq/4?
%'

substitute(_, [], _, []) :- ! .
substitute(X, [U|Us], Y, [V|Vs]) :-
        (   X == U
	->  V = Y,
            substitute(X, Us, Y, Vs)
        ;   V = U,
            substitute(X, Us, Y, Vs)
        ).

%	memberchk_eq(+Val, +List)
%	
%	Deterministic check of membership using == rather than
%	unification.

memberchk_eq(X, [Y|Ys]) :-
   (   X == Y
   ->  true
   ;   memberchk_eq(X, Ys)
   ).


%	list_difference_eq(+List, -Subtract, -Rest)
%	
%	Delete all elements of Subtract from List and unify the result
%	with Rest.  Element comparision is done using ==/2.

list_difference_eq([],_,[]).
list_difference_eq([X|Xs],Ys,L) :-
	(   memberchk_eq(X,Ys)
	->  list_difference_eq(Xs,Ys,L)
	;   L = [X|T],
	    list_difference_eq(Xs,Ys,T)
	).

%	intersect_eq(+List1, +List2, -Intersection)
%	
%	Determine the intersection of two lists without unifying values.

intersect_eq([], _, []).
intersect_eq([X|Xs], Ys, L) :-
	(   memberchk_eq(X, Ys)
	->  L = [X|T],
	    intersect_eq(Xs, Ys, T)
	;   intersect_eq(Xs, Ys, L)
	).


%	take(+N, +List, -FirstElements)
%	
%	Take the first  N  elements  from   List  and  unify  this  with
%	FirstElements. The definition is based   on the GNU-Prolog lists
%	library. Implementation by Jan Wielemaker.

take(0, _, []) :- !.
take(N, [H|TA], [H|TB]) :-
	N > 0,
	N2 is N - 1,
	take(N2, TA, TB).

%	Drop the first  N  elements  from   List  and  unify  the remainder  with
%	LastElements.

drop(0,LastElements,LastElements) :- !.
drop(N,[_|Tail],LastElements) :-
	N > 0,
	N1 is N  - 1,
	drop(N1,Tail,LastElements).

%	max_go_list(+List, -Max)
%	
%	Return the maximum of List in the standard order of terms.

max_go_list([H|T], Max) :-
	max_go_list(T, H, Max).

max_go_list([], Max, Max).
max_go_list([H|T], X, Max) :-
        (   H @=< X
	->  max_go_list(T, X, Max)
        ;   max_go_list(T, H, Max)
        ).

%	or_list(+ListOfInts, -BitwiseOr)
%	
%	Do a bitwise disjuction over all integer members of ListOfInts.

or_list(L, Or) :-
	or_list(L, 0, Or).

or_list([], Or, Or).
or_list([H|T], Or0, Or) :-
	Or1 is H \/ Or0,
	or_list(T, Or1, Or).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sublist(L, L).
sublist(Sub, [H|T]) :-
	'$sublist1'(T, H, Sub).

'$sublist1'(Sub, _, Sub).
'$sublist1'([H|T], _, Sub) :-
	'$sublist1'(T, H, Sub).
'$sublist1'([H|T], X, [X|Sub]) :-
	'$sublist1'(T, H, Sub).

bounded_sublist(Sublist,_,_) :-
	Sublist = [].
bounded_sublist(Sublist,[H|List],Bound) :-
	Bound > 0,
	(
		Sublist = [H|Rest],
		NBound is Bound - 1,
		bounded_sublist(Rest,List,NBound)
	;
		bounded_sublist(Sublist,List,Bound)
	).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
min_list([H|T], Min) :-
	'$min_list1'(T, H, Min).

'$min_list1'([], Min, Min).
'$min_list1'([H|T], X, Min) :-
        (   H>=X ->
            '$min_list1'(T, X, Min)
        ;   '$min_list1'(T, H, Min)
        ).

chr_delete([], _, []).
chr_delete([H|T], X, L) :-
        (   H==X ->
            chr_delete(T, X, L)
        ;   L=[H|RT],
            chr_delete(T, X, RT)
        ).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% SWI primitives on global variable 
% b_setval(chr_global,Y):-true :
%     global_heap_set(chr_global,Y).
b_setval(X,Y):-
    global_heap_set(X,Y).

%:- dynamic swi_global_var_init/2.

%nb_setval(chr_global,Y):-true :
%    global_heap_set(chr_global,Y).
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

