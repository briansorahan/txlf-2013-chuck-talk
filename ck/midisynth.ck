class NoteEvent extends Event {
	int note;
	int velocity;
}

class MidiSynth {
	static NoteEvent @ noteOn;
}
