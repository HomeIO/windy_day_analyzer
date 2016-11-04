set terminal png size 10000, 1200
set output "gnuplot/current_1.png"

set title "Charging current" font ",20"
#set key left box
#set style data points
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"


plot [:][:] 'data.dat' using 2:3
#with lines
