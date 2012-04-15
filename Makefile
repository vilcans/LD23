all: release

js:
	coffee -c -o www/js/ src/

continuous:
	coffee -w -c -o www/js/ src/

release: js
	ant -f www/build/build.xml

.PHONY: continuous js
