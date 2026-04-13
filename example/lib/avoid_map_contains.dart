void foo() {
  final map = {'hello': 'world'};

  final result = map.keys.contains('hello'); // LINT
  print(result);
}

void bar() {
  final map = {'hello': 'world'};

  final result = map.containsKey('hello');
  print(result);
}
