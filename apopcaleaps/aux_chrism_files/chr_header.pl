
:- chr_option(debug,off).
:- chr_option(optimize,full).
:- chr_option(all_ground,on).

% switch off the expensive optimizations
:- chr_option(guard_simplification,off).
:- chr_option(check_impossible_rules,off).
:- chr_option(occurrence_subsumption,off).

% switch off some other optimizations
:- chr_option(late_allocation,off).
:- chr_option(storage_analysis,off).

:- chr_option(observation,regular).


% comment out for slower compilation, faster execution
:- chr_option(reorder_heads,off).

:- op(1102,xfx,[<==>,===>,<=/=>,==/=>]).

:- op(1160,xfx,times).
:- op(1150,fx,sample).
:- op(1150,fx,prob).
:- op(900,fx,'~').

:- chr_constraint result_status/1, result/1, cleanup/0.

result((A,B)) <=> result(A), result(B).
