fun void printID() {
    chout <= "My id is " + me.id() <= IO.newline();
}

chout <= "My id is " + me.id() <= IO.newline();
for (0 => int i; i < 5; i++) {
    spork ~ printID();
}

100::ms => now;