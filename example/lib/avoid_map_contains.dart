void foo() {
  final d = {'hello': 'world'};

  final result = d.keys.contains('hello'); // LINT
  print(result);
}

void bar() {
  final d = {'hello': 'world'};

  final result = d.containsKey('hello');
  print(result);
}
