// MidiMixer.ck
// Mixer that responds to MIDI control.
//
// chuck with:
//--- MidiInstrument
//
// Brian Sorahan 2013

public class MidiMixer extends MidiInstrument {
    Gain masterGain;
    PRCRev reverb;
    reverb => masterGain;
    0.9 => masterGain.gain;
    0.1 => reverb.mix;

    // Default cc values
    93 => int ccGain;
    51 => int ccMix;

    fun void connectMaster(UGen in) {
        in => masterGain;
    }

    fun void disconnectMaster(UGen in) {
        in =< masterGain;
    }

    fun void connectReverb(UGen in) {
        in => reverb;
    }

    fun void disconnectReverb(UGen in) {
        in =< reverb;
    }

    fun void control(ControlEvent cev) {
        cev.cc => int cc;
        cev.val => int val;
        val / 128.0 => float uval;

        // <<< "MidiMixer", cc, val >>>;
        
        if (cc == ccGain) {
            // <<< "Changing gain to", uval >>>;
            uval => masterGain.gain;
        } else if (cc == ccMix) {
            // <<< "Changing reverb mix to", uval >>>;
            uval => reverb.mix;
        }
    }
}
