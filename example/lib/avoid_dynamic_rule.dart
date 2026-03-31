void foo(dynamic value) {
  print(value);
}

void bar(Function f) {
  Function other = () {};
  other();
  f();
}

void test(int x) {
  x = 3; // doit être détecté
  x++; // doit être détecté
}

class TestClass {
  void test(int x, int z) {
    x = 3; // doit être détecté
    x++; // doit être détecté
    print(z);
  }
}
