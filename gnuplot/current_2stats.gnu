set terminal png size 10000, 1200
set output "gnuplot/graphs/current_2stats_5min.png"

set title "Charging current" font ",20"
set style data lines
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"

datafile = 'gnuplot/data/stats_charg_current_300000.0_short.dat'

plot [:][0:*] datafile u 2:4:5 title "Min/Max Current"   with filledcurve lt rgb '#88aa88', \
                    '' u 2:3   title "Avg Current"                        lt rgb 'green' lw 2
