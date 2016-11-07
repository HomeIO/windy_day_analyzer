graphs:
	for file in $$(find ./gnuplot/ -iname '*.gnu'); do \
		gnuplot "$$file"; \
		echo $$file ; \
	done

clean:
	rm gnuplot/*.png
