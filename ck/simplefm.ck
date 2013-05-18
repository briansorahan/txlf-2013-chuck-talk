// simplefm.ck
// A garden-variety FM synth.
//
// chuck with:
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- AmpEnvelope.ck
//
// Brian Sorahan 2013


class SimpleFM extends MidiInstrument {
    // Modulator params
    float harmonicity;
    float modFreq;
    32 => int ccHarmonicity;
    33 => int ccModFreq;

    AmpEnvelope ampEnvelope;
    
    // Output params
    Gain out;
    0.9 => out.gain;

    fun void voice(NoteEvent noteEvent) {
        // keep the gain under control
        4.0 => float polyphony;

        // Get note data
        noteEvent.note => int note;
        noteEvent.velocity => int velocity;
        
        // Audio patch
	    SinOsc carrier;
        SinOsc modulator;
        ampEnvelope.getEnvelope() @=> ADSR @ ampEnv;
        modulator => carrier => ampEnv => out;

        2 => carrier.sync; // fm
        velocity / 128.0 => float vel;
        vel / polyphony => carrier.gain;
        harmonicity => modulator.gain;
        modFreq => modulator.freq;

        // dynamically control modulator params
        spork ~ dynamicControl(MidiInstrument.controlEvent, modulator);
        
        // play it
        note => Std.mtof => carrier.freq;
        1 => ampEnv.keyOn;
        noteEvent.noteOff => now;
        1 => ampEnv.keyOff;
        ampEnvelope.release => now;
    }

    // Control modulation with MIDI CC
    fun void control(ControlEvent cev) {
        cev.cc => int cc;
        cev.val => int val;
        if (cc == ccHarmonicity) {
            val => Std.mtof => harmonicity;
        } else if (cc == ccModFreq) {
            val => Std.mtof => modFreq;
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
                val => Std.mtof => modulator.freq;
            }
        }
    }
}



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
