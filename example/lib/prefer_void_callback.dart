void foo(void Function() f) {
  f();
}

void foo2(Function() f) {
  f();
}

void other(int Function() f) {
  final result = f();
  print(result);
}

void bar(void Function()? f) {
  f?.call();
}

void otherNullable(int? Function() f) {
  final result = f();
  print(result);
}

void myFuture(Future<void> Function() f) {
  f();
}
