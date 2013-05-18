public class SharedEvent {
    static Event @ ev;
}

fun void triggerEvent(Event ev) {
    2::second => now;
    ev.signal();
}

new Event @=> SharedEvent.ev;
triggerEvent(SharedEvent.ev);