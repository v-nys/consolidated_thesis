%:-set_prolog_flag(gc_threshold,100000).
:-set_prolog_flag(redefine_warning,on).
:-op(600,xfy,':').
:- op(1180, xfx, ==>).
:- op(1180, xfx, <=>).
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

:-include('run_bp.pl').

main:-

go:-
    chr_init,
    load_module(chr_translate_bootstrap),
    chr_compile_step1('chr_translate_bootstrap1.chr','chr_translate_bootstrap1.pl'),
    nl,writeln('next s1'),
    statistics,halt.

s1:-
    chr_init,
    load_module(chr_translate_bootstrap1),
    chr_compile_step2('chr_translate_bootstrap1.chr','chr_translate_bootstrap1.pl'),
    nl,writeln('next s2'),
    statistics,halt.

s2:-
    chr_init,
    load_module(chr_translate_bootstrap1),
    chr_compile_step2('chr_translate_bootstrap2.chr','chr_translate_bootstrap2.pl'),
    nl,writeln('next s3'),
    statistics,halt.

s3:-
    chr_init,
    load_module(chr_translate_bootstrap2),
    chr_compile_step3('chr_translate_bootstrap2.chr','chr_translate_bootstrap2.pl'),
    nl,writeln('next s4'),
    statistics,halt.

s4:-
    chr_init,
    load_module(chr_translate_bootstrap2),
    chr_compile_step3('guard_entailment.chr','guard_entailment.pl'),
    nl,writeln('next s5'),
    statistics,halt.

s5:-
    chr_init,
    load_module(chr_translate_bootstrap2),
    chr_compile_step3('chr_translate.chr','chr_translate.pl'),
    nl,writeln('next s6'),
    statistics,halt.

s6:-
    chr_init,
    load_module(chr_translate),
    load_module(chr_compiler_options),
    load_module(guard_entailment),
    chr_compile_step4('guard_entailment.chr','guard_entailment.pl'),
    nl,writeln('next s7'),
    statistics,halt.

s7:-
    chr_init,
    load_module(chr_compiler_options),
    consult(chr_translate),
    load_module(guard_entailment),
    chr_compile_step4('chr_translate.chr','chr_translate.pl'),
    statistics,halt.

chr_compile(In,Out) :-
    chr_init,
    load_module(chr_compiler_options),
    consult(chr_translate),
    load_module(guard_entailment),
    chr_compile_step4(In,Out),
    statistics,halt.

clean:-
    system('rm chr_translate_bootstrap1.pl'),
    system('rm chr_translate_bootstrap2.pl'),
    system('rm guard_entailment.pl'),
    system('rm chr_translate.pl').

t:-
    chr_compile('fib.chr','fib.pl'),
    load_module('fib.pl').


cl_chr(File):-
    chr_compile(File,'__tmp.pl'),
    load_module('__tmp.pl').
    
