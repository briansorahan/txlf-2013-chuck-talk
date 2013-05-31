fun int add(int a, int b) {
    return a + b;
}

fun dur add(dur a, dur b) {
    return a + b;
}

<<< add(1, 2) >>>;
<<< add(1::second, 2::second) >>>;