// simpleFM.ck
// A garden-variety FM synth.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- AmpEnvelope.ck
//--- SimpleFM.ck
//
// Brian Sorahan 2013

SimpleFM simpleFM;
MidiMixer mixer;
mixer.masterGain => dac;
simpleFM.out => mixer.echo;

spork ~ MidiInstrument.sendNotesTo(simpleFM);
spork ~ MidiInstrument.sendControlTo(simpleFM);
spork ~ MidiInstrument.sendControlTo(mixer);

while (1) {
    1000::ms => now;
}
