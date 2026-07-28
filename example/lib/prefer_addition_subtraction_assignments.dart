// ignore_for_file: unused_local_variable

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

void baz() {
  int value = 1;

  value = value + 1; // LINT: Prefer compound assignment operators over simple assignment with arithmetic operations.
  value = value - 1; // LINT: Prefer compound assignment operators over simple assignment with arithmetic operations.
}

void qux() {
  int value = 1;

  value *= 1;
  value += 1;
}
