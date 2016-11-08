set terminal png size 2000, 2000
set output "gnuplot/graphs/batt_voltage_vs_current.png"

set title "Batt voltage / Current" font ",20"
set timefmt "%Y-%m-%d_%H:%M:%S"
set style data points


plot [30:70][:] 'gnuplot/data/data.dat' using 7:3 pt 5 ps 1 lc rgb 'red'
