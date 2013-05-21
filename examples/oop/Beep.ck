// Beep.ck

public class Beep {
    SqrOsc osc;
    440 => osc.freq;
    0.1 => osc.gain;
    
    fun void go(dur len) {
        osc => dac;
        len => now;
    }
}