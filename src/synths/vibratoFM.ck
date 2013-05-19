// vibratoFM.ck
// FM synth that showcases the full spectrum of timbres that lie
// between vibrato and FM synthesis.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- AmpEnvelope.ck
//--- SimpleFM.ck
//--- VibratoFM.ck
//
// Brian Sorahan 2013

VibratoFM vibratoFM;
MidiMixer mixer;
mixer.masterGain => dac;
vibratoFM.out => mixer.echo;

spork ~ MidiInstrument.sendNotesTo(vibratoFM);
spork ~ MidiInstrument.sendControlTo(vibratoFM);
spork ~ MidiInstrument.sendControlTo(mixer);

while (1) {
    1000::ms => now;
}
