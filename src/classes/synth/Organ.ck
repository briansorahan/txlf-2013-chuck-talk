// Organ.ck
// Additive synthesis organ emulation.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- EnvelopeGenerator.ck
//
// Brian Sorahan 2013

public class Organ extends MidiInstrument {
    8 => int harmonics;
    32 => int ccHarmonics;
    
    EnvelopeGenerator ampEnvGen;

    fun void voice(NoteEvent nev) {
        4.0 => float polyphony; // keep the gain under control
        
        SinOsc oscillators[harmonics];

        // Audio patch
        ampEnvGen.getADSR() @=> ADSR @ adsr;
        adsr => out;
        for (0 => int i; i < harmonics; i++) {
            oscillators[i] => adsr;
        }

        nev.velocity / (128.0 * polyphony) => float vel;

        // play it
        nev.note => Std.mtof => float f;
        for(0 => int i; i < harmonics; i++) {
            vel / harmonics => oscillators[i].gain;
            f * Math.pow(2, i) => oscillators[i].freq;
        }
        
        1 => adsr.keyOn;
        nev.noteOff => now;
        1 => adsr.keyOff;
        ampEnvGen.release => now;
    }

    // MIDI CC
    function void control(ControlEvent cev) {
        harmonics => int oldVal;
        
        if (cev.cc == ccHarmonics) {
            harmonics => oldVal;
            Math.floor(cev.val / 4.0) $ int => harmonics;
            if (harmonics != oldVal) {
                <<< "Harmonics:", harmonics >>>;
            }
        } else {
            ampEnvGen.control(cev.cc, cev.val);
        }
    }
}
