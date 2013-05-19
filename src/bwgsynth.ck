class CcEvent extends Event {
    int cc;
	int val;
}

1 => int device;
MidiIn midiIn;
MidiMsg midiMsg;

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
masterGain => r => dac;
// masterGain => dac;
.8 => masterGain.gain;
.2 => r.mix;

// global control parameters for the synth voices
float bowPressure, bowMotion, strikePosition, vibFreq;
float bowVelocity, bowRate,   setStriking,    modesGain;
int preset;
[
  "Uniform Bar",
  "Tuned Bar",
  "Glass Harmonica",
  "Tibetan Bowl"
] @=> string presetNames[];


////////////////////////////////////////
// Shreds
////////////////////////////////////////

// midi cc
function void bwgControl(CcEvent @ ev) {
    int oldPreset;
    
    while (true) {
        // Wait for a CC event
        ev => now;

        // Map MIDI CC to BandedWG CC
        int bwgCC;
        if (ev.cc == 32) {
            ev.val => bowPressure; // bow pressure
        } else if (ev.cc == 33) {
            ev.val => bowMotion; // bow motion
        } else if (ev.cc == 82) {
            ev.val => strikePosition; // strike position
        } else if (ev.cc == 83) {
            ev.val => vibFreq; // vibrato frequency
        } else if (ev.cc == 5) {
            ev.val => bowVelocity; // bow velocity
        } else if (ev.cc == 6) {
            ev.val => setStriking; // set striking
        } else if (ev.cc == 40) {
            ev.val => bowRate; // bow rate
        } else if (ev.cc == 43) {
            ev.val / 128.0 => modesGain; // modes Gain
        } else if (ev.cc == 71) {
            preset => oldPreset;
            ((3.0 * ev.val) / 120.0) $ int => preset;
            if (oldPreset != preset) {
                <<< "Preset = ", presetNames[preset] >>>;
            }
        }
    }
}

// synth voice
4.0 => float polyphony; // keep the gain under control
fun void voice(int note, int velocity, Event @ noteOff, UGen @ out) {
	BandedWG bwg;
    bwg => out;
    1.0 => bwg.gain;
    velocity / 128.0 => float vel;

    // control parameters
    bwg.controlChange(2, bowPressure); // bow pressure
    bwg.controlChange(4, bowMotion); // bow motion
    bwg.controlChange(8, strikePosition); // strike position
    bwg.controlChange(11, vibFreq); // vibrato frequency
    bwg.controlChange(128, bowVelocity); // bow velocity
    bwg.controlChange(64, setStriking); // set striking
    bowRate => bwg.bowRate; // bow rate
    modesGain => bwg.modesGain; // modes Gain
    preset => bwg.preset; // modes Gain

    // pluck, gain, freq
    vel => bwg.pluck;
    bwg.controlChange(1, velocity);
    note => Std.mtof => bwg.freq;

    // play it
    vel => bwg.noteOn;
    vel => bwg.startBowing;
    noteOff => now;
    1.0 => bwg.noteOff;
    vel => bwg.stopBowing;
    2::second => now;
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
spork ~ bwgControl(ccEvent);

while (1) {
    1000::ms => now;
}
