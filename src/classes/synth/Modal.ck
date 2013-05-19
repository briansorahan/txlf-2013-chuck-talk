// Modal.ck
// MIDI synth using the ModalBar STK class.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//--- MidiInstrument.ck
//--- MidiMixer.ck
//--- SimpleFM.ck
//
// Brian Sorahan 2013

public class Modal extends MidiInstrument {
    // global control parameters for the synth voices
    int stickHardness, stickPosition, vibratoGain, vibratoFreq,
        directStick, preset;
    [ "Marimba", "Vibraphone", "Agogo", "Wood1", "Reso", "Wood2",
      "Beats", "Two Fixed", "Clump" ] @=> string presetNames[];
    
    fun void voice(NoteEvent nev) {
        nev.note => int note;
        nev.velocity => int velocity;
        
        // keep the gain under control
        4.0 => float polyphony;
        
	    ModalBar modal;
        modal => out;
        1.0 => modal.gain;
        velocity / 128.0 => float vel;

        // control parameters
        modal.controlChange(2, stickHardness);
        modal.controlChange(4, stickPosition);
        modal.controlChange(11, vibratoGain);
        modal.controlChange(7, vibratoFreq);
        modal.controlChange(1, directStick);
        preset => modal.preset;

        // play it
        note => Std.mtof => modal.freq;
        vel => modal.strike;
        vel => modal.noteOn;
        nev.noteOff => now;
        0.2 => modal.damp;
        2::second => now;
        1.0 => modal.noteOff;
        250::ms => now;
    }

    fun void control(ControlEvent cev) {
        int oldPreset;
        
        if (cev.cc == 32) {
            cev.val => stickHardness;
        } else if (cev.cc == 33) {
            cev.val => stickPosition;
        } else if (cev.cc == 82) {
            cev.val => vibratoGain;
        } else if (cev.cc == 83) {
            cev.val => vibratoFreq;
        } else if (cev.cc == 5) {
            cev.val => directStick;
        } else if (cev.cc == 6) {
            preset => oldPreset;
            ((8.0 * cev.val) / 120.0) $ int => preset;
            if (preset != oldPreset) {
                <<< "Preset ---> ", presetNames[preset] >>>;
            }
        }
    }
}
