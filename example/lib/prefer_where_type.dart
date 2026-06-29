void foo() {
  final items = <String?>['a', 'b', 'c', null, 'd'];

  final result = items.where((e) => e != null); // LINT
  print(result);
}

void bar() {
  final items = <String?>['a', 'b', 'c', null, 'd'];

  final result = items.whereType<String>();
  print(result);
}
