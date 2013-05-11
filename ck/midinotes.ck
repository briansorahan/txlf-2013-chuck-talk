1 => int device;
MidiIn midiIn;
MidiMsg midiMsg;

if (! midiIn.open(device)) {
	cherr <= "Could not open midi device." <= IO.newline();
	me.exit();
}

// infinite time-loop
while (true) {
    // wait on midi event
    midiIn => now;

    // get the midimsg
    while (midiIn.recv(midiMsg)) {
		if (midiMsg.data1 == 144) {
			<<< "Note: ",  midiMsg.data2, "  Velocity: ", midiMsg.data3 >>>;
		}
    }
}
