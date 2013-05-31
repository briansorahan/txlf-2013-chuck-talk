1::second => dur attentionSpan;
8::hour => dur workDay;
now + workDay => time done;

while (now < done) {
    lookAtClock();
    attentionSpan => now; // Advance time
}

fun void lookAtClock() {
    <<< "only", now, "samples have gone by" >>>;
}