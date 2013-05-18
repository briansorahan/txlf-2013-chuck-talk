// chuck with:
//--- SharedEvent.ck

fun void printMsg(Event ev) {
    ev => now;
    cherr <= "Receieved shared event." <= IO.newline();
}

spork ~ printMsg(SharedEvent.ev);

3::second => now;