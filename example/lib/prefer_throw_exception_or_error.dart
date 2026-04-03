void foo() {
  throw 'my exception'; //LINT
}

void bar() {
  throw MyException();
}

void bar2() {
  throw Exception(); // LINT
}

class MyException implements Exception {}
