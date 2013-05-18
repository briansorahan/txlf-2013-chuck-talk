.PHONY: test additive-synth

# Unfortunately, the order in which we load classes
# matters here.
MIDICLASSES := $(addprefix classes/, NoteEvent.ck ControlEvent.ck MidiInstrument.ck)

MIDITEST = test/MidiInstrumentTest.ck

TESTS_ALL := $(wildcard test/*.ck)

midi-test:
	chuck --silent $(MIDICLASSES) $(MIDITEST)

additive-synth:
	chuck $(CLASSES) additive.ck

fm-synth:
	chuck $(CLASSES) simplefm.ck

fm-synth2:
	chuck $(CLASSES) fm-whatis.ck

