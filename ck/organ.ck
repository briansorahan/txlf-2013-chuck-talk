// organ.ck
// Additive synthesis organ emulation.
// Brian Sorahan 2013

class CcEvent extends Event {
    int cc;
	int val;
}

class HarmonicEvent extends Event {
    int val;
}

1 => int device;
MidiIn midiIn;
MidiMsg midiMsg;
0 => int traceMidiCC;

if (! midiIn.open(device)) {
	chout <= "Could not open midi device." <= IO.newline();
	me.exit();
}

// NoteOff events
Event @ offEvent[128];
CcEvent ccEvent;

// the base patch
Gain masterGain;
PRCRev r;
masterGain => r => dac;
// masterGain => dac;
.8 => masterGain.gain;
.2 => r.mix;

// global synth voice parameters
8 => int harmonics;

////////////////////////////////////////
// Shreds
////////////////////////////////////////

// control harmonics with midi cc
function void harmonicsControl(CcEvent @ ev) {
    harmonics => int oldVal;
    
    while (true) {
        // Wait for a CC event
        ev => now;

        if (traceMidiCC) {
            <<< ev.cc, ev.val >>>;
        }

        // Map MIDI CC
        if (ev.cc == 32) {
            harmonics => oldVal;
            Math.floor(ev.val / 4.0) $ int => harmonics;
            if (harmonics != oldVal) {
                <<< "Harmonics:", harmonics >>>;
            }
        }
    }
}

// Control a Gain with MIDI CC
function void gainControl(CcEvent ev, Gain g, int cc) {
    while (true) {
        ev => now;
        if (ev.cc == cc) {
            ev.val / 130.0 => g.gain;
        }
    }
}

// Control a PRCRev with MIDI CC
function void reverbControl(CcEvent ev, PRCRev prcRev, int cc) {
    while (true) {
        ev => now;
        if (ev.cc == cc) {
            ev.val / 128.0 => prcRev.mix;
        }
    }
}

// synth voice
4.0 => float polyphony; // keep the gain under control
fun void voice(int note, int velocity, Event @ noteOff, UGen @ out) {
    // event for dynamically controlling the number of harmonics
    HarmonicEvent hev;
    
    // Audio patch
    ADSR adsr;
    200::ms => dur release;
    adsr.set(100::ms, 100::ms, 1.0, release);
    adsr => out;

    // Set up oscillators
    SinOsc oscillators[harmonics];
    for (0 => int i; i < harmonics; i++) {
        oscillators[i] => adsr;
    }

    velocity / 128.0 => float vel;
    vel / polyphony => float gainVel;

    // play it
    note => Std.mtof => float f;
    for(0 => int i; i < harmonics; i++) {
        gainVel / harmonics => oscillators[i].gain;
        f * Math.pow(2, i) => oscillators[i].freq;
    }
    
    1 => adsr.keyOn;
    noteOff => now;
    1 => adsr.keyOff;
    release => now;
}

// midi listener
function void midiLoop() {
    int note, velocity, cc, ccVal;
    
    while (true) {
        midiIn => now;

        while( midiIn.recv(midiMsg)) {
            if(midiMsg.data1 == 144) {
                midiMsg.data2 => note;
                midiMsg.data3 => velocity;
                
			    if (midiMsg.data3 > 0) {
                    Event off;
                    off @=> offEvent[note];
                    // <<< "Triggering note on for", note >>>;
                    spork ~ voice(note, velocity, off, masterGain);
				    me.yield();
			    } else {
                    if (offEvent[note] != null) {
                        // <<< "Triggering note off for", note >>>;
                        offEvent[note].signal();
                        null => offEvent[note];
                    }
			    }
		    } else if (midiMsg.data1 == 176) {
                // CC
                midiMsg.data2 => ccEvent.cc;
                midiMsg.data3 => ccEvent.val;
                ccEvent.broadcast();
		    }			
        }
    }
}

////////////////////////////////////////
// Spork 'em
////////////////////////////////////////

spork ~ midiLoop();
spork ~ harmonicsControl(ccEvent);
spork ~ gainControl(ccEvent, masterGain, 93);
spork ~ reverbControl(ccEvent, r, 51);

while (1) {
    1000::ms => now;
}
