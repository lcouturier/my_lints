void foo() {
  int value = 1;

  value++; // LINT: Prefer += or -= over ++ or --.
  value--; // LINT: Prefer += or -= over ++ or --.
}

void bar() {
  int value = 1;

  value += 1;
  value -= 1;
}
