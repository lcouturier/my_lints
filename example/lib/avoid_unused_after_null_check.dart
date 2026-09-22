void foo() {
  final String? value = 'test';
  if (value != null) {
    print(value);
  }
}

void bar() {
  final String? value = 'test';
  if (value != null) {
    // Missing reference to value
  }
}
