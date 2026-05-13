void foo() {
  throw 'error'; // LINT
}

void bar() {
  throw Exception('error'); // OK
}
