// SawSynth.ck
// MIDI synth demonstrating subtractive synthesis.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//
// Brian Sorahan 2013

class SawSynth extends MidiInstrument {
    float filterFreq;
    32 => int ccFilterFreq;
    
    fun void voice(NoteEvent nev) {
        4 => float polyphony; // keep gain under control

        // Patch
	    SawOsc saw;
        LPF lpf;
        saw => lpf => out;

        2.0 => lpf.Q;
        nev.velocity / (128.0 * polyphony) => SawOsc.gain;
        nev.note => Std.mtof => saw.freq;
        nev.noteOff => now;
    }

    // map midi values to filter frequency
    fun float mapFilterFreq(int val) {
        return val => Std.mtof;
    }

    fun void control(ControlEvent cev) {
        if (cev.cc == ccFilterFreq) {
            val => mapFilterFreq => filterFreq;
        }
    }

    // spork me
    fun void filterMod(ControlEvent cev, LPF lpf) {
        while (true) {
            cev => now;
            if (cev.cc == ccFilterFreq) {
                cev.val => mapFilterFreq => lpf.freq;
            }
        }
    }
}