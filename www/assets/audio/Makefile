WAVS = $(wildcard *.wav)
OGGS = $(patsubst %.wav,%.ogg,$(WAVS))

all: $(OGGS)

%.ogg: %.wav
	oggenc $<
