set terminal png size 2000, 2000
set output "gnuplot/graphs/coil_voltage_vs_battery_voltage.png"

set title "Coil voltage / Battery voltage" font ",20"
set timefmt "%Y-%m-%d_%H:%M:%S"
set style data points


plot [30:70][:] 'gnuplot/data/data.dat' using 7:4 pt 5 ps 0.3 lc rgb 'red' title "Coil 1 V", \
                                 '' using 7:5 pt 5 ps 0.3 lc rgb 'green' title "Coil 2 V", \
                                 '' using 7:6 pt 5 ps 0.3 lc rgb 'blue' title "Coil 3 V"
