:-include('chr_op.pl').
:-include('chrism_op.pl').
%:-set_prolog_flag(gc_threshold,100000).
%:-set_prolog_flag(redefine_warning,on).

%:-[chr_op].
%:-cl('run_bp'),preload.
:-load('run_bp'),preload.

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
%    cl(chr_translate),
    load(chr_translate),
    %load_module(guard_entailment),
    load(guard_entailment),
    chr_compile_step4(In,Out).


clean:-
    system('rm chr_translate_bootstrap1.pl'),
    system('rm chr_translate_bootstrap2.pl'),
    system('rm guard_entailment.pl'),
    system('rm chr_translate.pl').

t:-
    chr_compile('fib.chr','fib.pl'),
    load_module('fib.pl').

install:-
    dump_module('chr_compiler_options.pl','released/chr_compiler_options.pl'),
    dump_module('guard_entailment.pl','released/guard_entailment.pl'),
    dump_module('chr_runtime.pl','released/chr_runtime.pl'),
    dump_module('assoc.pl','released/assoc.pl'),
    dump_module('oset.pl','released/oset.pl'),
    dump_module('gensym.pl','released/gensym.pl'),
    dump_module('ordsets.pl','released/ordsets.pl'),
    dump_module('hprolog.pl','released/hprolog.pl'),
    dump_module('pairlist.pl','released/pairlist.pl'),
    dump_module('binomialheap.pl','released/binomialheap.pl'),
    dump_module('find.pl','released/find.pl'),
    dump_module('lists.pl','released/lists.pl'),
    dump_module('a_star.pl','released/a_star.pl'),
    dump_module('listmap.pl','released/listmap.pl'),
    dump_module('clean_code.pl','released/clean_code.pl'),
    dump_module('builtins.pl','released/builtins.pl'),
    dump_module('chr_runtime.pl','released/chr_runtime.pl'),
    dump_module('chr_compiler_errors.pl','released/chr_compiler_errors.pl'),
    dump_module('chr_hashtable_store.pl','released/chr_hashtable_store.pl'),
    dump_module('chr_compiler_utility.pl','released/chr_compiler_utility.pl'),
    dump_module('chr_messages.pl','released/chr_messages.pl'),
    dump_module('chr_swi.pl','released/chr_swi.pl'),
    dump_module('chr_translate_bootstrap.pl','released/chr_translate_bootstrap.pl'),
    dump_module('chr_translate.pl','released/chr_translate.pl'),
    dump_module('chr_swi_bootstrap.pl','released/chr_swi_bootstrap.pl').

/*********************************************/
cl_chr(File):-
    chr_file_name(File,_,InFile),
    chr_init,
    load_module(chr_compiler_options),
    cl(chr_translate),
    load_module(guard_entailment),
    chr_compile_step4(InFile,'__tmp.pl'),
    load_module('__tmp.pl').
    
consult_chr(File):-
    chr_file_name(File,_,InFile),
    chr_init,
    load_module(chr_compiler_options),
    cl(chr_translate),
    load_module(guard_entailment),
    chr_compile_step4(InFile,'__tmp.pl'),
    consult_module('__tmp.pl').

chr_compile(File) :-
    chr_file_name(File,MainStr,InFile),
    append(MainStr,".pl",OutFileStr),
    atom_codes(OutFile,OutFileStr),
    chr_compile(InFile,OutFile).

/*    
chr_compile(In,Out) :-
    chr_init,
    load_module(chr_compiler_options),
    cl(chr_translate),
    load_module(guard_entailment),
    write(user,compiling(In,Out)),nl(user),
    chr_compile_step4(In,Out).
*/

chr_file_name(File,MainStr,InFile):-
     exists(File),!,
     InFile=File,
     atom_codes(File,Str),
     (append(MainStr,".chr",Str)->true;
      MainStr=Str).
chr_file_name(File,MainStr,InFile):-
    atom_codes(File,MainStr),
    append(MainStr,".chr",Str),
    atom_codes(InFile,Str),
    exists(InFile),!.
chr_file_name(File,MainStr,InFile):-
    handle_exception(file_not_file,File).


