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

release: js audio
	ant -f www/build/build.xml

.PHONY: clean js continuous release audio
