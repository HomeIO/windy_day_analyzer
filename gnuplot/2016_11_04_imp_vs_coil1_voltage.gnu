set terminal png size 2000, 2000
set output "gnuplot/graphs/2016_11_04_imp_vs_coil1_voltage.png"

set title "Impulses / Coil1 voltage" font ",20"
set timefmt "%Y-%m-%d_%H:%M:%S"
set style data points


plot [:][:] 'gnuplot/data/data_2016_11_04.dat' using 8:4 pt 5 ps 1 lc rgb 'red'
