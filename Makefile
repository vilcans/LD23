all: release

js:
	coffee -c -o js/modules src/

continuous:
	coffee -w -c -o js/modules src/

release: js
	ant -f build/build.xml

.PHONY: continuous js
