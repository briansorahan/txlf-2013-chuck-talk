// Additive.ck - Additive Synth in ChucK.
//
// chuck with:
//--- MidiInstrument.ck
//
// Brian Sorahan 2013

public class Additive extends MidiInstrument {
    // @Override
    function void voice(int note, int velocity, Event off, UGen out) {
        off => now;
    }
}

