// organ.ck
// Additive synthesis organ emulation.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- EnvelopeGenerator.ck
//--- Organ.ck
//
// Brian Sorahan 2013

Organ organ;
MidiMixer mixer;
mixer.masterGain => dac;
organ.out => mixer.echo;

spork ~ MidiInstrument.sendNotesTo(organ);
spork ~ MidiInstrument.sendControlTo(organ);
spork ~ MidiInstrument.sendControlTo(mixer);

while (1) {
    1000::ms => now;
}
