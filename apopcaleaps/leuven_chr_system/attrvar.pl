/*  built-ins on attributed variables as in Sicstus and SWI-Prolg */
/*  by Neng-Fa Zhou, March 2006                                   */

/* X is an attributed variable */
attvar(X):-
    susp_var(X),
    susp_attached_term(X,$attrs(_)).

/* Set the attribute Attr of X to Value. Undone on backtracking */
put_attr(X,Attr,Value):-
    var(X) , !,
    ((susp_var(X),susp_attached_term(X,$attrs(AttrValues)))->
     (get_attribute_pair(AttrValues,Attr,OldPair)
      ->
      setarg(2,OldPair,Value)
      ;
      attach((Attr,Value),AttrValues))
     ;
     AttachedTerm=$attrs([(Attr,Value)|_]),
     susp_attach_term(X,AttachedTerm),
     generate_agent_to_call_hook(X,AttachedTerm)
     ).
put_attr(X,Attr,Value):-
    throw(illegal_arguments(put_attr(X,Attr,Value))).

get_attribute_pair(AttrValues,Attr,Pair):-var(AttrValues) , !,  fail.
get_attribute_pair([Pair1|AttrValues],Attr,Pair):-Pair1=(Attr,_), !,  
    Pair=Pair1.
get_attribute_pair([_|AttrValues],Attr,Pair):-
    get_attribute_pair(AttrValues,Attr,Pair).

generate_agent_to_call_hook(X,AttachedTerm),AttachedTerm=$attrs(AttrValues),{ins(X)} =>
    call_hook(AttrValues,X).

call_hook(AttrValues,X):-
    var(AttrValues),!.
call_hook([(Attr,Value)|AttrValues],X):-
    % attr_unify_hook(Attr,Value,X),
    attr_unify_hook(Value,X), % XXX no module system available
    call_hook(AttrValues,X).

/* Get the attribute value for Attr of X. */
get_attr(X,Attr,Value):-
    susp_var(X), !,  
    susp_attached_term(X,$attrs(AttrValues)),
    get_attribute_pair(AttrValues,Attr,Pair),
    Pair=(_,Value).

/* Delete the attribute Attr from the attributed variable X. */
del_attr(X,Attr):-
    susp_var(X), !,  
    susp_attached_term(X,AttachedTerm),
    AttachedTerm=$attrs(AttrValues),
    delete_attribute(AttrValues,Attr,NewAttrValues),
    setarg(1,AttachedTerm,NewAttrValues).
del_attr(X,Attr):-
    throw(illegal_arguments,del_attr(X,Attr)).

delete_attribute(AttrValues,Attr,NewAttrValues):-var(AttrValues) , !, NewAttrValues=AttrValues.
delete_attribute([(Attr,_)|AttrValues],Attr,NewAttrValues):- !,
    NewAttrValues=AttrValues.
delete_attribute([_|AttrValues],Attr,NewAttrValues):-
    delete_attribute(AttrValues,Attr,NewAttrValues).

attr_unify_hook(Module,Value,X):-
    attr_unify_hook(Value,X).

/*
test the primitives. From SWI users' manual
mydomain(X, Dom) :-
        var(Dom), !,
        get_attr(X, mydomain, Dom).
mydomain(X, List) :-
        sort(List, Mydomain),
        put_attr(Y, mydomain, Mydomain),
        X = Y.

%       An attributed variable with attribute value Mydomain has been
%       assigned the value Y


attr_unify_hook(mydomain,Mydomain, Y) :-
        (   get_attr(Y, mydomain, Dom2)
        ->  oset_int(Mydomain, Dom2, NewMydomain),
            (   NewMydomain == []
            ->  fail
            ;   NewMydomain = [Value]
            ->  Y = Value
            ;   put_attr(Y, mydomain, NewMydomain)
            )
        ;   var(Y)
        ->  put_attr( Y, mydomain, Mydomain )
        ;   memberchk(Y, Mydomain)
        ).     

memberchk(X,Y):-member(X,Y),!.
*/
