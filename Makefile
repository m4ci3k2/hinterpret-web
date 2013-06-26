all: main

run-server: main
	./main

.PHONY: run-server all

main: main.hs
	ghc --make $<
