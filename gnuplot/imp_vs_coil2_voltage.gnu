set terminal png size 2000, 2000
set output "gnuplot/graphs/imp_vs_coil2_voltage.png"

set title "Impulses / Coil2 voltage" font ",20"
set timefmt "%Y-%m-%d_%H:%M:%S"
set style data points


plot [:][:] 'gnuplot/data/data.dat' using 8:5 pt 5 ps 1 lc rgb 'red'
