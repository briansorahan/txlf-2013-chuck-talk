.PHONY: test additive-synth simple-fm vibrato-fm modal-synth

# Unfortunately, the order in which we load classes matters.
# Otherwise we could just use a wildcard instead of addprefix.
MIDICLASSES := $(addprefix classes/midi/, NoteEvent.ck ControlEvent.ck MidiInstrument.ck MidiMixer.ck)

SYNTHCLASSES := $(addprefix classes/synth/, EnvelopeGenerator.ck SimpleFM.ck VibratoFM.ck Modal.ck SawSynth.ck)

MIDITEST = test/MidiInstrumentTest.ck

midi-test:
	chuck --silent $(MIDICLASSES) $(MIDITEST)

# Assume there is a running chuck listener
midi-classes:
	chuck + $(MIDICLASSES)

# Assume there is a running chuck listener
synth-classes:
	chuck + $(SYNTHCLASSES)

# Assume there is a running chuck listener
all-classes:
	chuck + $(MIDICLASSES) $(SYNTHCLASSES)

additive-synth:
	chuck $(MIDICLASSES) $(SYNTHCLASSES) synths/additive.ck

simple-fm:
	chuck $(MIDICLASSES) $(SYNTHCLASSES) synths/simpleFM.ck

vibrato-fm:
	chuck $(MIDICLASSES) $(SYNTHCLASSES) synths/vibratoFM.ck

modal-synth:
	chuck $(MIDICLASSES) $(SYNTHCLASSES) synths/modal.ck

saw-synth:
	chuck $(MIDICLASSES) $(SYNTHCLASSES) synths/sawsynth.ck
