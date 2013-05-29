fun void ping(Event e) {
    while (true) {
        e => now;
        1000::ms => now;
        chout <= "Ping!" <= IO.newline();
        e.signal();
    }
}

fun void pong(Event e) {
    while (true) {
        e => now;
        1000::ms => now;
        chout <= "Pong!" <= IO.newline();
        e.signal();
    }
}

Event e;
spork ~ ping(e);
spork ~ pong(e);

1::ms => now;
e.signal();

while (true) {
    1000::ms => now;
}