// fm-whatis.ck
// Getting to hear the transition from vibrato to FM.
// Brian Sorahan 2013

class CcEvent extends Event {
    int cc;
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
float harmonicity, modFreq;

////////////////////////////////////////
// Shreds
////////////////////////////////////////

// midi cc
function void fmControl(CcEvent @ ev) {
    while (true) {
        // Wait for a CC event
        ev => now;

        if (traceMidiCC) {
            <<< ev.cc, ev.val >>>;
        }

        // Map MIDI CC
        if (ev.cc == 32) {
            ev.val => Std.mtof => harmonicity;
        } else if (ev.cc == 33) {
            ev.val - 63 => Std.mtof => modFreq;
        }
    }
}

function void dynamicControl(CcEvent @ ev, SinOsc modulator) {
    while (true) {
        // Wait for a CC event
        ev => now;

        if (traceMidiCC) {
            <<< ev.cc, ev.val >>>;
        }

        // Map MIDI CC
        if (ev.cc == 32) {
            ev.val => Std.mtof => harmonicity => modulator.gain;
        } else if (ev.cc == 33) {
            ev.val - 63 => Std.mtof => modFreq => modulator.freq;
        }
    }
}

// Control a PRCRev with MIDI CC
function void gainControl(CcEvent ev, Gain g, int cc) {
    while (true) {
        ev => now;
        if (ev.cc == cc) {
            ev.val / 130.0 => g.gain;
        }
    }
}

// Control a Gain with MIDI CC
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
    // Audio patch
	SinOsc carrier;
    SinOsc modulator;
    ADSR adsr;
    200::ms => dur release;
    adsr.set(100::ms, 100::ms, 1.0, release);
    modulator => carrier => adsr => out;

    // dynamic modulation
    spork ~ dynamicControl(ccEvent, modulator);

    2 => carrier.sync; // fm
    velocity / 128.0 => float vel;
    vel / polyphony => carrier.gain;
    harmonicity => modulator.gain;
    modFreq => modulator.freq;

    // play it
    note => Std.mtof => carrier.freq;
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
spork ~ fmControl(ccEvent);
spork ~ gainControl(ccEvent, masterGain, 93);
spork ~ reverbControl(ccEvent, r, 51);

while (1) {
    1000::ms => now;
}
