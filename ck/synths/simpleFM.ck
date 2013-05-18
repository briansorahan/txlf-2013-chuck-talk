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
mixer.connectReverb(simpleFM.out);

spork ~ MidiInstrument.noteListen(simpleFM);
spork ~ MidiInstrument.controlListen(simpleFM);
spork ~ MidiInstrument.controlListen(mixer);

while (1) {
    1000::ms => now;
}
