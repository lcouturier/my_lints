// ignore_for_file: unused_element

void foo(bool animated) {
  // LINT
  // ...
}

void bar() {
  void foo(bool x) {}
}

final fn = (bool enabled) {};

typedef Callback = void Function(String, int);

void baz(Callback callback) {
  callback('hello', 42);
}

void baz2(void Function(String, int) callback) {
  // LINT
  callback('hello', 42);
}
