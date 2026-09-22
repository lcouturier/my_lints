void foo() {
  bool? value;
  if (value == true) {
    // LINT
    print('value is true');
  }
}

void bar() {
  bool? value;
  if (value == true) {
    print('value is false');
  }
}
