4 => int children;
int ids[children];

chout <= "Parent's id is " + me.id() <= IO.newline();

for (0 => int i; i < children; i++) {
    Machine.add("printID") => ids[i];
    chout <= "Child's id is " + ids[i] <= IO.newline();
}
