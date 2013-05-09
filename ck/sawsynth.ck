class NoteEvent extends Event {
	int note;
	int velocity;
}

1 => int device;
MidiIn midiIn;
MidiMsg midiMsg;

if (! midiIn.open(device)) {
	chout <= "Could not open midi device." <= IO.newline();
	me.exit();
}

NoteEvent on;
Event @ us[128];

// the base patch
Gain g;
JCRev r;
LPF lpf;
PitShift shifter;
Chorus c;
shifter => lpf => c => g => dac;
.2 => g.gain;
.2 => r.mix;
500 => lpf.freq;
4 => lpf.Q;
0.1 => c.modFreq;

// handler for a single voice
fun void handler(NoteEvent on) {
    // don't connect to dac until we need it
	SawOsc saw;
    Event off;
    int note;

    while (true) {
        on => now;
        saw => shifter; // dynamically repatch
        on.note => note;
        note => Std.mtof => saw.freq;
        off @=> us[note];

        off => now;
        null @=> us[note];
        saw =< shifter;
    }
}

// spork handlers, one for each voice
for( 0 => int i; i < 20; i++ ) {
	spork ~ handler(on);
}

// infinite time-loop
while (true) {
    // wait on midi event
    midiIn => now;

    // get the midimsg
    while( midiIn.recv(midiMsg)) {
        // catch only noteon
        if(midiMsg.data1 == 144) {
			// check velocity
			if (midiMsg.data3 > 0) {
				// store midi note number
				midiMsg.data2 => on.note;
				// store velocity
				midiMsg.data3 => on.velocity;
				// signal the event
				on.signal();
				// yield without advancing time to allow shred to run
				me.yield();
			} else {
				if( us[midiMsg.data2] != null ) {
					us[midiMsg.data2].signal();
				}
			}
		} else if (midiMsg.data1 == 176) {
			// CC
			if (midiMsg.data2 == 32) {
				midiMsg.data3 => Std.mtof => lpf.freq;
			} else if (midiMsg.data2 == 5) {
				midiMsg.data3 => int midiVal;
				if (midiVal == 65 || midiVal == 64 || midiVal == 63) {
					;
				} else {
					6 * ((midiVal - 64) / 63.0) => float amt;
					amt => shifter.shift;
				}
			} else {
				<<< "CC:  ", midiMsg.data2 >>>;
				<<< "Val: ", midiMsg.data3 >>>;
			}				
		} else if (midiMsg.data1 == 224) {
			// Pitch Bend
			midiMsg.data3 => int pbend;
			if (pbend == 65 || pbend == 64 || pbend == 63) {
				continue;
			} else {
				;
			}
		} else {
		}			
    }
}