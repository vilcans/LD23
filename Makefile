all: release

COFFEE_SOURCES = $(wildcard src/*.coffee)
GENERATED_JS = $(patsubst src/%.coffee,www/js/%.js,$(COFFEE_SOURCES))

clean:
	rm -vrf www/intermediate www/publish
	rm -vf ${GENERATED_JS}

js:
	coffee -c -o www/js/ src/

continuous:
	coffee -w -c -o www/js/ src/

audio:
	$(MAKE) -C www/assets/audio

generate: js audio www/js/ship-names.js

www/js/ship-names.js: ship-names.csv convert-names.py
	./convert-names.py >$@

release: generate
	ant -f www/build/build.xml

.PHONY: clean js continuous generate release audio
