class NoteEvent extends Event {
	int note;
	int velocity;
}

class CcEvent extends Event {
	int val;
}

1 => int device;
MidiIn midiIn;
MidiMsg midiMsg;

if (! midiIn.open(device)) {
	chout <= "Could not open midi device." <= IO.newline();
	me.exit();
}

NoteEvent on;
CcEvent filterControl;
Event @ us[128];

// the base patch
Gain g;
JCRev r;
LPF lpf;
Chorus c;
lpf => /*c =>*/ g => dac;
.2 => g.gain;
.2 => r.mix;
500 => lpf.freq;
4 => lpf.Q;
0.1 => c.modFreq;

// handler for a single voice
fun void handler(NoteEvent on, UGen out) {
    // don't connect to dac until we need it
	SawOsc saw;
    Event off;
    int note;

    while (true) {
        on => now;
        saw => out; // dynamically repatch
        on.note => note;
        note => Std.mtof => saw.freq;
        off @=> us[note];

        off => now;
        null @=> us[note];
        saw =< out;
    }
}

////////////////////////////////////////
// Shreds
////////////////////////////////////////

function void filterMod(CcEvent @ ev, LPF @ filter) {
    while (true) {
        ev => now;
        ev.val => Std.mtof => filter.freq;
    }
}

function void midiLoop() {
    while (true) {
        midiIn => now;

        while( midiIn.recv(midiMsg)) {
            if(midiMsg.data1 == 144) {
			    if (midiMsg.data3 > 0) {
				    midiMsg.data2 => on.note;
				    midiMsg.data3 => on.velocity;
				    on.signal();
				    me.yield();
			    } else {
				    if( us[midiMsg.data2] != null ) {
					    us[midiMsg.data2].signal();
				    }
			    }
		    } else if (midiMsg.data1 == 176) { // Control Change
			    if (midiMsg.data2 == 32) { // CC 32 => filter modulation
                    midiMsg.data3 => filterControl.val;
                    filterControl.broadcast();
			    } else {
				    // <<< "CC:  ", midiMsg.data2 >>>;
				    // <<< "Val: ", midiMsg.data3 >>>;
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
                ;
		    }			
        }
    }
}

////////////////////////////////////////
// Spork 'em
////////////////////////////////////////

// spork handlers, one for each voice
for( 0 => int i; i < 20; i++ ) {
	spork ~ handler(on, lpf);
}

spork ~ midiLoop();
spork ~ filterMod(filterControl, lpf);

while (1) {
    1000::ms => now;
}