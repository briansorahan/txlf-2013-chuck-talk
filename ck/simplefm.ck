// simplefm.ck
// A garden-variety FM synth.
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
JCRev r;
// masterGain => r => dac;
masterGain => dac;
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
            ev.val => Std.mtof => modFreq;
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
            ev.val => Std.mtof => modulator.gain;
        } else if (ev.cc == 33) {
            ev.val => Std.mtof => modulator.freq;
        }
    }
}

// synth voice
4.0 => float polyphony; // keep the gain under control
fun void voice(int note, int velocity, Event @ noteOff, UGen @ out) {
    // Audio patch
	SinOsc carrier;
    SinOsc modulator;
    modulator => carrier => out;
    // dynamic modulation
    spork ~ dynamicControl(ccEvent, modulator);

    2 => carrier.sync; // fm
    velocity / 128.0 => float vel;
    vel => carrier.gain;
    harmonicity => modulator.gain;
    modFreq => modulator.freq;

    // play it
    note => Std.mtof => carrier.freq;
    noteOff => now;
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

while (1) {
    1000::ms => now;
}
