// modal.ck
// Physical modelling synth that uses the ModalBar STK class.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- EnvelopeGenerator.ck
//--- Modal.ck
//
// Brian Sorahan 2013

Modal modal;
MidiMixer mixer;
mixer.masterGain => dac;
modal.out => mixer.echo;

spork ~ MidiInstrument.sendNotesTo(modal);
spork ~ MidiInstrument.sendControlTo(modal);
spork ~ MidiInstrument.sendControlTo(mixer);

while (1) {
    1000::ms => now;
}
