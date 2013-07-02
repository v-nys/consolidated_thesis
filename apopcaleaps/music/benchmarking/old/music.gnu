set terminal postscript eps enhanced color solid
#set size 1,2

#set terminal epslatex color dashed 8 


set output 'plot.eps'

#set logscale x 2  ; set xtics 1,2 
set logscale y 10 ;
#set ytics 0.5; set mytics 5
#set mxtics 0
#set logscale xy 10  ; set xtics 32,2  ; set ytics ("10 ms" 0.01, "100 ms" 0.1, "1 second" 1, "10 seconds" 10, "1 minute" 60, "10 minutes" 600)

set size 1,1


set xlabel "Input size (#measures)"
set ylabel "Runtime in milliseconds"
set grid ytics  back 
set key right outside top spacing 1.5

#set key below Left reverse spacing 1




#plot [128:16384] [0:3]  

plot [0:50] [1:100000000]  \
x with lines lt 0 lw 2 title "$n$",\
x*x*1 with lines lt 0 lw 3 title "$n^2$",\
x*x*x*1 with lines lt 0 lw 4 title "$n^3$",\
'data'  with errorbars lt 3 pt 3 lw 2 title "bla",\
'data1'  with errorbars lt 1 pt 1 lw 2 title "manual",\
'data2' with errorbars  lt 2 pt 2 lw 2 title "all NR"


#'dijkstra' using 1:($3/1) with linespoints lt 1 pt 1 lw 2 title "CHR [2]",\
'dijkstra' using 1:($4/1) with linespoints lt 1 pt 2 lw 2 title "CHR [1]",\
'dijkstra' using 1:($5/1) with linespoints lt 1 pt 3 lw 2 title "CHR [0]",\
'dijkstra' using 1:($6/1) with linespoints lt 2 pt 4 lw 2 title "SICStus",\
'dijkstra' using 1:($7/1) with linespoints  lt 3 pt 7 lw 2 title "Java"



set output

