graphs:
	for file in $$(find ./gnuplot/ -maxdepth 1 -iname '*.gnu'); do \
		gnuplot "$$file"; \
		echo $$file ; \
	done

clean:
	rm gnuplot/graphs/*.png ;
	rm gnuplot/data/*.dat ;
