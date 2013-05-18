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
mixer.connectReverb(vibratoFM.out);

spork ~ MidiInstrument.noteListen(vibratoFM);
spork ~ MidiInstrument.controlListen(vibratoFM);
spork ~ MidiInstrument.controlListen(mixer);

while (1) {
    1000::ms => now;
}
