
run :- tell(data), run(1).

run(N) :- findall(T,data(N,T),TList),
          sum(TList,Sum),
          min(TList,Min),
          max(TList,Max),
          length(TList,K),
          K>0,
          Avg is Sum/K,
          format('~w~t~w~t~w~t~w~t~n',[N,Avg,Min,Max]),
          N1 is N+1,
          run(N1).
          

sum([],0).
sum([X|Xs],N) :- sum(Xs,A), N is A+X.
max([],0).
max([X|Xs],N) :- max(Xs,A), N is max(A,X).
min([X],X).
min([X|Xs],N) :- min(Xs,A), N is min(A,X).


:- include(data).