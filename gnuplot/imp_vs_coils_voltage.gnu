set terminal png size 2000, 2000
set output "gnuplot/graphs/imp_vs_coils_voltage.png"

set title "Impulses / Coil1 voltage" font ",20"
set timefmt "%Y-%m-%d_%H:%M:%S"
set style data points


plot [:][:] 'gnuplot/data/data.dat' using 8:4 pt 5 ps 0.3 lc rgb 'red', \
                                 '' using 8:5 pt 5 ps 0.3 lc rgb 'green', \
                                 '' using 8:6 pt 5 ps 0.3 lc rgb 'blue'
