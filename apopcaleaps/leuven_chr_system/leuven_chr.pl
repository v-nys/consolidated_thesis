:-set_prolog_flag(redefine_builtin,on).
:-include('chr_op.pl').
:-include('run_bp.pl').

:-include('released/chr_runtime.pl').
:-include('released/assoc.pl').
:-include('released/oset.pl').
:-include('released/gensym.pl').
:-include('released/ordsets.pl').
:-include('released/hprolog.pl').
:-include('released/pairlist.pl').
:-include('released/binomialheap.pl').
:-include('released/find.pl').
:-include('released/lists.pl').
:-include('released/lists.pl').
:-include('released/listmap.pl').
:-include('released/clean_code.pl').
:-include('released/builtins.pl').
:-include('released/chr_runtime.pl').
:-include('released/chr_compiler_errors.pl').
:-include('released/chr_hashtable_store.pl').
:-include('released/chr_compiler_utility.pl').
:-include('released/chr_messages.pl').
:-include('released/chr_swi.pl').
:-include('released/chr_compiler_options.pl').
:-include('released/chr_translate.pl').
:-include('released/guard_entailment.pl').
:-include('released/chr_translate_bootstrap.pl').
:-include('released/chr_swi_bootstrap.pl').


/*********************************************/
cl_chr(File):-
    chr_file_name(File,_,InFile),
    chr_init,
    chr_compile_step4(InFile,'__tmp.pl'),
    load_module('__tmp.pl').
    
consult_chr(File):-
    chr_file_name(File,_,InFile),
    chr_init,
    chr_compile_step4(InFile,'__tmp.pl'),
    consult_module('__tmp.pl').

chr_compile(File) :-
    chr_file_name(File,MainStr,InFile),
    append(MainStr,".pl",OutFileStr),
    atom_codes(OutFile,OutFileStr),
    chr_compile(InFile,OutFile).
    
chr_compile(In,Out) :-
    chr_init,
    write(user,compiling(In,Out)),nl(user),
    chr_compile_step4(In,Out).

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


