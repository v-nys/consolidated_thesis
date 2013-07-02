% Benchmarking stuff
maketest(N) :- (t(N) <==> Result) ->
                writeq(instance(N,Result)), write('.'), nl,      %'
                fail.
maketest(N) :- N < 100, N1 is N+1, maketest(N1).


ftest :- ftest(1,[[nr,s,u],[s,u],[u],[s],[nr,s],[nr,u]],1,10).
ftest0 :- ftest(1,[x],1,1).
ftest1 :- ftest(1,[s(x)],1,1).
ftest2 :- ftest(1,[s(s(x))],1,1).
ftest3 :- ftest(1,[s(s(s(x)))],1,1).
ftest(N,Xs,K,KM) :- 
%           write(making_instance(N)),write('.'),nl, %'
           finstance(N,Result),
%           write(trying(N)),write('.'),nl, %'
%           writeln(fullresult(Result)),
           member(X,Xs),
           cputime(T1),
           log_prob(((failrules(X),w2(N) <==> Result)),P),
           cputime(T2),
           T is T2-T1,
           format('data(~w,~w,~w,~w).~n',[X,N,T,P]),      %'
%           format('prob(~w,~w).~n',[N,P]),      %'
           fail.
ftest(N,X,K,KM) :- K<KM, K1 is K+1, ftest(N,X,K1,KM).
ftest(N,X,KM,KM) :- N<50, N1 is N+1, ftest(N1,X,1,KM).           
%ftest(_,X,K) :- ftest(1,X).

:- dynamic foo/1, ddd/1.
finstance(N,R) :- retractall(foo(_)),
                  (w2(N) <==> X) ->
%                  write_notes,
                  assert(foo(X)),
                  fail.
finstance(_,R) :- foo(R).

fr :- failrules([nr,s,u]).
pt(Q) :- finstance2(Q,R), 
          writeln(trying_log_prob((fr,Q<==>R))),
          log_prob((fr,Q<==>R)).
finstance2(Q,R) :- retractall(foo(_)),
                  (Q <==> X) ->
%                  write_notes,
                  assert(foo(X)),
                  fail.
finstance2(_,R) :- foo(R).


test :- test(1).
test(N) :- instance(N,Result),
           cputime(T1),
           log_prob(((t(N) <==> Result)),P),
           cputime(T2),
           T is T2-T1,
           format('data(~w,~w).~n',[N,T]),      %'
           fail.
test(N) :- N1 is N+1, test(N1).           

ttest :- ttest(1).
ttest(N) :- instance(N,Result),
           cputime(T1),
           log_prob(((t(N) <==> Result)),P),
           cputime(T2),
           T is T2-T1,
           format('data(~w,~w,~w).~n',[N,T,P]),      %'
           fail.
ttest(N) :- N1 is N+1, ttest(N1).           


ptest :- ptest(1).
ptest(N) :- instance(N,Result),
            only_observables(Result,OResult),
           cputime(T1),
           log_prob(((s(N) ===> OResult)),P),
           cputime(T2),
           T is T2-T1,
           format('data(~w,~w).~n',[N,T]),      %'
           fail.
ptest(N) :- N1 is N+1, ptest(N1).           

only_observables((A,B),X) :-
        !,
        only_observables(A,X1),
        only_observables(B,X2),
        (X1 = true ->
                X = X2
        ; X2 = true ->
                X = X1
        ;
                X = (X1,X2)
        ).
only_observables(A,A) :-
        functor(A,F,N),
        observable(F/N), !.
only_observables(A,true).
        
observable(note/5).
observable(octave/5).
observable(beat/5).
observable(tied/4).

