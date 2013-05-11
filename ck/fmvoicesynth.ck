// fmsynth.ck
// MIDI synth using the FMVoices STK class.
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

// global control parameters for the synth voices
int vowel, spectralTilt, lfoSpeed, lfoDepth;
int adsrTarget;

////////////////////////////////////////
// Shreds
////////////////////////////////////////

// midi cc
function void fmvControl(CcEvent @ ev) {
    int oldPhoneme;
    
    while (true) {
        // Wait for a CC event
        ev => now;

        if (traceMidiCC) {
            <<< ev.cc, ev.val >>>;
        }

        // Map MIDI CC
        if (ev.cc == 32) {
            ev.val => vowel;
        } else if (ev.cc == 33) {
            ev.val => spectralTilt;
        } else if (ev.cc == 82) {
            ev.val => lfoSpeed;
        } else if (ev.cc == 83) {
            ev.val => lfoDepth;
        } else if (ev.cc == 5) {
            ev.val => adsrTarget;
        }
    }
}

// synth voice
4.0 => float polyphony; // keep the gain under control
fun void voice(int note, int velocity, Event @ noteOff, UGen @ out) {
	FMVoices oscillator;
    oscillator => out;
    1.0 => oscillator.gain;
    velocity / 128.0 => float vel;

    // control parameters
    oscillator.controlChange(2, vowel);
    oscillator.controlChange(4, spectralTilt);
    oscillator.controlChange(11, lfoSpeed);
    oscillator.controlChange(1, lfoDepth);
    oscillator.controlChange(128, adsrTarget);

    // play it
    note => Std.mtof => oscillator.freq;
    vel => oscillator.noteOn;
    noteOff => now;
    1.0 => oscillator.noteOff;
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
spork ~ fmvControl(ccEvent);

while (1) {
    1000::ms => now;
}
