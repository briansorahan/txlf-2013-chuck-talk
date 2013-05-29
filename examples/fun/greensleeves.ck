// Greensleaves (Traditional song).
// Score from http://www.mutopiaproject.org

// ChucK program
// Copyright (C) 2006 Pedro López-Cabanillas <plcl@users.sourceforge.net>

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software Foundation, Inc.
// 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

// patch
Mandolin s1 => JCRev r => dac;
Mandolin s2 => r;

// initial settings
.6 => s1.gain;
.4 => s2.gain;
.9 => r.gain;
.2 => r.mix;

// MIDI note constants
60 => int c;     72 => int C;
61 => int cs;    73 => int Cs;
62 => int d;     74 => int D;
63 => int ds;    75 => int Ds;
64 => int e;     76 => int E;
65 => int f;     77 => int F;
66 => int fs;    78 => int Fs;
67 => int g;     79 => int G;
68 => int gs;    80 => int Gs;
69 => int a;     81 => int A;
70 => int as;    82 => int As;
71 => int b;     83 => int B;

// We use musical tempo, and symbolic durations
160 => int tempo;
// integers 1,2,4,8 mean musical figures
dur duration[9];
240000::ms / ( 1 * tempo )  => duration[1]; // whole
240000::ms / ( 2 * tempo )  => duration[2]; // half
240000::ms / ( 4 * tempo )  => duration[4]; // quarter
240000::ms / ( 8 * tempo )  => duration[8]; // eighth
(duration[4] + duration[8]) => duration[5]; // dotted quarter
(duration[2] + duration[4]) => duration[3]; // dotted half

// Tune fragments. Each note is a pair of [MIDI note,duration]
[[a,4],
[C,2],[D,4],[E,5],[F,8], [E,4], [D,2], [b,4], [g,5],[a,8],[b,4],
[C,2],[a,4],[a,5],[gs,8],[a,4], [b,2], [gs,4],[e,2],[a,4],
[C,2],[D,4],[E,5],[F,8], [E,4], [D,2], [b,4], [g,5],[a,8],[b,4],
[C,5],[b,8],[a,4],[gs,5],[fs,8],[gs,4],[a,3], [a,3],
[G,2],[G,4],[G,5],[F,8], [E,4], [D,2], [b,4], [g,5],[a,8],[b,4],
[C,2],[a,4],[a,5],[gs,8],[a,4], [b,2], [gs,4],[e,2],[e,4],
[G,2],[G,4],[G,5],[F,8], [E,4], [D,2], [b,4], [g,5],[a,8],[b,4],
[C,5],[b,8],[a,4],[gs,5],[fs,8],[gs,4],[a,3], [a,3]] @=> int voice1[][];

[[0,4],
[a,2],[b,4],[C,3],[g,3],[b,3],
[a,3],[F,3],[E,3],[e,3],
[a,2],[b,4],[C,3],[g,3],[b,3],
[a,3],[e,3],[a,3],[a,3],
[C,3],[C,3],[g,3],[b,3],
[a,3],[F,3],[E,3],[e,3],
[C,3],[C,3],[g,3],[b,3],
[a,3],[e,3],[a,3],[a,3]] @=> int voice2[][];

Event finish;

// Play a fragment
fun void playVoice(Mandolin m, int voice[][], int transport) {
    for( 0 => int i; i < voice.cap(); i++) {
        if ( voice[i][0] > 0 ) {
            Std.mtof( voice[i][0] + transport ) => m.freq;
            1.0 => m.pluck;
        }
        duration[voice[i][1]] => now;
    }
    finish.broadcast();
}

// Main: play the whole song
spork ~ playVoice(s1, voice1, 0);
spork ~ playVoice(s2, voice2, -12);
finish => now;