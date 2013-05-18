// AmpEnvelope.ck
// Simple ADSR Amp Envelope.
// Brian Sorahan 2013

public class AmpEnvelope {
    100::ms => dur attack;
    100::ms => dur decay;
    100::ms => dur release;
    1.0 => float sustain;

    71 => int ccAttack;
    74 => int ccDecay;
    52 => int ccSustain;
    47 => int ccRelease;

    5 => float MAPDUR_MIN;
    2000 => float MAPDUR_MAX;
    MAPDUR_MAX - MAPDUR_MIN => float MAPDUR_RANGE;

    fun ADSR getEnvelope() {
        ADSR env;
        env.set(attack, decay, sustain, release);
        return env;
    }

    fun void control(int cc, int val) {
        val => mapDur => dur duration;

        if (cc == ccAttack) {
            duration => attack;
        } else if (cc == ccDecay) {
            duration => decay;
        } else if (cc == ccSustain) {
            val / 127.0 => sustain;
        } else if (cc == ccRelease) {
            duration => release;
        }
    }

    // Convert MIDI values to duration
    fun dur mapDur(int val) {
        return (MAPDUR_RANGE * (val / 127.0) + MAPDUR_MIN)::ms;
    }
}