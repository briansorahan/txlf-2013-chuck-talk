// MidiMixer.ck
// Mixer that responds to MIDI control.
//
// chuck with:
//--- MidiInstrument
//
// Brian Sorahan 2013

public class MidiMixer extends MidiInstrument {
    Gain masterGain;
    Echo echo;
    PRCRev reverb;
    Gain feedback;

    // Initialize delay params
    500 => int DELAY_MAX; // ms
    2 => int DELAY_MIN; // ms
    DELAY_MAX - DELAY_MIN => int DELAY_RANGE; // ms
    DELAY_MAX::ms => echo.max;
    feedback => reverb => masterGain;
    feedback => echo => feedback;
    echo => reverb;
    0.25 => feedback.gain;

    // Initialize reverb and gain params
    0.9 => masterGain.gain;
    0.1 => reverb.mix;

    // Default cc values
    48 => int ccDelay;
    49 => int ccFeedback;
    50 => int ccDelayMix;
    51 => int ccReverbMix;
    93 => int ccGain;

    fun dur mapDelay(int midiVal) {
        return (DELAY_RANGE * (midiVal / 127.0) + DELAY_MIN)::ms;
    }

    fun void control(ControlEvent cev) {
        cev.cc => int cc;
        cev.val => int val;
        val / 128.0 => float uval;

        if (cc == ccGain) {
            uval => masterGain.gain;
        } else if (cc == ccReverbMix) {
            uval => reverb.mix;
        } else if (cc == ccDelay) {
            val => mapDelay => echo.delay;
        } else if (cc == ccFeedback) {
            val / 130.0 => feedback.gain; // careful!
        } else if (cc == ccDelayMix) {
            uval => echo.mix;
        }
    }
}
