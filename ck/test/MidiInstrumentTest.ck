public class MidiInstrumentTest extends MidiInstrument {
    // @Override
    fun void voice(NoteEvent nev) {
        nev.note => int n;
        nev.velocity => int v;
        this.log("Received Note On  ---> (" + n + ", " + v + ")");
        nev.noteOff => now;
        this.log("Received Note Off ---> (" + n + ", 0)");
    }

    // @Override
    fun void control(ControlEvent cev) {
        cev.cc => int cc;
        cev.val => int val;
        this.log("Received CC       ---> (" + cc + ", " + val + ")");
    }

    fun void log(string msg) {
        chout <= msg <= IO.newline();
    }
}

// Test initialization
MidiInstrumentTest test;

spork ~ MidiInstrument.listen(MidiInstrument.noteEvent, test);
spork ~ MidiInstrument.listen(MidiInstrument.controlEvent, test);

while (true) {
    1000::ms => now;
}
