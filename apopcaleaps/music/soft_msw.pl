
% Backtrackable switch
% this is based on the definition of msw/2, but rewritten so that
% the probabilistic choice is not committed to.
soft_msw(Sw,Val) :-
    $pp_get_distribution(Sw,Values,Pbs), !,
    zip(Values,Pbs,Candidates),
    soft_choose(Candidates,Val).

zip([],[],[]).
zip([Val|Vals],[Prob|Probs],[Val-Prob|Rest]) :- zip(Vals,Probs,Rest).

soft_choose([],Val) :- !, fail.
soft_choose(Candidates,V) :-
    zip(Vals,Probs,Candidates),
    sumlist(Probs,Sum),
    Sum > 0,
    random_uniform(Sum,R),
    $pp_choose(Probs,R,Vals,Val,Prob),
    delete(Candidates,Val-Prob,OtherOptions),
    (V=Val ; soft_choose(OtherOptions,V)).
