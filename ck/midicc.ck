1 => int device;
MidiIn midiIn;
MidiMsg midiMsg;

if (! midiIn.open(device)) {
	chout <= "Could not open midi device." <= IO.newline();
	me.exit();
}

class NoteEvent extends Event {
	int note;
	int velocity;
}

NoteEvent on;
Event @ us[128];

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
			<<< "CC:  ",  midiMsg.data2 >>>;
			<<< "Val: ",  midiMsg.data3 >>>;
		}
    }
}