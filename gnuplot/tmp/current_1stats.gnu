set terminal png size 20000, 1200
set output "gnuplot/graphs/current_1candlebar_10s.png"

set title "Charging current" font ",20"
set style data lines
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"
set style fill empty

datafile = 'gnuplot/data/stats_charg_current_10000.0.dat'

#plot datafile using 2:5:4:4:4:6:xticlabels(8) with candlesticks title 'Quartiles' whiskerbars

plot [:][:] datafile u 2:4   title "Avg Current" lt rgb 'green', \
            ''       u 2:5:6 notitle lt rgb 'red'
