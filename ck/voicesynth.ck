// voicesynth.ck
// MIDI synth using the VoicForm STK class.
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
int mix, phoneme, vibratoFreq, vibratoGain;
int loudness;
[
    "eee", "ihh", "ehh", "aaa",
    "ahh", "aww", "ohh", "uhh",
    "uuu", "ooo", "rrr", "lll",
    "mmm", "nnn", "nng", "ngg",
    "fff", "sss", "thh", "shh",
    "xxx", "hee", "hoo", "hah",
    "bbb", "ddd", "jjj", "ggg",
    "vvv", "zzz", "thz", "zhh"
] @=> string phonemeNames[];

////////////////////////////////////////
// Shreds
////////////////////////////////////////

// midi cc
function void modalControl(CcEvent @ ev) {
    int oldPhoneme;
    
    while (true) {
        // Wait for a CC event
        ev => now;

        if (traceMidiCC) {
            <<< ev.cc, ev.val >>>;
        }

        // Map MIDI CC
        if (ev.cc == 32) {
            ev.val => mix;
        } else if (ev.cc == 33) {
            phoneme => oldPhoneme;
            (ev.val / 3.8) $ int => phoneme;
            if (oldPhoneme != phoneme) {
                <<< "Phoneme =", phonemeNames[phoneme] >>>;
            }
        } else if (ev.cc == 82) {
            ev.val => vibratoFreq;
        } else if (ev.cc == 83) {
            ev.val => vibratoGain;
        } else if (ev.cc == 5) {
            ev.val => loudness;
        }
    }
}

// synth voice
4.0 => float polyphony; // keep the gain under control
fun void voice(int note, int velocity, Event @ noteOff, UGen @ out) {
	VoicForm voicform;
    voicform => out;
    1.0 => voicform.gain;
    velocity / 128.0 => float vel;

    // control parameters
    voicform.controlChange(2, mix);
    voicform.controlChange(4, phoneme);
    voicform.controlChange(11, vibratoFreq);
    voicform.controlChange(1, vibratoGain);
    voicform.controlChange(128, loudness);

    // play it
    note => Std.mtof => voicform.freq;
    // vel => voicform.speak;
    vel => voicform.noteOn;
    noteOff => now;
    // 0.2 => voicform.quiet;
    // 2::second => now;
    1.0 => voicform.noteOff;
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
