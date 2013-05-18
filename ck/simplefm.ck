// simplefm.ck
// A garden-variety FM synth.
// Brian Sorahan 2013

// Global UGens
Gain masterGain;
JCRev r;
masterGain => r => dac;
0.99 => masterGain.gain;
0.2 => r.mix;



float harmonicity;
float modFreq;

fun void voice(NoteEvent @ noteEvent, UGen out) {
    // keep the gain under control
    4.0 => float polyphony;

    // Get note data
    noteEvent.note => int note;
    noteEvent.velocity => int velocity;
    noteEvent.noteOff @=> Event @ noteOff;
    
    // Audio patch
	SinOsc carrier;
    SinOsc modulator;
    modulator => carrier => out;

    2 => carrier.sync; // fm
    velocity / 128.0 => float vel;
    vel => carrier.gain;
    harmonicity => modulator.gain;
    modFreq => modulator.freq;

    // play it
    note => Std.mtof => carrier.freq;
    noteOff => now;
}

// Control modulation with MIDI CC
fun void control(ControlEvent @ controlEvent) {
    controlEvent.cc => int cc;
    controlEvent.val => int val;
    
    if (cc == 32) {
        val => Std.mtof => harmonicity;
    } else if (cc == 33) {
        val => Std.mtof => modFreq;
    }
}



////////////////////////////////////////
// Spork 'em
////////////////////////////////////////

NoteEvent @ noteEvent;
ControlEvent @ controlEvent;
MidiInstrument.noteEvent @=> noteEvent;
MidiInstrument.controlEvent @=> controlEvent;
spork ~ voice(noteEvent, masterGain);
spork ~ control(controlEvent);

while (1) {
    1000::ms => now;
}
