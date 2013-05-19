// additive.ck
// Additive synthesis demo.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- EnvelopeGenerator.ck
//--- Additive.ck
//
// Brian Sorahan 2013

Additive additive;
MidiMixer mixer;
mixer.masterGain => dac;
additive.out => mixer.echo;

spork ~ MidiInstrument.sendNotesTo(additive);
spork ~ MidiInstrument.sendControlTo(additive);
spork ~ MidiInstrument.sendControlTo(mixer);

while (1) {
    1000::ms => now;
}
