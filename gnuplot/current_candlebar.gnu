set terminal png size 10000, 1200
set output "gnuplot/graphs/current_candlebar.png"

set title "Charging current" font ",20"
set style data lines
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"

datafile = 'gnuplot/data/data.dat'

plot [:][:] datafile using 2:3 title 'current' lw 1 lc rgb 'red'

#plot sum = init(0), \
#     datafile using 0:2 title 'data' lw 2 lc rgb 'forest-green', \
#     '' using 0:(avg5($2)) title "running mean over previous 5 points" pt 7 ps 0.5 lw 1 lc rgb "blue", \
#     '' using 0:(sum = sum + $2, sum/($0+1)) title "cumulative mean" pt 1 lw 1 lc rgb "dark-red"
