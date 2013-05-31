now + 2::second => time later;
chout <= IO.newline();
<<< "now:", now >>>;
chout <= IO.newline();

chout <= "Chucking a 1::second to now..." <= IO.newline();
1::second => now;
<<< "now:", now >>>;
chout <= IO.newline();

chout <= "Chucking later to now..." <= IO.newline();
later => now;
<<< "now:", now >>>;
chout <= IO.newline();

Event e;
chout <= "Chucking event to now..." <= IO.newline();
spork ~ eventTrigger(e);
e => now;
<<< "now:", now >>>;
chout <= IO.newline();

fun void eventTrigger(Event e) {
    Math.random2(1, 5)::second => now;
    e.signal();
}