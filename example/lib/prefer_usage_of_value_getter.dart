void foo(bool Function() f) {
  final result = f();
  print(result);
}
