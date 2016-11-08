set terminal png size 10000, 1200
set output "gnuplot/graphs/current_30min.png"

set title "Charging current" font ",20"
set style data lines
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"

datafile = 'gnuplot/data/stats_charg_current_1800000_short.dat'

plot [:][0:*] datafile u 2:5:6 title "Min/Max Current"   with filledcurve lt rgb '#88aa88', \
                    '' u 2:4   title "Avg Current"                        lt rgb 'green' lw 2
