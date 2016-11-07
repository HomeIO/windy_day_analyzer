set terminal png size 2000, 2000
set output "gnuplot/graphs/imp_vs_coil1_voltage.png"

set title "Impulses / Coil1 voltage" font ",20"
set timefmt "%Y-%m-%d_%H:%M:%S"
set style data dots

plot [:][:] 'gnuplot/data/data.dat' using 8:4
