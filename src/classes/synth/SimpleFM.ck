// simplefm.ck
// A garden-variety FM synth.
//
// chuck with:
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- AmpEnvelope.ck
//
// Brian Sorahan 2013


public class SimpleFM extends MidiInstrument {
    // Modulator params
    float harmonicity;
    float modFreq;
    32 => int ccHarmonicity;
    33 => int ccModFreq;

    AmpEnvelope ampEnvelope;
    
    fun void voice(NoteEvent nev) {
        // keep the gain under control
        4.0 => float polyphony;

        // Audio patch
	    SinOsc carrier;
        SinOsc modulator;
        2 => carrier.sync; // fm
        ampEnvelope.getEnvelope() @=> ADSR @ ampEnv;
        modulator => carrier => ampEnv => out;

        nev.velocity / 128.0 => float vel;
        vel / polyphony => carrier.gain;
        harmonicity => modulator.gain;
        modFreq => modulator.freq;

        // dynamically control modulator params
        spork ~ dynamicControl(MidiInstrument.controlEvent, modulator);
        
        // play it
        nev.note => Std.mtof => carrier.freq;
        1 => ampEnv.keyOn;
        nev.noteOff => now;
        1 => ampEnv.keyOff;
        ampEnvelope.release => now;
    }

    // Map MIDI to modulator frequency
    fun float mapModFreq(int val) {
        return val => Std.mtof;
    }


    // Control modulation with MIDI CC
    fun void control(ControlEvent cev) {
        cev.cc => int cc;
        cev.val => int val;
        if (cc == ccHarmonicity) {
            val => Std.mtof => harmonicity;
        } else if (cc == ccModFreq) {
            val => mapModFreq => modFreq;
        } else {
            ampEnvelope.control(cc, val);
        }
    }

    // Control the harmonicity and modulator frequency per-voice.
    // This function should be sporked to a separate shred.
    fun void dynamicControl(ControlEvent cev, SinOsc modulator) {
        // Infinite loop
        while (true) {
            cev => now;
            cev.cc => int cc;
            cev.val => int val;
            if (cc == ccHarmonicity) {
                val => Std.mtof => modulator.gain;
            } else if (cc == ccModFreq) {
                val => mapModFreq => modulator.freq;
            }
        }
    }
}