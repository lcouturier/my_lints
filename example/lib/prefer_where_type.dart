void foo() {
  final items = <String?>['a', 'b', 'c', null, 'd'];

  final result = items.where((e) => e != null); // LINT
  print(result);
}

void foo2() {
  final items = <String?>['a', 'b', 'c', null, 'd'];

  final result = items.where((e) => e is String); // LINT
  print(result);
}

void bar() {
  final items = <String?>['a', 'b', 'c', null, 'd'];

  final result = items.whereType<String>();
  print(result);
}

void barz() {
  final items = <String?>['a', 'b', 'c', null, 'd'];

  final result = items.where((x) => x is String).cast<String>();
  print(result);
}

void barx() {
  final items = <String?>['a', 'b', 'c', null, 'd'];

  final result = items.where((x) => x is String).map((x) => x as String);
  print(result);
}
