// modalsynth.ck
// MIDI synth using the ModalBar STK class.
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
int stickHardness, stickPosition, vibratoGain, vibratoFreq;
int directStick,   preset;
[
  "Marimba",
  "Vibraphone",
  "Agogo",
  "Wood1",
  "Reso",
  "Wood2",
  "Beats",
  "Two Fixed",
  "Clump"
] @=> string presetNames[];

////////////////////////////////////////
// Shreds
////////////////////////////////////////

// midi cc
function void modalControl(CcEvent @ ev) {
    int oldPreset;
    
    while (true) {
        // Wait for a CC event
        ev => now;

        if (traceMidiCC) {
            <<< ev.cc, ev.val >>>;
        }

        // Map MIDI CC
        int modalCC;
        if (ev.cc == 32) {
            ev.val => stickHardness;
        } else if (ev.cc == 33) {
            ev.val => stickPosition;
        } else if (ev.cc == 82) {
            ev.val => vibratoGain;
        } else if (ev.cc == 83) {
            ev.val => vibratoFreq;
        } else if (ev.cc == 5) {
            ev.val => directStick;
        } else if (ev.cc == 71) {
            preset => oldPreset;
            ((8.0 * ev.val) / 120.0) $ int => preset;
            if (preset != oldPreset) {
                <<< "Preset:", presetNames[preset] >>>;
            }
        }
    }
}

// synth voice
4.0 => float polyphony; // keep the gain under control
fun void voice(int note, int velocity, Event @ noteOff, UGen @ out) {
	ModalBar modal;
    modal => out;
    1.0 => modal.gain;
    velocity / 128.0 => float vel;

    // control parameters
    modal.controlChange(2, stickHardness);
    modal.controlChange(4, stickPosition);
    modal.controlChange(11, vibratoGain);
    modal.controlChange(7, vibratoFreq);
    modal.controlChange(1, directStick);
    preset => modal.preset;

    // play it
    note => Std.mtof => modal.freq;
    vel => modal.strike;
    vel => modal.noteOn;
    noteOff => now;
    0.2 => modal.damp;
    2::second => now;
    1.0 => modal.noteOff;
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
spork ~ modalControl(ccEvent);

while (1) {
    1000::ms => now;
}
