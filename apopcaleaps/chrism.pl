% Copyright 2009-2010, Jon Sneyers
% 
% This file is part of CHRiSM.
% 
% CHRiSM is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% CHRiSM is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with CHRiSM.  If not, see <http://www.gnu.org/licenses/>.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CHRiSM COMPILER       - converts a CHRiSM program to a CHR(PRISM) program
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%:- op(1106,fx,handler).
%:- op(1106,fx,constraints).
%:- op(1105,xfx,@).
%:- op(1104,xfx,[<=>,==>]).
%:- op(1101,xfx,\).
:- op(1180, xfx, ==>).
:- op(1180, xfx, <=>).
:- op(1150, fx, chrism).
:- op(1150, fx, constraints).
:- op(1150, fx, chr_constraint).
:- op(1150, fx, handler).
:- op(1150, fx, rules).
:- op(1100, xfx, \).
:- op(1200, xfx, @).			% values from hProlog
:- op(1190, xfx, pragma).		% values from hProlog
:- op( 500, yfx, #).			% values from hProlog
%:- op(1100, xfx, '|').
:- op(1150, fx, chr_type).
:- op(1130, xfx, --->).
:- op(900, fx, (?)).

:- op(1050,xfy,':').
:- op(1102,xfy,'??').
:- op(1102,fx,'??').
:- op(900,fx,cond).
:- op(1150,fx,ccall).





:- op(1160,xfx,times).
:- op(1102,xfx,[<==>,===>]).    % in case learning stuff is included in .pchr file
:- op(1150,fx,sample).
:- op(1150,fx,prob).
:- op(900,fx,'~').

chrism_compile(File,OutFile) :-
        open(OutFile,write,OutStream),
        assert(output_stream(OutStream)),
        parse_file(File),
        close(OutStream).

fatal_error(X) :- 
        told, 
%        tell('/dev/stderr'), nl, 
%        writeln('FATAL ERROR:'),writeln(X),
%        told,
        tell('chrism_fatal_error'),
        writeln(X),
        told,
        halt(1).        % exit codes do not seem to work

syntax_error :- told, halt.

parse_file(File) :-
        open(File,read,Stream),
        parse_rules(Stream,1),
        close(Stream).

parse_rules(Stream,Counter) :-
        tell('chrism_syntax_error'),
        catch(read_term(Stream,Term,[]),_,syntax_error),
        told, 
        ( Term = end_of_file ->
                true,system('rm chrism_syntax_error')
        ; parse_rule(Term,Counter,Counter1) ->
%            tell('/dev/stderr'), writeln(Counter-Term), told,
            parse_rules(Stream,Counter1)
        ; fatal_error('This should not happen')).



parse_rule('<=>'(H,GB),N,N1) :-
        ( prob_param(H,Head,Param) ->
            (nonvar(GB), GB = '|'(G,B) ->
                NGB = '|'(G,NB)
            ;
                NGB = NB,
                B = GB
            ),
            make_experiment(N,[yes,no],Param,_Name,X,Exp),
            add_susp_ids_removals(Head,NHead,RemoveCode),
            NB = ( Exp, (X=1 -> 
                                (RemoveCode ->
                                        true
                                ;
                                        writeln(error_internal),
                                        halt
                                ),
                                B         
                        ;
                                true
                        )
                ),
            
            N0 is N+1,
            parse_rule('==>'(NHead,NGB),N0,N1)
        ;
          process_guardbody(GB,NGB,N,N1),
          writeclause('<=>'(H,NGB))
        ).
parse_rule('==>'(H,GB),N,N1) :-
        ( H = '??'(P,Head) ->
            (nonvar(GB), GB = '|'(G,B) ->
                NGB = '|'(G,(P ?? B ; true))
          ;
                NGB = (P ?? GB ; true)
            ),
            parse_rule('==>'(Head,NGB),N,N1)
        ; H = '??'(Head) ->
            (nonvar(GB), GB = '|'(G,B) ->
                NGB = '|'(G,(?? B ; true))
          ;
                NGB = (?? GB ; true)
            ),
            parse_rule('==>'(Head,NGB),N,N1)
        ;
          process_guardbody(GB,NGB,N,N1),
          writeclause('==>'(H,NGB))
        ).
parse_rule((chrism X),N,N) :-
        writeclause((:- chr_constraint X)).
parse_rule((:- chrism X),N,N) :-
        writeclause((:- chr_constraint X)).
parse_rule(Term,N,N) :-
        writeclause(Term).



add_susp_ids_removals(Head,NHead,RemoveCode) :-
        (Head = (KHead \ RHead) ->
                add_susp_ids_removals2(RHead,RNHead,RemoveCode),
                NHead = (KHead, RNHead)
        ;
                add_susp_ids_removals2(Head,NHead,RemoveCode)
        ).
add_susp_ids_removals2((H,Hs),(NH,NHs),RC) :-
        !,
        add_susp_ids_removals2(H,NH,RC1),
        add_susp_ids_removals2(Hs,NHs,RC2),
        RC = (RC1,RC2).

add_susp_ids_removals2(H,H#susp(ID),remove_chr_constraint(ID)).



add_to_kept(X,(KH \ RH),(X,KH \ RH)) :- !.
add_to_kept(X,RH,(X \ RH)).


process_guardbody(GB,NGB,N,N1) :-
        ( nonvar(GB), GB = '??'(GP,B), nonvar(GP), GP = '|'(G,P) ->
                process_body('??'(P,B),NB,N,N1),
                NGB = '|'(G,NB)
        ; nonvar(GB), GB = '|'(G,B) ->
                process_body(B,NB,N,N1),
                NGB = '|'(G,NB)
        ;
                process_body(GB,NGB,N,N1)
        ).

process_body(B,NB,N,N1) :-
        (annotated_disj(B,Disjuncts,Probs) ->
                sum(Probs,S),
                (S >= 1 ->
                        RealProbs = Probs,
                        RealDisjuncts = Disjuncts
                ;
                        RestProb is 1-S,  % otherwise empty (true) disjunct
                        append(Probs,[RestProb],RealProbs),
                        append(Disjuncts,[true],RealDisjuncts)
                ),
                make_experiment(N,RealDisjuncts,none,Name,X,Exp),
                Set_Sw = (:- set_sw(Name,RealProbs)),
                writeclause(Set_Sw),
                N0 is N+1,
                generate_ad_code(RealDisjuncts,X,1,NB2,N0,N1),
                NB = (Exp, NB2)
        ; param_annotated_disj(B,Disjuncts,Params) ->
                make_experiment(N,Disjuncts,Params,Name,X,Exp),
                N0 is N+1,
                generate_ad_code(Disjuncts,X,1,NB2,N0,N1),
                NB = (Exp, NB2)
        ; B = (X,Y) ->
                NB = (NX,NY),
                process_body(X,NX,N,N0),
                process_body(Y,NY,N0,N1)
        ; B = (X -> Y) ->
                NB = (NX -> NY),
                process_body(X,NX,N,N0),
                process_body(Y,NY,N0,N1)
        ; B = chrism_condition(Cond,Body) ->
                NB = chrism_condition(Cond,NBody),
                process_body(Body,NBody,N,N1)
        ;
                NB = B,
                N1 = N
        ).

make_experiment(N,Disjuncts,Params,Name,X,Exp) :-
        term2atom(N,NA),
        atom_concat(experiment,NA,FName),
        Exp1 = msw(Name,X),
        length(Disjuncts,K),
        (Params == none ->
                Name = FName,
                Exp = Exp1
        ; ground(Params), Params \= eval(_), (number(Params) ; functor(Params,_,0)) ->
                (number(Params), Params =< 1.0 ->
                        Name = FName,
                        RestProb is 1-Params,
                        ( K > 2 ->
                                fatal_error('More than two disjuncts; expected only two')
                        ;
                                true
                        ),
                        Set_Sw = (:- set_sw(Name,[Params,RestProb])),
                        writeclause(Set_Sw),
                        Exp = Exp1
%                ;
%                        fatal_error('Expected a number =< 1 or parameter for probability '(Params))
                ; functor(Params,_,0) ->
                        Name = Params,
                        Exp = Exp1
                ;
                        fatal_error('Expected a number =< 1 or experiment name for probability '(Params))
                )
        ; nonvar(Params), Params = eval(Expr) ->
                ( K > 2 ->
                        fatal_error('More than two disjuncts; expected only two')
                ;
                        true
                ),
                Name = FName,
                Exp = (V1 is Expr, V2 is 1-V1, set_sw(Name,[V1,V2]), Exp1)
        ; args_eval(Params,Eval,FName,Name) ->
                (Eval == true ->
                        Exp = Exp1
                ;
                        Exp = (Eval,Exp1)
                )
        ;
                fatal_error('Could not parse probability parameter '(Params))
        ),
        Declaration = (values_x(Name, [1 - K])),
        writeclause(Declaration).

args_eval(P,Eval,FName,Name) :-
	(nonvar(P), functor(P,F,_), F \== cond, F \== '.' ->
	    P =.. [_|PArgs],
	    args_eval(PArgs,Args,Eval),
	    Name =.. [F|Args]
	;
	    args_eval(P,Args,Eval),
	    Name =.. [FName|Args]
	).
args_eval(P,Args,Eval) :-
        (var(P) ->
                Args = [P],
                Eval = true
        ; P = cond(X) ->
                Args = [Result],
                Eval = ( X -> Result = yes ; Result = no)
        ; P = [] ->
    		Args = [],
    		Eval = true
        ; ground(P) ->
                Args = [P],
                Eval = true
        ; (P = [A|B] ; P = (A,B)) ->
                args_eval(A,Args1,Eval1),
                args_eval(B,Args2,Eval2),
                append(Args1,Args2,Args),
                conjunction(Eval1,Eval2,Eval)
        ; 	fatal_error('Could not parse probability parameter argument '(P))
        ).

conjunction(true,A,A) :- !.
conjunction(A,true,A) :- !.
conjunction(A,B,(A,B)).

annotated_disj((Disj : Prob),[Disj],[Prob]) :-
        ground(Prob).
annotated_disj((DP ; RDP),Disjuncts,Probs) :-
        annotated_disj(DP,D1,P1),
        annotated_disj(RDP,D2,P2),
        append(D1,D2,Disjuncts),
        append(P1,P2,Probs).

sum([],0).
sum([X|Xs],S) :- sum(Xs,S1), S is S1+X.
generate_ad_code([],_X,_N,fail,ZN,ZN).
generate_ad_code([D|RD],X,N,Body,ZN,ZN1) :-
        process_body(D,ND,ZN,ZN0),
        Body = ( (X = N -> ND ; Otherwise) ),
        N1 is N+1,
        generate_ad_code(RD,X,N1,Otherwise,ZN0,ZN1).


prob_param(H,Head,Param) :-
        H = '??'(Param,Head).
prob_param(H,Head,none) :-
        H = '??'(Head).

param_annotated_disj(B,Disjuncts,Params) :-
        prob_param(B,Ds,Params),
        disj2list(Ds,DisjunctsList),
        (DisjunctsList = [OnlyOne] ->
                Disjuncts = [OnlyOne,true]
        ;
                Disjuncts = DisjunctsList
        ).

disj2list(Disj,L) :-
  disj2list(Disj,L,[]).

disj2list(Disj,L,T) :-
  Disj = (G1;G2), !,
  disj2list(G1,L,T1),
  disj2list(G2,T1,T).
disj2list(G,[G | T],T).

writeclause(C) :-
    output_stream(OutStream),
    portray_clause(OutStream,C).

    %writeq(C), write('.'), nl.
