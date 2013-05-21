chout <= "My id is " + me.id() <= IO.newline();
for (0 => int i; i < 5; i++) {
    Machine.add("printID") => int id;
    chout <= "ID of the sporked shred is " + id <= IO.newline();
}

100::ms => now;