// Additive.ck
// Additive MIDI synth.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- EnvelopeGenerator.ck
//
// Brian Sorahan 2013

public class Additive extends MidiInstrument {
    4 => int harmonics;
    
    [1.0, 1.0, 1.0, 1.0] @=> float frequencies[];
    [0.0, 0.0, 0.0, 0.0] @=> float gains[];

    [32, 33, 82, 83] @=> int freqCC[];
    [5,  6,  40, 43] @=> int gainCC[];
    
    EnvelopeGenerator ampEnvGen;

    fun void voice(NoteEvent nev) {
        4.0 => float polyphony; // keep the gain under control

        SinOsc root;
        SinOsc partials[harmonics];

        // Audio patch
        ampEnvGen.getADSR() @=> ADSR @ adsr;
        root => adsr => out;
        for (0 => int i; i < harmonics; i++) {
            partials[i] => adsr;
        }

        nev.velocity / (128.0 * polyphony) => float vel;

        // play it
        nev.note => Std.mtof => float f;
        f => root.freq;
        vel / harmonics => root.gain;
        for(0 => int i; i < harmonics; i++) {
            (vel / harmonics) * gains[i] => partials[i].gain;
            f * frequencies[i] => partials[i].freq;
        }
        
        1 => adsr.keyOn;
        nev.noteOff => now;
        1 => adsr.keyOff;
        ampEnvGen.release => now;
    }

    // MIDI CC
    function void control(ControlEvent cev) {
        for (0 => int i; i < harmonics; i++) {
            if (cev.cc == freqCC[i]) {
                cev.val => mapFreq => frequencies[i];
            } else if (cev.cc == gainCC[i]) {
                cev.val / 127.0 => gains[i];
            }
        }
            
        ampEnvGen.control(cev.cc, cev.val);
    }

    fun float mapFreq(int midiVal) {
        return Math.pow(2.0, (midiVal / 127.0) * 4.0);
    }
}
