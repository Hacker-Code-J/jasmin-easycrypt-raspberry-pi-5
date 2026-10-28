# Build the installation guide (run `make` twice-safe: pdflatex is run twice
# so that the table of contents is up to date).
main.pdf: main.tex $(wildcard examples/*/*) examples/run-tests-output.txt
	pdflatex -interaction=nonstopmode -halt-on-error main.tex
	pdflatex -interaction=nonstopmode -halt-on-error main.tex

test:
	./examples/run-tests.sh

clean:
	rm -f main.aux main.log main.out main.toc build.txt

.PHONY: test clean
