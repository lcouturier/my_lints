void foo() {
  final items = [1, 2, 3, 4];
  final value = items.reduce((a, b) => a + b); // LINT
  print(value);
}

void bar() {
  final items = [1, 2, 3, 4];
  final value = items.where((e) => e.isEven).reduce((a, b) => a + b); // LINT
  print(value);
}

void foo2() {
  final items = [1, 2, 3, 4];
  final value = items.isNotEmpty ? items.reduce((a, b) => a + b) : 0;
  print(value);
}

void foo4() {
  final items = [1, 2, 3, 4];
  final value = items.isEmpty ? 0 : items.reduce((a, b) => a + b);
  print(value);
}

void foo3() {
  final items = [1, 2, 3, 4];
  if (items.isNotEmpty) {
    final value = items.reduce((a, b) => a + b);
    print(value);
  } else {
    print(0);
  }
}

void foo5() {
  final items = [1, 2, 3, 4];
  if (!items.isEmpty) {
    final value = items.reduce((a, b) => a + b);
    print(value);
  } else {
    print(0);
  }
}
