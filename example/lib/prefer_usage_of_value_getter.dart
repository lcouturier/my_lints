void foo(bool Function() f) {
  final result = f();
  print(result);
}

void bar(int? Function()? f) {
  final result = f?.call();
  print(result);
}
