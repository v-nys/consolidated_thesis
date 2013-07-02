

%run :- diff(s(s(x)),s(s(y)),1).

run :- writeln(data1),
       tell(data1), 
        run([nr,s,u],1), told,
       writeln(data2),
       tell(data2), 
        run([s,u],1), told,
       writeln(data3),
       tell(data3), 
        run([u],1), told,
       writeln(data4),
       tell(data4), 
        run([s],1), told,
       writeln(data5),
       tell(data5), 
        run([nr,s],1), told,
       writeln(data6),
       tell(data6), 
        run([nr,u],1), told,
       writeln(data8),
       tell(data8), 
        run([nr],1), told.

run(X,N) :- findall(T,data(X,N,T,_),TList),
          sum(TList,Sum),
          min(TList,Min),
          max(TList,Max),
          length(TList,K),
          K>0,
          Avg is Sum/K,
          format('~w~t~w~t~w~t~w~t~n',[N,Avg,Min,Max]),
          N1 is N+1,
          run(X,N1).
run(_,_).          

sum([],0).
sum([X|Xs],N) :- sum(Xs,A), N is A+X.
max([],0).
max([X|Xs],N) :- max(Xs,A), N is max(A,X).
min([X],X).
min([X|Xs],N) :- min(Xs,A), N is min(A,X).


diff(X,Y,N) :- 
          findall(T,data(X,N,T,_),T1List),
          findall(T,data(Y,N,T,_),T2List),
          sum(T1List,Sum1),
          min(T1List,Min1),
          max(T1List,Max1),
          sum(T2List,Sum2),
          min(T2List,Min2),
          max(T2List,Max2),
          length(T1List,K),
          K>0,
          Sum is Sum1-Sum2,
          Min is Min1-Min2,
          Max is Max1-Max2,
          Avg is Sum/K,
          format('~w~t~w~t~w~t~w~t~n',[N,Avg,Min,Max]),
          N1 is N+1,
          diff(X,Y,N1).
diff(_,_,_).          


:- include(results).