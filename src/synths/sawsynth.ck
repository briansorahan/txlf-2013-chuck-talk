// sawsynth.ck
// Using the SawSynth class.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- SawSynth.ck
//
// Brian Sorahan 2013

SawSynth sawSynth;
MidiMixer mixer;
mixer.masterGain => dac;
sawSynth.out => mixer.reverb;

spork ~ MidiInstrument.sendNotesTo(sawSynth);
spork ~ MidiInstrument.sendControlTo(sawSynth);
spork ~ MidiInstrument.sendControlTo(mixer);

while (1) {
    1000::ms => now;
}
