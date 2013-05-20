fun void sporkMe(Event done) {
    chout <= "Hello, World!" <= IO.newline();
    done.signal();
}

Event done;
spork ~ sporkMe(done);
done => now;