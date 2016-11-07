set terminal png size 10000, 1200
set output "gnuplot/graphs/current_1.png"

set title "Charging current" font ",20"
#set key left box
#set style data points
set style data lines
set xdata time
set timefmt "%Y-%m-%d_%H:%M:%S"


plot [:][:] 'gnuplot/data/data.dat' using 2:3
