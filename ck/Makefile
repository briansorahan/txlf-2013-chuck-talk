.PHONY: test additive-synth

# Unfortunately, the order in which we load classes
# matters here.
MIDICLASSES := $(addprefix classes/, NoteEvent.ck ControlEvent.ck MidiInstrument.ck MidiMixer.ck AmpEnvelope.ck)

MIDITEST = test/MidiInstrumentTest.ck

TESTS_ALL := $(wildcard test/*.ck)

midi-test:
	chuck --silent $(MIDICLASSES) $(MIDITEST)

additive-synth:
	chuck $(MIDICLASSES) additive.ck

fm-synth:
	chuck $(MIDICLASSES) simplefm.ck

fm-synth2:
	chuck $(MIDICLASSES) fm-whatis.ck

