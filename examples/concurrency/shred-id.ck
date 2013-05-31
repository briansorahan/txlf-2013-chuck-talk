4 => int shreds;
Shred @ shredObjects[shreds];

fun void printID() {
    chout <= "Child's id is " + me.id() <= IO.newline();
}

chout <= "Parent's id is " + me.id() <= IO.newline();
for (0 => int i; i < shreds; i++) {
    spork ~ printID() @=> shredObjects[i];
}

// 1::ms => now;

for (0 => int i; i < shreds; i++) {
    <<< shredObjects[i] >>>;
}
