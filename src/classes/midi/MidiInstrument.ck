// MidiInstrument.ck - Base MIDI instrument class.
//
// This shred will open a MIDI device, listen for Note and CC
// events from this device, and trigger events through
// static Event references in the public class.
//
// chuck with:
//--- NoteEvent.ck
//--- ControlEvent.ck
//
// Brian Sorahan 2013



// MIDI device number is hardcoded!
// Change this to use a different device.
MidiIn midiIn;
if (! midiIn.open(1)) {
    cherr <= "Could not open MIDI device." <= IO.newline();
    me.exit();
}



////////////////////////////////////////////////////////////////////////////////
// MidiInstrument Class
////////////////////////////////////////////////////////////////////////////////

public class MidiInstrument {
    static NoteEvent @ noteEvent;
    static ControlEvent @ controlEvent;

    Gain out;
    0.99 => out.gain;

    fun static void sendNotesTo(MidiInstrument inst) {
        while (true) {
            noteEvent => now;
            spork ~ inst.voice(noteEvent);
        }
    }

    fun static void sendControlTo(MidiInstrument inst) {
        while (true) {
            controlEvent => now;
            spork ~ inst.control(controlEvent);
        }
    }

    // Synth voice shred
    function void voice(NoteEvent noteEvent) {
        ; // *override with custom synth voice*
    }

    // Controller shred
    function void control(ControlEvent controlEvent) {
        ; // *override with custom controller logic*
    }
}

// Initialize the static fields of MidiInstrument
new NoteEvent @=> MidiInstrument.noteEvent;
new ControlEvent @=> MidiInstrument.controlEvent;



////////////////////////////////////////////////////////////////////////////////
// SHREDS
////////////////////////////////////////////////////////////////////////////////

// MIDI listener
function void midiLoop(NoteEvent nev, ControlEvent cev, int traceNotes, int traceControl, int traceMidi) {
    MidiMsg midiMsg;
    
    // this needs to get initialized outside of handleNote
    Event noteOff[128];
    
    while (true) {
        traceMsg("... waiting for MidiIn event", traceMidi);
        midiIn => now;
        traceMsg("... received MidiIn event", traceMidi);

        while (midiIn.recv(midiMsg)) {
            if(midiMsg.data1 == 144) {
                handleNote(nev, noteOff, midiMsg, traceNotes);
		    } else if (midiMsg.data1 == 176) {
                handleControl(cev, midiMsg, traceControl);
            }
        }
    }
}

function void handleNote(NoteEvent nev, Event @ offEvents[], MidiMsg midiMsg, int trace) {
    int note, velocity;
    
    midiMsg.data2 => note;
    midiMsg.data3 => velocity;

    traceMsg("... MIDI Note " + note + ", " + velocity, trace);
    
	if (velocity > 0) {
        // traceMsg("... triggering note on for " + note, trace);

        // Trigger Note On
        note => nev.note;
        velocity => nev.velocity;

        if (offEvents[note] == null) {
            Event off;
            off @=> offEvents[note];
            off @=> nev.noteOff;
        } else {
            offEvents[note] @=> nev.noteOff;
        }
            
        nev.broadcast();
		me.yield();
	}
    // Trigger Note Off
    else {
        if (offEvents[note] != null) {
            // traceMsg("... triggering note off for " + note, trace);
            offEvents[note].broadcast();
        }
	}
}

// control listener
function void handleControl(ControlEvent cev, MidiMsg midiMsg, int trace) {
    midiMsg.data2 => cev.cc;
    midiMsg.data3 => cev.val;
    cev.broadcast();
}

// message printer
function void traceMsg(string msg, int flag) {
    if (flag) {
        chout <= msg <= IO.newline();
    }
}

// Enter infinite loop
midiLoop(MidiInstrument.noteEvent, MidiInstrument.controlEvent, 0, 0, 0);
