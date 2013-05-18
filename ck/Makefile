.PHONY: test additive-synth

# Unfortunately, the order in which we load classes
# matters here.
MIDICLASSES := $(addprefix classes/, NoteEvent.ck ControlEvent.ck MidiInstrument.ck MidiMixer.ck AmpEnvelope.ck SimpleFM.ck VibratoFM.ck)

SYNTHCLASSES := $(addprefix

MIDITEST = test/MidiInstrumentTest.ck

TESTS_ALL := $(wildcard test/*.ck)

midi-test:
	chuck --silent $(MIDICLASSES) $(MIDITEST)

additive-synth:
	chuck $(MIDICLASSES) additive.ck

simple-fm:
	chuck $(MIDICLASSES) synths/SimpleFM.ck

vibrato-fm:
	chuck $(MIDICLASSES) synths/SimpleFM.ck synths/VibratoFM.ck

