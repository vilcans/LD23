all: release

js:
	coffee -c -o www/js/modules src/

continuous:
	coffee -w -c -o www/js/modules src/

release: js
	ant -f build/build.xml

.PHONY: continuous js
