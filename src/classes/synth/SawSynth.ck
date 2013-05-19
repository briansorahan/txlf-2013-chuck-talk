// SawSynth.ck
// MIDI synth demonstrating subtractive synthesis.
//
// chuck with:
//--- EnvelopeGenerator.ck
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//
// Brian Sorahan 2013

public class SawSynth extends MidiInstrument {
    12000.0 => float filterFreq;
    2.0 => float filterQ;
    0.0 => float filterEnvModDepth;
    
    32 => int ccFilterFreq;
    33 => int ccFilterQ;
    82 => int ccFilterEnvModDepth;

    EnvelopeGenerator ampEnvGen;
    EnvelopeGenerator filterEnvGen;
    // Set MIDI CC values for envelopes
    ampEnvGen.setCC(71, 74, 52, 47);
    filterEnvGen.setCC(5, 6, 40, 43);
    
    fun void voice(NoteEvent nev) {
        4 => float polyphony; // keep gain under control

        // Patch
	    SawOsc saw;
        LPF lpf;
        ampEnvGen.getADSR() @=> ADSR @ ampEnv;
        filterEnvGen.getADSR() @=> ADSR @ filterEnv;

        // UGen patch
        saw => lpf => ampEnv => out;

        // spork filter envelope and filter controller shred
        spork ~ filterEnvelope(filterEnv, lpf, filterEnvModDepth);
        spork ~ filterControl(MidiInstrument.controlEvent, lpf);

        filterQ => lpf.Q;
        filterFreq => lpf.freq;
        nev.velocity / (128.0 * polyphony) => saw.gain;
        nev.note => Std.mtof => saw.freq;
        1 => ampEnv.keyOn;
        1 => filterEnv.keyOn;
        nev.noteOff => now;
        1 => ampEnv.keyOff;
        1 => filterEnv.keyOff;

        // We need to make sure the filterEnv gets a chance to
        // finish so that the shred we sporked for it will go away.
        if (filterEnvGen.release > ampEnvGen.release) {
            filterEnvGen.release => now;
        } else {
            ampEnvGen.release => now;
        }
    }

    // map midi values to filter frequency
    fun float mapFilterFreq(int val) {
        return val => Std.mtof;
    }

    // map midi values to filter Q
    fun float mapFilterQ(int val) {
        return (val / 127.0) * 4.0;
    }
    
    // control global filter params with MIDI CC
    fun void control(ControlEvent cev) {
        if (cev.cc == ccFilterFreq) {
            cev.val => mapFilterFreq => filterFreq;
        } else if (cev.cc == ccFilterQ) {
            cev.val => mapFilterQ => filterQ;
        } else if (cev.cc == ccFilterEnvModDepth) {
            cev.val / 127.0 => filterEnvModDepth;
        } else {
            // send the control values to the envelope generators
            ampEnvGen.control(cev.cc, cev.val);
            filterEnvGen.control(cev.cc, cev.val);
        }
    }

    // *SPORK*
    // control filter params with MIDI CC
    fun void filterControl(ControlEvent cev, LPF lpf) {
        while (true) {
            cev => now;
            if (cev.cc == ccFilterFreq) {
                cev.val => mapFilterFreq => lpf.freq;
            } else if (cev.cc == ccFilterQ) {
                cev.val => mapFilterQ => lpf.Q;
            }
        }
    }

    // *SPORK*
    // control filter freq with an ADSR
    // modDepth should be between 0 and 1
    fun void filterEnvelope(ADSR adsr, LPF lpf, float modDepth) {
        Step driver => adsr => blackhole;
        1.0 => driver.next;

        while (adsr.state() != 4) { // 4 = done
            (adsr.last() * 127.0) $ int => mapFilterFreq => float e;
            Math.min((e * modDepth) + filterFreq, 20000.0) => lpf.freq;
            10::ms => now;
        }
    }
}