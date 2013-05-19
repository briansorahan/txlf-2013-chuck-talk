// VibratoFM.ck
// An FM synth that showcases the full spectrum of sounds
// between vibrato and FM.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- AmpEnvelope.ck
//--- SimpleFM.ck
//
// Brian Sorahan 2013

public class VibratoFM extends SimpleFM {
    // @Override
    fun float mapModFreq(int val) {
        return val - 63 => Std.mtof;
    }
}