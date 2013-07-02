%% start with swi -p chr=. after s6 and s7
:-set_prolog_flag(singleton,off).

:-compile('chr_swi_bootstrap').

go:-
    chr_compile_step1('chr_translate_bootstrap1.chr','chr_translate_bootstrap1.pl'),
    nl,writeln('next s1'),
    halt.

s1:-
    chr_compile_step2('chr_translate_bootstrap1.chr','chr_translate_bootstrap1.pl'),
    nl,writeln('next s2'),
    halt.

s2:-
%    cl(chr_translate_bootstrap1),
    chr_compile_step2('chr_translate_bootstrap2.chr','chr_translate_bootstrap2.pl'),
    nl,writeln('next s3'),
    halt.

s3:-
%    cl(chr_translate_bootstrap1),
    chr_compile_step3('chr_translate_bootstrap2.chr','chr_translate_bootstrap2.pl'),
    nl,writeln('next s4'),
    halt.

s4:-
%    cl(chr_translate_bootstrap2),
    chr_compile_step3('guard_entailment.chr','guard_entailment.pl'),
    nl,writeln('next s5'),
    halt.

s5:-
    chr_compile_step3('chr_translate.chr','chr_translate.pl'),
    nl,writeln('next s6'),
    halt.

s6:-
    chr_compile_step4('guard_entailment.chr','guard_entailment.pl'),
    nl,writeln('next s7'),
    halt.

s7:-
    chr_compile_step4('chr_translate.chr','chr_translate.pl'),
    halt.

/*

go:-
    chr_compile_step1('chr_translate_bootstrap1.chr','chr_translate_bootstrap1.pl'),
    writeln('next make_bootstrap1_2'),
    halt.

make_bootstrap1_2:-
    chr_compile_step2('chr_translate_bootstrap1.chr','chr_translate_bootstrap1.pl'),
    writeln('next make_bootstrap2_1'),
    halt.

make_bootstrap2_1:-chr_compile_step2('chr_translate_bootstrap2.chr','chr_translate_bootstrap2.pl'),
    writeln('next make_bootstrap2_2'),
    halt.

make_bootstrap2_2 :- chr_compile_step3('chr_translate_bootstrap2.chr','chr_translate_bootstrap2.pl'),
    writeln('next make_guard_entailment_1'),
    halt.

make_guard_entailment_1 :- chr_compile_step3('guard_entailment.chr','guard_entailment.pl'),
    writeln('next make_chr_translate_1'),
    halt.

make_chr_translate_1 :-chr_compile_step3('chr_translate.chr','chr_translate.pl'),
    writeln('next make_guard_entailment_2'),
    halt.

make_guard_entailment_2 :- chr_compile_step4('guard_entailment.chr','guard_entailment.pl'),
    writeln('next make_chr_translate_2'),
    halt.

make_chr_translate_2:- chr_compile_step4('chr_translate.chr','chr_translate.pl'),
    halt.

*/
